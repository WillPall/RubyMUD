class Game
  # number of seconds between each "tick"
  TICK_INTERVAL = 5

  def initialize
    @last_tick = Time.now.to_f * 1000

    initialize_commands
    prepare_game_state
    load_world
  end

  # TODO: EventMachine doesn't give any guarantees around timing. It will be
  # _at least_ as long as asked for, but is usually longer. This will
  # eventually need to be synced for things that take a long amount of time to
  # run
  def tick
    @last_tick = Time.now.to_f

    # TODO: BIG TODO: All the `.save` on all these model records (e.g. user,
    # room, etc) need to be moved to a periodic save_all kind of thing, as well
    # as saving on player leave
  end

  private

  # Instantiates and registers all commands that are subclasses of `Command`
  def initialize_commands
    Command.descendants.each do |command|
      CommandHandler.register_command(command.new)
    end
  end

  # ensure that the game is in a good state on startup
  # TODO: probably want an actual table that has info about the overall game
  # state, such as whether it had a clean shutdown, what was running at the
  # time, etc.
  def prepare_game_state
    # if the server is killed or crashes, user information may be in a bad
    # state, so clean that up
    User.all.update_all(online: false)
  end

  # Loads the first existing world, or creates one based on the default world image file if it doesn't exist
  def load_world
    if World.none?
      @@world = World.new
      World::ImageLoader.load(@@world)
      @@world.save
    else
      @@world = World.first
    end
  end

  def self.get_world
    @@world
  end
end
