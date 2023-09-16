class Command::Yell < Command
  def execute(client, arguments)
    RubyMUD.send_to_clients("#{Paint["#{client.user.name} yells:", :magenta]} #{arguments.strip}", ConnectionHelper.other_peers(client))
    client.send_line("#{Paint['you yell:', :yellow]} #{arguments.strip}")
  end

  private

  def setup_attributes
    @description = 'Send a chat message to all users on the server'
  end
end
