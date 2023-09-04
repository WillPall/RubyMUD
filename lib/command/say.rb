class Command::Say < Command
  def initialize
    super

    self.name = :say
    self.description = 'Send a chat message to all users in the current room'
  end

  def execute(client, arguments)
    client.send_to_users("#{Paint["#{client.user.name} says:", :green]} #{arguments.strip}", client.user.room_users)
    client.send_line("#{Paint['you say:', :yellow]} #{arguments.strip}")
  end
end

CommandHandler.register_command(Command::Say.new)