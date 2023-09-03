class Muby::Connection < EM::Connection

  @@connected_clients = Array.new

  attr_reader :username
  attr_accessor :user

  #
  # EventMachine handlers
  #

  def post_init
    @username = nil

    puts 'A client has connected...'
    ask_for_username
  end

  def unbind
    @@connected_clients.delete(self)

    send_to_clients(info_message("#{@username} has left the game."), other_peers)
    puts "[info] #{@username} has left" if entered_username?
  end

  def receive_data(data)
    data = data.strip

    if logged_in?
      command, arguments = data.split(' ', 2)
      Muby::CommandHandler.dispatch_command(self, command.downcase.to_sym, arguments)
      binding.pry
      # handle_chat_message(data)
    elsif !entered_username?
      verify_username(data)
    else
      verify_password(data)
    end
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

  def ask_for_username
    send_line('Enter your username:')
  end

  def verify_username(input)
    if input.empty?
      send_line('Blank usernames are not allowed. Try again.')
      ask_for_username
    else
      @username = input
      existing_user = Muby::User.where(username: @username).first

      if existing_user.blank?
        send_line('We haven\'t seen you before. Choose a password:')
      else
        send_line("Welcome back #{@username}! Enter your password:")
      end
    end
  end

  # TODO: Turn off echo for passwords?
  def verify_password(input)
    existing_user = Muby::User.where(username: @username).first

    if input.blank?
      send_line('Please enter a valid password:')
      return
    elsif existing_user.blank?
      self.user = Muby::User.create(
        username: @username,
        name: @username,
        password: input,
        room: Muby::Room.first
      )
    elsif existing_user.password != input
      send_line('That password is incorrect. Try again:')
      return
    else
      self.user = existing_user
      self.user.room = Muby::Room.first
      self.user.save
    end

    @@connected_clients.push(self)
    send_line('Welcome to Muby! Start chatting now!')
    send_to_clients(info_message("#{@username} has joined the room"), other_peers)
    puts Paint[@username, :green] + ' has joined'
  end


  #
  # Message handling
  #

  def handle_chat_message(message)
    if command?(message)
      self.handle_command(message)
    else
      send_to_clients(user_message(user, message), other_peers)
      send_line(feedback_message(message))
    end
  end


  #
  # Commands handling
  #

  def command?(input)
    input =~ /(exit|status)$/i
  end

  def handle_command(cmd)
    case cmd
    when /exit$/i   then self.close_connection
    when /status$/i then self.send_line("[chat server] It's #{Time.now.strftime('%H:%M')} and there are #{self.number_of_connected_clients} people in the room")
    end
  end


  #
  # Helpers
  #

  def info_message(message)
    "#{Paint['[info]', :cyan]} #{message}"
  end

  def user_message(user, message, user_color = :green)
    "#{Paint["#{user.name} says:", user_color]} #{message}"
  end

  def feedback_message(message)
    "#{Paint['you say:', :yellow]} #{message}"
  end

  def number_of_connected_clients
    @@connected_clients.count
  end

  def other_peers
    @@connected_clients.reject { |c| self == c }
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

  def self.connected_clients
    @@connected_clients
  end
end
