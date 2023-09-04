class Command::Quit < Command
  def initialize
    super

    self.name = :quit
    self.description = 'Save and leave the server'
    self.requires_full_name = true
  end

  def execute(client, arguments)
    # TODO: complete save of character
    client.user.save
    client.close_connection
    # binding.pry
  end
end

CommandHandler.register_command(Command::Quit.new)
