class Muby::CommandHandler
  @@commands = {}

  class << self
    ##
    # Handles the command. Yeah, very inventive. TODO: maybe come up with something smarter on all this naming
    def handle_command(client, data)
      # let's get the command itself, then let the args be their own string. might need to split those up again further
      command_request, arguments = data.split(' ', 2)

      # TODO: all this command stuff here needs to be delegated out of a giant if/else. half of the stuff here has
      # nothing to do with a user, real command, really anything
      if command_request.present?
        command_request = command_request.downcase.to_sym
        possible_commands = possible_commands(command_request)

        if possible_commands.count == 1
          # this is an abbreviated request for something that requires the full name
          if possible_commands.first.requires_full_name && possible_commands.first.name != command_request
            client.send_line("Please type the full command for \"#{possible_commands.first.name}\" to confirm")
          else
            Muby::CommandHandler.dispatch_command(client, possible_commands.first, arguments)
          end
        elsif possible_commands.count > 1
          client.send_line("There are multiple commands that match your request:")
          possible_commands.each do |c|
            client.send_line("\t#{c.name}")
          end
        # TODO: this one should be moved to the direction/destination command?
        elsif client.user.can_move?(command_request)
          client.user.move_to(command_request)
        else
          client.send_line('Command `' + command_request.to_s + '` not found. Type `help` for a list of commands.')
        end
      else
        client.send_line(client.user.prompt)
      end
    end

    ##
    # Bare-bones helper method to make sure that a command has been registered
    def is_command?(command_request)
      @@commands[command_request].present?
    end

    ##
    # Return all the possible commands that could match a given command
    def possible_commands(command_request)
      possible_commands = []

      # if it's an exact match, go ahead and return that. this prevents issues where the user types "say" and there
      # are two commands named "say" and "say_something_more" for example
      if is_command?(command_request)
        return [@@commands[command_request]]
      end

      @@commands.values.each do |c|
        if c.name.to_s.start_with?(command_request.to_s)
          possible_commands << c
        end
      end

      possible_commands
    end

    ##
    # Wrapper called by the client, which command, and any arguments that will pass that information along to the
    # desired command's execute method.
    def dispatch_command(client, command, arguments)
      command.execute(client, arguments)
    end

    ##
    # Very basic method that adds a command to the list of commands by its name. This must be called in every command
    # definition, or those commands won't exist for use.
    def register_command(command)
      @@commands[command.name] = command
    end

    ##
    # Return a list of all available commands as a hash with the command as key and command objects as the values.
    #
    # `include_special` defaults to false and indicates whether the "special" commands should be included in the list.
    # For example, `direction` which is actually a wrapper for n/s/e/w etc, or `sudo` which isn't meant for many.
    def available_commands(include_special = false)
      commands = @@commands.sort.to_h

      if !include_special
        commands.reject! { |k,command| command.is_special_type }
      end

      commands
    end
  end
end
