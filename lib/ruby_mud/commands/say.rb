class Commands::Say < Commands::Command
  def execute(client, arguments)
    RubyMUD.send_to_users("#{Paint["#{client.user.name} says:", :green]} #{arguments.strip}", client.user.room_users)
    client.send_line("#{Paint['you say:', :yellow]} #{arguments.strip}")
  end

  private

  def setup_attributes
    @description = 'Send a chat message to all users in the current room'
  end
end
