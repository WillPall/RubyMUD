class Command::Help < Command
  def execute(client, arguments)
    client.send_line('Available commands:')
    CommandHandler.available_commands(client.user).each do |k, command|
      client.send_line("\t#{command.name} - #{command.description}")
    end
  end

  private

  def setup_attributes
    @description = 'Lists all available commands'
  end
end
