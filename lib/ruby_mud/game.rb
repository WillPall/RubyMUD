class Game
  # number of seconds between each "tick"
  TICK_INTERVAL = 0.01

  def initialize
    @last_tick = Time.now
    @updateables = []

    initialize_commands
  end

  # TODO: EventMachine doesn't give any guarantees around timing. It will be
  # _at least_ as long as asked for, but is usually longer. This will
  # eventually need to be synced for things that take a long amount of time to
  # run
  def tick
    @elapsed_time = Time.now - @last_tick
    @last_tick = Time.now

    @updateables.each do |u|
      u.update(@elapsed_time)
    end
  end

  def register_updateable(updateable)
    @updateables << updateable
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

  private

  # Instantiates and registers all commands that are subclasses of `Command`
  def initialize_commands
    Command.descendants.each do |command|
      CommandHandler.register_command(command.new)
    end
  end

  def self.get_world
    @@world
  end
end
