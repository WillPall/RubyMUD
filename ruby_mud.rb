#!/usr/bin/env ruby

require File.expand_path('../config/ruby_mud', __FILE__)

ruby_mud = RubyMUD.new

db_config = YAML.load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

# start the listening server
EventMachine.run do
  # hit Control + C to stop
  Signal.trap('INT')  { EventMachine.stop }
  Signal.trap('TERM') { EventMachine.stop }

  game = Game.new

  # TODO: Figure out how to get this working on external servers. may just be local testing issues
  EventMachine.start_server(ruby_mud.config[:hostname], ruby_mud.config[:port], Connection)
  EventMachine.add_periodic_timer(Game::TICK_INTERVAL) do
    game.tick
  end

  # attach another connection listener on stdin to handle commands given directly to the server process (e.g. through
  # the command line)
  EventMachine.attach($stdin, ServerCommandHandler)

  # TODO: make this pretty and put it somehwere else
  puts 'Server is ready for connections'
end
