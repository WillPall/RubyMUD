class Muby::Command::Yell < Muby::Command
  def initialize
    self.name = :yell
    self.description = 'Send a chat message to all users on the server'
  end

  def execute(client, arguments)
    client.send_to_clients(Muby::MessageHelper.user_message(client.user, arguments, :magenta), Muby::ConnectionHelper.other_peers(client))
    client.send_line(Muby::MessageHelper.feedback_message(arguments))
  end
end

Muby::CommandHandler.register_command(Muby::Command::Yell.new)
