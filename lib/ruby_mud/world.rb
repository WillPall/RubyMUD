class World < ActiveRecord::Base
  has_many :rooms
  belongs_to :starting_room, class_name: 'Room'

  private

  def load_rooms
    rooms.order(:x, :y)
  end
end
