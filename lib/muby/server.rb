class Muby::Server < EM::Connection

  @@connected_clients = Array.new
  DM_REGEXP           = /^@([a-zA-Z0-9]+)\s*:?\s*(.+)/.freeze

  attr_reader :username
  attr_accessor :user

  #
  # EventMachine handlers
  #

  def post_init
    @username = nil

    puts "A client has connected..."
    ask_username
  end

  def unbind
    @@connected_clients.delete(self)
    puts "[info] #{@username} has left" if entered_username?
  end

  def receive_data(data)
    if entered_username?
      handle_chat_message(data.strip)
    else
      handle_username(data.strip)
    end
  end


  #
  # Username handling
  #

  def entered_username?
    !@username.nil? && !@username.empty?
  end # entered_username?

  def handle_username(input)
    if input.empty?
      send_line("Blank usernames are not allowed. Try again.")
      ask_username
    else
      @username = input
      @@connected_clients.push(self)
      self.user = Muby::User.create(
        name: @username
      )
      self.other_peers.each { |c| c.send_data("#{@username} has joined the room\n") }
      puts Paint[@username, :green] + ' has joined'

      self.send_line(info_message("Welcome, #{@username}!"))
    end
  end # handle_username(input)

  def ask_username
    self.send_line(info_message('Enter your username:'))
  end # ask_username


  #
  # Message handling
  #

  def handle_chat_message(msg)
    if command?(msg)
      self.handle_command(msg)
    else
      if direct_message?(msg)
        self.handle_direct_message(msg)
      else
        self.announce(msg, "#{@username}:")
      end
    end
  end # handle_chat_message(msg)

  def direct_message?(input)
    input =~ DM_REGEXP
  end # direct_message?(input)

  def handle_direct_message(input)
    username, message = parse_direct_message(input)

    if connection = @@connected_clients.find { |c| c.username == username }
      puts "[dm] @#{@username} => @#{username}"
      connection.send_line("[dm] @#{@username}: #{message}")
    else
      send_line "@#{username} is not in the room. Here's who is: #{usernames.join(', ')}"
    end
  end # handle_direct_message(input)

  def parse_direct_message(input)
    return [$1, $2] if input =~ DM_REGEXP
  end # parse_direct_message(input)


  #
  # Commands handling
  #

  def command?(input)
    input =~ /(exit|status)$/i
  end # command?(input)

  def handle_command(cmd)
    case cmd
    when /exit$/i   then self.close_connection
    when /status$/i then self.send_line("[chat server] It's #{Time.now.strftime('%H:%M')} and there are #{self.number_of_connected_clients} people in the room")
    end
  end # handle_command(cmd)


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

  def announce(msg = nil, prefix = "[chat server]")
    if msg.present?
      other_peers.each do |client|
        client.send_line(user_message(self.user, msg))
      end
      self.send_line(feedback_message(msg))
    end
  end # announce(msg)

  def number_of_connected_clients
    @@connected_clients.size
  end # number_of_connected_clients

  def other_peers
    @@connected_clients.reject { |c| self == c }
  end # other_peers

  def send_line(line)
    self.send_data("#{line}\n")
  end # send_line(line)

  def usernames
    @@connected_clients.map { |c| c.username }
  end # usernames

  def self.get_clients
    @@connected_clients
  end
end
