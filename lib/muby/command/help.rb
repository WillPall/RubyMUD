class Muby::Command::Help < Muby::Command
  def initialize
    self.name = :help
    self.description = 'Lists all available commands'
  end

  def execute(client, arguments)
    client.send_line('Available commands:')
    Muby::CommandHandler.available_commands.each do |k, command|
      client.send_line("\t#{command.name} - #{command.description}")
    end
  end
end

Muby::CommandHandler.register_command(Muby::Command::Help.new)
