class Connection < EM::Connection
  attr_reader :username
  attr_accessor :user, :prompt_shown
  attr_reader :terminal_width, :terminal_height

  module PASSWORD_STATES
    INVALID = :invalid
    BLANK = :blank
    VALID = :valid
  end

  module LOGIN_STATES 
    USERNAME = :username
    PASSWORD = :password
    LOGGED_IN = :logged_in
  end

  module USERNAME_STATES
    BLANK = :blank
    EXISTING = :existing
    NEW = :new
  end

  module ECHO_STATUS
    ON = :on
    OFF = :off
  end

  module IAC_COMMAND
    NAWS = "\x1F".b
    ECHO = "\x01".b
    NONE = :none
  end

  module IAC_ACTION
    WILL = "\xFB".b
    WONT = "\xFC".b
    DO = "\xFD".b
    DONT = "\xFE".b
    SB = "\xFA".b
  end

  IAC_START = "\xFF".b

  #
  # EventMachine handlers
  #

  def post_init
    @current_password_state = PASSWORD_STATES::INVALID
    @current_login_state = LOGIN_STATES::USERNAME
    @current_username_state = USERNAME_STATES::BLANK
    @current_echo_status = ECHO_STATUS::ON

    puts 'A client has connected...'
    send_line('Enter your username:')

    # request NAWS
    send_data(IAC_START + IAC_ACTION::DO + IAC_COMMAND::NAWS)
  end

  def unbind
    RubyMUD.remove_client(self)

    if user.present?
      user.update_column(:online, false)
    end

    if logged_in?
      RubyMUD.send_to_clients(MessageHelper.info_message("#{user.name} has left the game."), ConnectionHelper.other_peers(self))
      puts "[info] #{user.name} has left"
    end
  end

  ##
  # This is everything about the connection. We can send data whenever we
  # want, but the process is always going to end up "blocking" here until we
  # hear back from the user.
  def receive_data(data)
    @current_response = data.strip

    # TODO: move this into a telnet IAC handler or something
    # IAC telnet protocol responses:
    #   https://github.com/blinkdog/telnet-stream/blob/master/src/main/coffee/telnetInput.coffee
    #   https://unix.stackexchange.com/questions/207782/how-are-terminal-length-and-width-forwarded-over-ssh-and-telnet
    #   https://users.cs.cf.ac.uk/Dave.Marshall/Internet/node141.html
    #
    # skip responding if it's the client sending us a protocol response code
    if is_protocol_response?(@current_response)
      # Some clients send this as two different responses (like the spec) and some don't (like telnet itself)
      # e.g. 255,251,31 then 255,250,31,width,height,255,240 vs. 255,251,31,255,250,31,width,height,255,240
      #
      # If it's a WILL NAWS with extra info, chop that off and continue
      # WILL NAWS response to DO NAWS
      if @current_response[1] == IAC_ACTION::WILL && @current_response[2] == IAC_COMMAND::NAWS && @current_response.length > 3
        @current_response = @current_response[3..-1]
      end

      # SB NAWS response to client window change
      if @current_response[1] == IAC_ACTION::SB && @current_response[2] == IAC_COMMAND::NAWS
        @terminal_width = @current_response[3,2].unpack('n')[0]
        @terminal_height = @current_response[5,2].unpack('n')[0]
      end

      return
    end

    # if they're not currently logged in, as in "playing", then we've gotta go
    # through sign in process
    if !logged_in?
      if @current_login_state == LOGIN_STATES::USERNAME
        do_username_handling
      elsif @current_login_state == LOGIN_STATES::PASSWORD
        do_password_handling
      else
        # something bad happened
        puts 'Auth error'
      end
    else
      # we're got a logged in user that needs to deal with a command, so let's send it off to the handler
      CommandHandler.handle_command(self, data)
    end
  end

  ####
  # Login handling
  ####

  def do_username_handling
    if @current_response.blank?
      send_line('Blank usernames are not allowed. Try again:')
      return
    end

    # next try to find a user
    @logging_in_user = User.find_by_username(@current_response)

    if @logging_in_user.present?
      send_line("Welcome back, #{@logging_in_user.username}! Enter your password:")
      @current_username_state = USERNAME_STATES::EXISTING
    end

    if @logging_in_user.blank?
      send_line("We haven't seen you before, #{@current_response}. Choose a password:")
      @current_username_state = USERNAME_STATES::NEW
      @logging_in_user = User.new(
        username: @current_response,
        name: @current_response
      )
    end

    @current_login_state = LOGIN_STATES::PASSWORD
    disable_echo
  end

  def do_password_handling
    if @current_response.blank?
      send_line('Please enter a valid password:')
      @current_password_state = PASSWORD_STATES::BLANK
      return
    end

    if @current_username_state == USERNAME_STATES::NEW
      @logging_in_user.password = @current_response
      @logging_in_user.save
    end

    if @current_username_state == USERNAME_STATES::EXISTING
      if @logging_in_user.password != @current_response
        send_line('That password is incorrect. Try again:')
        @current_password_state = PASSWORD_STATES::INVALID
        return
      end
    end

    @current_login_state = LOGIN_STATES::LOGGED_IN
    enable_echo

    # should go ahead an do this here, otherwise we have to wait for a response
    # before we can even start showing anything else
    do_login_finalization
  end

  def do_login_finalization
    RubyMUD.add_client(self)
    self.user = @logging_in_user
    self.user.connection = self

    # ensure they're in a valid room
    if self.user.room.blank?
      self.user.room = Game.get_world.starting_room
      self.user.save
    end

    self.user.update_column(:online, true)

    # send the welcome message and let the player know where they are
    send_line('Welcome to RubyMUD!')
    send_line(self.user.room.render_for(user))

    RubyMUD.send_to_clients(MessageHelper.info_message("#{self.user.name} has joined the game"), ConnectionHelper.other_peers(self))
    puts "#{Paint[self.user.name, :green]} has joined"
  end

  #
  # Username handling
  #

  def logged_in?
    self.user.present?
  end

  def enable_echo
    @current_echo_status = ECHO_STATUS::ON
    send_data(IAC_START + IAC_ACTION::WONT + IAC_COMMAND::ECHO)
  end

  def disable_echo
    @current_echo_status = ECHO_STATUS::OFF
    send_data(IAC_START + IAC_ACTION::WILL + IAC_COMMAND::ECHO)
  end

  def is_protocol_response?(response)
    response[0] == IAC_START
  end

  def send_line(line)
    clear_prompt

    # we must add a carriage return anywhere echo would be off or the client
    # doesn't know what to do with cursor placement
    self.send_data("#{line}#{(@current_echo_status == ECHO_STATUS::OFF ? "\r" : "")}\n")

    show_prompt
  end

  def prompt_shown?
    self.prompt_shown
  end

  def clear_prompt
    if logged_in? && prompt_shown?
      send_data("\e[2K\r")
      self.prompt_shown = false
    end
  end

  def show_prompt(force: false)
    if logged_in? && (!prompt_shown? || force)
      send_data(user.prompt)
      self.prompt_shown = true
    end
  end
end
