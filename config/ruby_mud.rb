require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'active_record'

Bundler.require(:default)

# TODO: we have to load the main classes/modules first before loading the rest
# there's got to be a better way to do this
# TODO: make sure this syntax and usage is the best (e.g. why use join instead of expand_path?)
Dir[File.join(__dir__, '../lib', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../lib', 'ruby_mud/concerns/*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../lib', 'ruby_mud/*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../lib', '**/*.rb')].each { |file| require file }

module RubyMUD
  class << self
    def initialize
      # @@secrets = YAML.load(File.open('config/secrets.yml'))
      @@config = {
        # Set whether to use SQLite or Postgres. Defaults to SQLite
        # Change to "postgresql" to use Postgres as the DB engine.
        database_engine: 'sqlite3',
        hostname: '0.0.0.0',
        port: 34119
      }

      @@connected_clients = Array.new
    end

    def config
      @@config
    end

    # TODO: load secrets and require a secrets.yml once we actually need them (if ever)
    # def secrets
    #   @@secrets ||= YAML.load(File.open('config/secrets.yml'))
    # end

    def number_of_connected_clients
      @@connected_clients.count
    end

    # sends a message to the provided clients. defaults to all connected clients if no clients are specified
    def send_to_clients(message, clients = nil)
      clients ||= @@connected_clients
  
      clients.each do |client|
        client.send_line(message)
      end
    end
  
    def send_to_users(message, users)
      users.each do |user|
        # TODO: this is extremely gross, but because we're using ActiveRecord
        # relations, when you load certain things, they don't contain their
        # instance variables anymore. For now, we'll just find the client that
        # matches each user
        find_client_by_user(user).send_line(message)
      end
    end
  
    def connected_clients
      @@connected_clients
    end

    def add_client(client)
      @@connected_clients.push(client)
    end

    def remove_client(client)
      @@connected_clients.delete(client)
    end
  
    private
  
    def find_client_by_user(user)
      @@connected_clients.each do |client|
        if client.user.id == user.id
          return client
        end
      end
  
      nil
    end
  end
end
