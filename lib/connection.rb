class Connection < EM::Connection

  @@connected_clients = Array.new

  attr_reader :username
  attr_accessor :user

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
  end

  def unbind
    @@connected_clients.delete(self)
    self.user.update_column(:online, false)

    if logged_in?
      send_to_clients(MessageHelper.info_message("#{self.user.name} has left the game."), ConnectionHelper.other_peers(self))
      puts "[info] #{self.user.name} has left"
    end
  end

  ##
  # This is everything about the connection. We can send data whenever we
  # want, but the process is always going to end up "blocking" here until we
  # hear back from the user.
  def receive_data(data)
    @current_response = data.strip

    # TODO: we should probably respond to most of these properly. some are
    # just things like echo ACKs, which we don't care about. some can be killed
    # or dropped clients. some can be useful (like console dimensions). can
    # this just be solved in this method by checking that it's an ASCII response
    # type?
    #
    # see for some details about how IAC commands work:
    #   https://github.com/blinkdog/telnet-stream/blob/master/src/main/coffee/telnetInput.coffee
    #   https://unix.stackexchange.com/questions/207782/how-are-terminal-length-and-width-forwarded-over-ssh-and-telnet
    #
    # skip responding if it's the client sending us a protocol response code
    if is_protocol_response?(@current_response)
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
      send_line("Blank usernames are not allowed. Try again:")
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
      send_line("Please enter a valid password:")
      @current_password_state = PASSWORD_STATES::BLANK
      return
    end

    if @current_username_state == USERNAME_STATES::NEW
      @logging_in_user.password = @current_response
      @logging_in_user.save
    end

    if @current_username_state == USERNAME_STATES::EXISTING
      if @logging_in_user.password != @current_response
        send_line("That password is incorrect. Try again:")
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
    @@connected_clients.push(self)
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
    send_line(self.user.room.render)
    send_line(self.user.prompt)

    send_to_clients(MessageHelper.info_message("#{self.user.name} has joined the game"), ConnectionHelper.other_peers(self))
    puts Paint[self.user.name, :green] + ' has joined'
  end

  #
  # Username handling
  #

  def logged_in?
    self.user.present?
  end

  def enable_echo
    @current_echo_status = ECHO_STATUS::ON
    send_data("\xFF\xFC\x01".b)
  end

  def disable_echo
    @current_echo_status = ECHO_STATUS::OFF
    send_data("\xFF\xFB\x01".b)
  end

  def is_protocol_response?(response)
    protocol_response_codes = [
      "\xFF\xF4\xFF\xFD\x06".b, # kill (ctrl+c)
      # echo protocol ACKs
      "\xFF\xFD\x01".b,
      "\xFF\xFE\x01".b
    ]

    protocol_response_codes.include?(response)
  end

  #
  # Helpers
  #

  def number_of_connected_clients
    @@connected_clients.count
  end

  def send_line(line)
    # we must add a carriage return anywhere echo would be off or the client
    # doesn't know what to do with cursor placement
    self.send_data("#{line}#{(@current_echo_status == ECHO_STATUS::OFF ? "\r" : "")}\n")
  end

  def send_to_clients(message, clients = nil)
    clients ||= @@connected_clients

    clients.each do |client|
      client.send_line(message)
    end
  end

  def send_to_users(message, users)
    users.each do |user|
      # TODO: this is extremely gross, but because we're using ActiveRecord
      # relations, when you load certain things, they don't contain their
      # instance variables anymore. For now, we'll just find the client that
      # matches each user
      find_client_by_user(user).send_line(message)
    end
  end

  def self.connected_clients
    @@connected_clients
  end

  private

  def find_client_by_user(user)
    @@connected_clients.each do |client|
      if client.user.id == user.id
        return client
      end
    end

    nil
  end
end
