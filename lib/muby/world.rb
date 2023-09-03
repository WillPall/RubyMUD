class Muby::World
  attr_accessor :rooms
  attr_accessor :starting_room

  def initialize
    Muby::Room.delete_all
    Muby::Room::Connection.delete_all

    self.starting_room = Muby::World::ImageLoader.load
    # self.rooms = load_rooms
  end

  private

  def load_rooms
    Muby::Room.order(:x, :y)
  end
end
