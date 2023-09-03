class Muby::Connection < EM::Connection

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
    @username = nil

    @current_password_state = PASSWORD_STATES::INVALID
    @current_login_state = LOGIN_STATES::USERNAME
    @current_username_state = USERNAME_STATES::BLANK
    @current_echo_status = ECHO_STATUS::ON

    puts 'A client has connected...'
    send_line('Enter your username:')
  end

  def unbind
    @@connected_clients.delete(self)

    send_to_clients(Muby::MessageHelper.info_message("#{@username} has left the game."), Muby::ConnectionHelper.other_peers(self))
    puts "[info] #{@username} has left" if entered_username?
  end

  ##
  # This is everything about the connection. We can send data whenever we
  # want, but the process is always going to end up "blocking" here until we
  # hear back from the user.
  def receive_data(data)
    @current_response = data.strip

    # skip responding if it's just the client sending us an ACK
    if is_echo_response?(@current_response)
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
      Muby::CommandHandler.handle_command(self, data)
    end
  end

  ####
  # Login handling
  #
  # NOTE: we _must_ add a carriage return anywhere echo would be off or the
  # client doesn't know what to do with cursor placement
  ####

  def do_username_handling
    if @current_response.blank?
      send_line("Blank usernames are not allowed. Try again:\r")
      return
    end

    # next try to find a user
    @current_user = Muby::User.find_by_username(@current_response)

    if @current_user.present?
      send_line("Welcome back, #{@current_user.username}! Enter your password:\r")
      @current_username_state = USERNAME_STATES::EXISTING
    end

    if @current_user.blank?
      send_line("We haven't seen you before, #{@current_response}. Choose a password:\r")
      @current_username_state = USERNAME_STATES::NEW
      @current_user = Muby::User.new(
        username: @current_response,
        name: @current_response
      )
    end

    @current_login_state = LOGIN_STATES::PASSWORD
    disable_echo
  end

  def do_password_handling
    if @current_response.blank?
      send_line("Please enter a valid password:\r")
      @current_password_state = PASSWORD_STATES::BLANK
      return
    end

    if @current_username_state == USERNAME_STATES::NEW
      @current_user.password = @current_response
      @current_user.save
    end

    if @current_username_state == USERNAME_STATES::EXISTING
      if @current_user.password != @current_response
        send_line("That password is incorrect. Try again:\r")
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
    self.user = @current_user
    self.user.connection = self

    # ensure they're in a valid room
    if self.user.room.blank?
      self.user.room = Muby::Game.get_world.starting_room
      self.user.save
    end

    # send the welcome message and let the player know where they are
    send_line('Welcome to Muby!')
    send_line(self.user.room.render)
    send_line(self.user.prompt)

    send_to_clients(Muby::MessageHelper.info_message("#{@username} has joined the game"), Muby::ConnectionHelper.other_peers(self))
    puts Paint[@username, :green] + ' has joined'
  end

  #
  # Username handling
  #

  def entered_username?
    @username.present?
  end

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

  def is_echo_response?(response)
    echo_response_codes = [
      "\xFF\xFD\x01".b,
      "\xFF\xFE\x01".b
    ]

    echo_response_codes.include?(response)
  end

  #
  # Helpers
  #

  def number_of_connected_clients
    @@connected_clients.count
  end

  def send_line(line)
    self.send_data("#{line}\n")
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
