class Muby::CommandHandler
  @@commands = {}

  def self.dispatch_command(client, command_name, arguments)
    command = @@commands[command_name]

    if command.present?
      command.execute(client, arguments)
    else
      client.send_line('Command `' + command_name.to_s + '` not found. Type `help` for a list of commands.')
    end
  end

  def self.register_command(command)
    @@commands[command.name] = command
  end

  def self.available_commands
    @@commands.sort.to_h
  end
end
