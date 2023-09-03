class Muby::Game
  # number of seconds between each "tick"
  TICK_INTERVAL = 5

  def initialize
    @last_tick = Time.now.to_f * 1000

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
    #   Muby::Connection.get_clients.each do |client|
    #     puts "\t#{client.user.name}"
    #   end
    # end


    @last_tick = Time.now.to_f
  end

  private

  # TODO: this is just a placeholder for testing. Replace with something more
  # data-driven later
  def create_world
    Muby::Room.destroy_all

    roomw = Muby::Room.create(
      title: 'North Room',
      description: 'This is the room to the north of the +'
    )
    rooma = Muby::Room.create(
      title: 'West Room',
      description: 'This is the room to the west of the +'
    )
    rooms = Muby::Room.create(
      title: 'Middle Room',
      description: 'This is the room in the middle of the +'
    )
    roomd = Muby::Room.create(
      title: 'East Room',
      description: 'This is the room to the east of the +'
    )
    roomx = Muby::Room.create(
      title: 'South Room',
      description: 'This is the room to the south of the +'
    )

    # NORTH
    Muby::Room::Connection.create(
      room: roomw,
      destination: rooms,
      name: 'south'
    )
    # MIDDLE
    Muby::Room::Connection.create(
      room: rooms,
      destination: roomw,
      name: 'north'
    )
    Muby::Room::Connection.create(
      room: rooms,
      destination: rooma,
      name: 'west'
    )
    Muby::Room::Connection.create(
      room: rooms,
      destination: roomx,
      name: 'south'
    )
    Muby::Room::Connection.create(
      room: rooms,
      destination: roomd,
      name: 'east'
    )
    # WEST
    Muby::Room::Connection.create(
      room: rooma,
      destination: rooms,
      name: 'east'
    )
    # EAST
    Muby::Room::Connection.create(
      room: roomd,
      destination: rooms,
      name: 'west'
    )
    # SOUTH
    Muby::Room::Connection.create(
      room: roomx,
      destination: rooms,
      name: 'north'
    )
  end
end
