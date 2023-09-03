class Muby::World
  attr_accessor :rooms
  attr_accessor :starting_room

  def initialize
    # need to determine if a world has been created yet. for now we'll assume
    # if any rooms exist, then the world exists.
    if Muby::Room.none?
      # TODO move starting room out of world load
      self.starting_room = Muby::World::ImageLoader.load
    else
      # TODO: if we already have some rooms, just pick a random starter. this
      # is super slow and makes no sense anyway, but is for testing
      self.starting_room = Muby::Room.offset(rand(Muby::Room.count)).first
    end

    # TODO these were there at some point to clear the world on startup, but we
    # don't want that right now. can move that to somewhere else for new worlds
    # or adding things to worlds
    # Muby::Room.delete_all
    # Muby::Room::Connection.delete_all

    # TODO: don't know what this is. maybe an attemp to move the player to a
    # generally correct location if their old room got deleted?
    # self.rooms = load_rooms
  end

  private

  def load_rooms
    Muby::Room.order(:x, :y)
  end
end
