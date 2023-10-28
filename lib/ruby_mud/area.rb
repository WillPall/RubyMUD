# A collection of rooms
class Area < ActiveRecord::Base
  has_many :rooms, class_name: 'Rooms::Room'
  belongs_to :starting_room, class_name: 'Rooms::Room'

  # Return a two-dimensional array of all the rooms in this area. Will be `nil` for any room that doesn't exist in that
  # x/y position.
  def map(horizontal_radius: 10000, vertical_radius: 10000, starting_room: nil, padding: 0)
    # TODO: grabbing a random room to just start the breadth-fill from. could definitely make this smarter
    if starting_room.blank?
      starting_room = Rooms::Room.find(self.rooms.pluck(:id).sample)
    end
    map = [[]]
    min_x = self.rooms.where('x >= ?', starting_room.x - horizontal_radius).minimum(:x)
    min_y = self.rooms.where('y >= ?', starting_room.y - vertical_radius).minimum(:y)
    max_x = self.rooms.where('x <= ?', starting_room.x + horizontal_radius).maximum(:x)
    max_y = self.rooms.where('y <= ?', starting_room.y + vertical_radius).maximum(:y)

    map_x = 0
    map_y = 0
    (min_y..max_y).each do |y|
      # TODO: probably a better way to add the padding here, but it's used rarely (e.g. editor)
      padding.times do |i|
        map[map_y].insert(0, nil)
        map_x += 1
      end

      (min_x..max_x).each do |x|
        map[map_y][map_x] = rooms.where(x: x, y: y).first
        map_x += 1
      end

      padding.times do |i|
        map[map_y].push(nil)
      end

      map.push([])
      map_y += 1
      map_x = 0
    end

    # add padding
    padding.times do |i|
      map.insert(0, [nil] * map[0].length)
      map.push([nil] * map[0].length)
    end

    map
  end
end
