# RubyMUD

A Ruby MUD/MUSH/MUx engine currently part of a hobby project.

## Features

* Uses a simple SQLite DB by default to handle storage of user accounts and state, with the option to use Postgres instead.
* Allows users to login and create a username and password
* Currently loads a basic world based off a png in the assets folder
* Supports commands such as directions, and basic chat

## Getting Started

1. Ensure you're using ruby 3.2.2 or later, and `bundle install`
1. Run `rake db:setup` to create the database with an admin user
1. Run `./ruby_mud.rb` from the parent directory
1. You should be able to `telnet localhost 34119` to connect to the server

### Default Admin User

A default user is created with the username `admin` and password `admin` that can be used to log in as a superuser.

## Postgres Setup

If you'd prefer to use Postgres as the database, you'll need to make the following changes and requirements:

* Postgres (tested on 12.x, but should work on older versions)
* A `ruby_mud` Postgres user with the ability to create a database
* Update `Gemfile`, `config/database.yml`, and `config/ruby_mud.rb` to use Postgres, following the comment directions in those files

See `config/database.yml` for defaults or to set different options.

## Rake Tasks

* `db:create`, `db:migrate`, `db:drop`, `db:seed` - all similar to commands for those familiar with Rails
* `db:setup` - creates, migrates, and seeds the DB
* `db:reset` - drops and then sets up the DB
* `g:migration [file name]` - creates a blank ActiveRecord migration with the given filename in the `db/migrate` directory

## World Editor

RubyMUD comes with a browser-based world editor. This editor uses Sinatra and is available at http://localhost:34911/.

### Running the Editor

1. Perform the Getting Started steps above and run `ruby_mud.rb` once to import the initial world image
1. Run `editor.rb`
1. Visit http://localhost:34911/ in your browser to view and edit the world

### Features

* View the main "overworld" area
* Add, edit, and delete rooms in the overworld

### Missing Features

* Support for multiple areas
* Support for adding room connections other than N/S/E/W
* Support for item and mob management

## TODO (i.e. very next on the list)

1. Ability to manage equiptment
1. Something to fight! What's the point of an RPG with nothing to do?
1. Combat
1. NPCs
1. Places for NPCs to show up (cities, towns, roads, etc.)
1. Procedural generation for the world itself (stretch goal)
1. Procedural generation for general world text for biomes (stretch goal)

## License

This software is licensed under the permissive MIT License
