class Muby::Command::Yell < Muby::Command
  def initialize
    super

    self.name = :yell
    self.description = 'Send a chat message to all users on the server'
  end

  def execute(client, arguments)
    client.send_to_clients("#{Paint["#{client.user.name} yells:", :magenta]} #{arguments.strip}", Muby::ConnectionHelper.other_peers(client))
    client.send_line("#{Paint['you yell:', :yellow]} #{arguments.strip}")
  end
end

Muby::CommandHandler.register_command(Muby::Command::Yell.new)
