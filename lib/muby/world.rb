class Muby::World
  attr_accessor :rooms

  def initialize
    self.rooms = load_rooms
  end

  private

  def load_rooms
    Muby::Room.order(:x, :y)
  end
end
