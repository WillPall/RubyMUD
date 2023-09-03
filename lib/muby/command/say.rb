class Muby::Command::Say < Muby::Command
  def initialize
    self.name = :say
    self.description = 'Send a chat message to all users in the current room'
  end

  def execute(client, arguments)
    client.handle_chat_message(arguments)
  end
end

Muby::CommandHandler.register_command(Muby::Command::Say.new)
