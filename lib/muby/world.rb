class Muby::World
  attr_accessor :rooms

  def initialize
    Muby::Room.destroy_all

    Muby::World::ImageLoader.load
    # self.rooms = load_rooms
  end

  private

  def load_rooms
    Muby::Room.order(:x, :y)
  end
end
