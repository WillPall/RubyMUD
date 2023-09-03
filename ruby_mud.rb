#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'active_record'

Bundler.require(:default)

# TODO: Automate pulling in schema, migrations, etc
db_config = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

# Set up database tables and columns
# ActiveRecord::Schema.define do
#   create_table :users do |t|
#     t.string :username
#     t.string :name
#     t.string :password
#     t.integer :room_id
#   end

#   create_table :rooms, force: true do |t|
#   end
# end

# TODO: we have to load the main classes/modules first before loading the rest
# there's got to be a better way to do this
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'lib', '**/*.rb')].each { |file| require file }

# start the listening server
EventMachine.run do
  # hit Control + C to stop
  Signal.trap('INT')  { EventMachine.stop }
  Signal.trap('TERM') { EventMachine.stop }

  game = Game.new

  # TODO: Figure out how to get this working on external servers (is it just my
  # home router?)
  # starts the server at localhost:2019
  EventMachine.start_server('0.0.0.0', 2019, Connection)
  EventMachine.add_periodic_timer(Game::TICK_INTERVAL) do
    game.tick
  end

  # TODO: make this pretty and put it somehwere else
  puts 'Server is ready for connections'

  # TODO: We need some sort of console/command interface from the server itself
end
