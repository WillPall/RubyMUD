namespace :db do
  RubyMUD.initialize
  db_config = YAML.load(File.open('config/database.yml'))
  db_config_admin_postgres = db_config.merge({'database' => 'postgres', 'schema_search_path' => 'public'})

  desc 'Create the database'
  task :create do
    if RubyMUD.config[:database] == 'postgresql'
      ActiveRecord::Base.establish_connection(db_config_admin_postgres)
      ActiveRecord::Base.connection.create_database(db_config['database'])
    else
      `sqlite3 #{db_config['database']} "VACUUM;"`
    end
    puts 'Database created.'
  end

  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::MigrationContext.new('db/migrate/').migrate
    Rake::Task['db:schema'].invoke
    puts 'Database migrated.'
  end

  desc 'Drop the database'
  task :drop do
    if RubyMUD.config[:database] == 'postgresql'
      ActiveRecord::Base.establish_connection(db_config_admin_postgres)
      ActiveRecord::Base.connection.drop_database(db_config['database'])
    else
      `rm #{db_config['database']}`
    end
    puts 'Database deleted.'
  end

  desc 'Seed the database'
  task :seed do
    ActiveRecord::Base.establish_connection(db_config)
    require File.join(__dir__, '../../db', 'seeds.rb')
    puts 'Database seeded.'
  end

  desc 'Reset the database'
  task reset: [:drop, :create, :migrate, :seed]

  desc 'Setup the initial database'
  task setup: [:create, :migrate, :seed]

  desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  task :schema do
    ActiveRecord::Base.establish_connection(db_config)
    require 'active_record/schema_dumper'
    filename = 'db/schema.rb'
    File.open(filename, 'w:utf-8') do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end

  desc 'Roll the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.migration_context.rollback(step)

    Rake::Task['db:schema'].invoke
  end
end

namespace :g do
  desc 'Generate migration'
  task :migration do
    name = ARGV[1] || raise('Specify name: rake g:migration your_migration')
    name = name.underscore
    timestamp = Time.now.strftime('%Y%m%d%H%M')
    # TODO: make rake use a root project directory rather than these relative ones
    path = File.expand_path("../../../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split('_').map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<-EOF
class #{migration_class} < ActiveRecord::Migration[7.0]
  def change
  end
end
EOF
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end
