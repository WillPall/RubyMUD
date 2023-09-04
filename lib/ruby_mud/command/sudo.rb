class Command::Sudo < Command
  def initialize
    super

    is_special_type!
    requires_full_name!

    self.name = :sudo
    self.description = 'Execute admin commands (room_id, users)'
  end

  def execute(client, arguments)
    command, arguments = arguments.split(' ', 2)

    if command.present?
      command = command.downcase.to_sym

      # TODO: will make these real commands when we have some that are more useful
      case command
      when :room_id
        client.send_line(client.user.room.id)
      when :users
        client.send_line(client.user.room.online_users.pluck(:username).join('\n\t'))
      end
    else
      client.send_line('Do not recognize that `sudo` command')
    end
  end
end

CommandHandler.register_command(Command::Sudo.new)
