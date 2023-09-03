class Muby::Game
  # number of seconds between each "tick"
  TICK_INTERVAL = 5

  def initialize
    @last_tick = Time.now.to_f * 1000

    Muby::Room.destroy_all

    roomw = Muby::Room.create
    rooma = Muby::Room.create
    rooms = Muby::Room.create
    roomd = Muby::Room.create
    roomx = Muby::Room.create

    Muby::Room::Connection.create(
      room: roomw,
      destination: rooms,
      name: 'south'
    )
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
end
