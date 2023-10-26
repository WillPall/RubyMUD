class ServerCommandHandler < EM::Connection
  def receive_data(data)
    # TODO: for some reason, a binding.pry in here will cause EventMachine to stop accepting commands from clients. it's
    # probably not necessary to fix this since we have a REPL implemented, but still confusing
    command, arguments = data.strip.split(' ', 2)

    # TODO: these should probably be moved out into a set of commands like we have with the normal client commands
    case command
    when 'shutdown'
      if arguments == 'now'
        EventMachine.stop
      else
        # TODO: make this prettier, and make sure we can't have multiple shutdowns happening at the same time
        RubyMUD.send_to_clients(Paint['The game is going down for maintenance in 30 seconds', :yellow])
        EventMachine.add_timer(30) do
          EventMachine.stop
        end
      end
    when 'players'
      table_print_format = "%-10s\t%-10s\t%-12s\t%-16s\n"

      printf(table_print_format, 'User ID', 'Username', 'Player Name', 'Connection ID')

      RubyMUD.connected_clients.each do |client|
        printf(table_print_format, client.user.id, client.user.username, client.user.name, 'not implemented')
      end
    when 'console'
      puts Paint["**EXPERIMENTAL FEATURE**\nNOTE: This is a blocking console and will not allow the server to respond to clients until exited with `exit` or `quit`", :yellow, :bright]

      repl = Repl.new
      repl.start
    end
  end
end
