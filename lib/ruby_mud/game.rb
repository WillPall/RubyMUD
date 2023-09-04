class Game
  # number of seconds between each "tick"
  TICK_INTERVAL = 5

  def initialize
    @last_tick = Time.now.to_f * 1000

    prepare_game_state
    create_world
  end

  # TODO: EventMachine doesn't give any guarantees around timing. It will be
  # _at least_ as long as asked for, but is usually longer. This will
  # eventually need to be synced for things that take a long amount of time to
  # run
  def tick
    # run any updates needed

    # we put this in a thread so that long running things can be done in the
    # background without blocking EventMachine's timer
    # Thread.new do
    #   puts "Connected users: "
    #   Connection.get_clients.each do |client|
    #     puts "\t#{client.user.name}"
    #   end
    # end


    @last_tick = Time.now.to_f

    # TODO: BIG TODO: All the `.save` on all these model records (e.g. user,
    # room, etc) need to be moved to a periodic save_all kind of thing, as well
    # as saving on player leave
  end

  private

  # ensure that the game is in a good state on startup
  # TODO: probably want an actual table that has info about the overall game
  # state, such as whether it had a clean shutdown, what was running at the
  # time, etc.
  def prepare_game_state
    # if the server is killed or crashes, user information may be in a bad
    # state, so clean that up
    User.all.update_all(online: false)
  end

  # TODO: this is just a placeholder for testing. Replace with something more
  # data-driven later
  def create_world
    @@world = World.new


    # roomw = Room.create(
    #   title: 'North Room',
    #   description: 'This is the room to the north of the +'
    # )
    # rooma = Room.create(
    #   title: 'West Room',
    #   description: 'This is the room to the west of the +'
    # )
    # rooms = Room.create(
    #   title: 'Middle Room',
    #   description: 'This is the room in the middle of the +'
    # )
    # roomd = Room.create(
    #   title: 'East Room',
    #   description: 'This is the room to the east of the +'
    # )
    # roomx = Room.create(
    #   title: 'South Room',
    #   description: 'This is the room to the south of the +'
    # )

    # # NORTH
    # Room::Connection.create(
    #   room: roomw,
    #   destination: rooms,
    #   name: 'south'
    # )
    # # MIDDLE
    # Room::Connection.create(
    #   room: rooms,
    #   destination: roomw,
    #   name: 'north'
    # )
    # Room::Connection.create(
    #   room: rooms,
    #   destination: rooma,
    #   name: 'west'
    # )
    # Room::Connection.create(
    #   room: rooms,
    #   destination: roomx,
    #   name: 'south'
    # )
    # Room::Connection.create(
    #   room: rooms,
    #   destination: roomd,
    #   name: 'east'
    # )
    # # WEST
    # Room::Connection.create(
    #   room: rooma,
    #   destination: rooms,
    #   name: 'east'
    # )
    # # EAST
    # Room::Connection.create(
    #   room: roomd,
    #   destination: rooms,
    #   name: 'west'
    # )
    # # SOUTH
    # Room::Connection.create(
    #   room: roomx,
    #   destination: rooms,
    #   name: 'north'
    # )
  end

  def self.get_world
    @@world
  end
end
