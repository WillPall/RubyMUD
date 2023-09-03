class Muby::Command::Sudo < Muby::Command
  def initialize
    super

    is_special_type!
    requires_full_name!

    self.name = :sudo
    self.description = 'Execute admin commands (only available to admins)'
  end

  def execute(client, arguments)
    # TODO: make this role-based
    if client.user.username == 'will'
      command, arguments = arguments.split(' ', 2)
      if command.present?
        command = command.downcase.to_sym

        case command
        when :room_id
          client.send_line(client.user.room.id)
        when :users
          client.send_line(client.user.room.online_users.pluck(:username).join(', '))
        end
      else
        client.send_line('Do not recognize that `sudo` command')
      end
    else
      client.send_line('You cannot do that')
    end
  end
end

Muby::CommandHandler.register_command(Muby::Command::Sudo.new)
