class Command::RoomInfo < Command
  def execute(client, arguments)
    room = client.user.room

    if arguments.present?
      begin
        room = Room.find(arguments)
      rescue
        client.send_line("No room with ID \"#{arguments}\"")
        return
      end
    end

    client.send_line(Paint['Room ID:', :green] + room.id.to_s)
    client.send_line(Paint['Rendered:', :green])
    client.send_line(room.render)
  end

  private

  def setup_attributes
    is_admin_command!

    @description = 'Get all info about room - add room ID for room other than current'
  end
end
