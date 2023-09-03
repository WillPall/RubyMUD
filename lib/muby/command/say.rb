class Muby::Command::Say < Muby::Command
  def initialize
    super

    self.name = :say
    self.description = 'Send a chat message to all users in the current room'
  end

  def execute(client, arguments)
    client.send_to_users(Muby::MessageHelper.user_message(client.user, arguments), client.user.room_users)
    client.send_line(Muby::MessageHelper.feedback_message(arguments))
  end
end

Muby::CommandHandler.register_command(Muby::Command::Say.new)
