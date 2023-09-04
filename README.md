# RubyMUD

A Ruby MUD/MUSH/MUx engine currently part of a hobby project.

## Features

* Uses a simple SQLite DB by default to handle storage of user accounts and state, with the option to use Postgres instead.
* Allows users to login and create a username and password
* Currently loads a basic world based off a png in the assets folder
* Supports commands such as directions, and basic chat

## Getting Started

1. Ensure you're using ruby 3.2.2 or later, and `bundle install``
1. Run `rake db:setup` to create the database with necessary empty structure
1. Run `ruby_mud.rb` from the parent directory
1. You should be able to `telnet localhost 2019` to connect to the server

## Postgres Setup

If you'd prefer to use Postgres as the database, you'll need to make the following changes and requirements:

* Postgres (tested on 12.x, but should work on older versions)
* A `ruby_mud` Postgres user with the ability to create a database
* Update `Gemfile`, `config/database.yml`, and `config/ruby_mud.yml` to use Postgres, following the comment directions in those files

See `config/database.yml` for defaults or to set different options.

## TODO (i.e. very next on the list)

1. Basic inventory and ability to manage equiptment
1. Something to fight! What's the point of an RPG with nothing to do?
1. NPCs
1. Places for NPCs to show up (cities, towns, roads, etc.)
1. Procedular generation for the world itself
1. Procedular generation for general world text for biomes (stretch goal)
1. World editor (either in-game or with a utility application)

## License

This software is licensed under the permissive MIT License
