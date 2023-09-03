#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'active_record'

Bundler.require(:default)

# TODO: Actually implement the persistent DB in SQLite with AR, migrations,
# schema, etc.
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Set up database tables and columns
ActiveRecord::Schema.define do
  create_table :muby_users, force: true do |t|
    t.string :username
    t.string :name
    t.string :password
  end
end

# TODO: we have to load the main classes/modules first before loading the rest
# there's got to be a better way to do this
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'lib', '**/*.rb')].each { |file| require file }

EventMachine.run do
  # hit Control + C to stop
  Signal.trap('INT')  { EventMachine.stop }
  Signal.trap('TERM') { EventMachine.stop }

  game = Muby::Game.new

  # TODO: Figure out how to get this working on external servers (is it just my
  # home router?)
  EventMachine.start_server('0.0.0.0', 2019, Muby::Connection)
  EventMachine.add_periodic_timer(Muby::Game::TICK_INTERVAL) do
    game.tick
  end
end
