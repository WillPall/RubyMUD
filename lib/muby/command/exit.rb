class Muby::Command::Exit < Muby::Command
  def initialize
    self.name = :exit
    self.description = 'Leave the server'
  end

  def execute(client, arguments)
    client.close_connection
  end
end

Muby::CommandHandler.register_command(Muby::Command::Exit.new)
