class Muby::CommandHandler
  @@commands = {}

  class << self
    def is_command?(command)
      @@commands[command].present?
    end

    def dispatch_command(client, command, arguments)
      @@commands[command].execute(client, arguments)
    end

    def register_command(command)
      @@commands[command.name] = command
    end

    def available_commands
      @@commands.sort.to_h
    end
  end
end
