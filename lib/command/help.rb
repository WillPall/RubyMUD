class Command::Help < Command
  def initialize
    super

    self.name = :help
    self.description = 'Lists all available commands'
  end

  def execute(client, arguments)
    client.send_line('Available commands:')
    CommandHandler.available_commands.each do |k, command|
      client.send_line("\t#{command.name} - #{command.description}")
    end
  end
end

CommandHandler.register_command(Command::Help.new)
