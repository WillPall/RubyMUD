class Command::Goto < Command
  def execute(client, arguments)
    subject, arguments = arguments.split(' ', 2)
    destination = nil

    if subject.blank? || arguments.blank?
      client.send_line('Enter "room <ID>" or "user <ID|Username|Name>" to go to')
      return
    end

    subject = subject.downcase.to_sym

    case subject
    when :room
      begin
        destination = Room.find(arguments)
      rescue
        client.send_line("No room found with ID \"#{arguments}\"")
        return
      end
    when :user
      if User.where(id: arguments, online: true).present?
        destination = User.where(id: arguments, online: true).first.room
      elsif User.where(username: arguments, online: true).present?
        destination = User.where(username: arguments, online: true).first.room
      elsif User.where(name: arguments, online: true).present?
        destination = User.where(name: arguments, online: true).first.room
      end
      
      if destination.blank?
        client.send_line("No user found relating to \"#{arguments}\"")
        return
      end
    else
      client.send_line("\"#{subject}\" must be \"room\" or \"user\"")
      return
    end

    client.user.room = destination
    client.user.save
    client.send_line(client.user.room.render)
  end

  private

  def setup_attributes
    is_admin_command!
    requires_full_name!

    @description = 'Teleport to a room or player based on ID or name'
  end
end
