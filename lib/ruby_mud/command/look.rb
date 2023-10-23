class Command::Look < Command
  def execute(client, arguments)
    client.send_line(client.user.room.render_for(client.user))
  end

  private

  def setup_attributes
    @description = 'Shows information about your current location'
  end
end
