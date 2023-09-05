require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'active_record'

Bundler.require(:default)

# TODO: we have to load the main classes/modules first before loading the rest
# there's got to be a better way to do this
# TODO: make sure this syntax and usage is the best (e.g. why use join instead of expand_path?)
Dir[File.join(__dir__, '../lib', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../lib', 'ruby_mud/*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../lib', '**/*.rb')].each { |file| require file }

class RubyMUD
  attr_accessor :config

  def initialize
    @@secrets = YAML.load(File.open('config/secrets.yml'))
    @config = {
      # Set whether to use SQLite or Postgres. Defaults to SQLite
      # Change to "postgresql" to use Postgres as the DB engine.
      database_engine: 'sqlite3',
      hostname: '0.0.0.0',
      port: 34119
    }
  end

  def self.secrets
    @@secrets ||= YAML.load(File.open('config/secrets.yml'))
  end
end
