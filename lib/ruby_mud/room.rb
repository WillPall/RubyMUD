class Room < ActiveRecord::Base
  include ItemHolder

  has_many :users
  has_many :connections
  has_many :destinations, through: :connections
  belongs_to :world

  def render
    output = map_view
    output += "\n" + Paint[self.title, :yellow] + "\n"
    output += self.description + "\n"

    if items.present?
      output += 'Items: '

      items.each do |item|
        output += "\t#{item.name}\n"
      end
    end

    if self.connections.present?
      output += 'Exits: '

      self.connections.each do |connection|
        output += "#{Paint[connection.name, :green]} "
      end
    end

    output
  end

  def title
    self[:title] || DEFAULT_TITLES[self.room_type.to_sym]
  end

  def description
    self[:description] || DEFAULT_DESCRIPTIONS[self.room_type.to_sym]
  end

  def online_users
    users.where(online: true)
  end

  def self.map_representation(room = nil)
    if room.present?
      Paint['#', COLOR_MAPPING[room.room_type.to_sym][0], COLOR_MAPPING[room.room_type.to_sym][1]]
    else
      print Paint['*', :red, :bright]
    end
  end

  protected

  def room_at_distance(distance, direction)
    final_room = self
    distance.times do |i|
      connection = final_room.connections.where(name: direction).first

      if connection.present?
        final_room = final_room.connections.where(name: direction).first.destination
      else
        return nil
      end
    end

    final_room
  end

  private

  DEFAULT_TITLES = {
    water: 'Deep Water',
    grass: 'Grassy Plain',
    sand: 'Sandy Beach',
    forest: 'Dense Forest',
    road: 'Road'
  }

  DEFAULT_DESCRIPTIONS = {
    water: "You're in the middle of a deep pool of water",
    grass: 'Waves of grass and wheat surround you',
    sand: 'The sand crunches between your toes',
    forest: 'The trees whisper in the wind around you',
    road: 'This road leads to Rome'
  }

  COLOR_MAPPING = {
    water: [:blue],
    grass: [:green, :bright],
    sand: [:yellow, :bright],
    forest: [:green],
    road: [:yellow]
  }

  def map_view(horizontal_radius = 6, vertical_radius = 3)
    map = []
    fill_adjacent(self, map, horizontal_radius, vertical_radius, horizontal_radius * 2 + 1, vertical_radius * 2 + 1)

    output = ''

    map.each_with_index do |row, y|
      row.each_with_index do |room, x|
        if room.id == self.id
          output += Paint['&', :white, :bright]
        else
          output += Room.map_representation(room)
        end
      end

      output += "\n"
    end

    output
  end

  def fill_adjacent(room, map, x, y, width, height)
    if map[y].blank?
      map[y] = []
    end

    map[y][x] = room

    if room.present?
      # TODO: this needs to become much more performant. something in here is
      # slowing things down massively. I'm assuming it's the AR queries for
      # each room and connection
      #
      # Example benchmark from render (seconds): Map: 0.27679 - Other: 0.000608
      north = room.connections.where(name: 'north').first
      south = room.connections.where(name: 'south').first
      east = room.connections.where(name: 'east').first
      west = room.connections.where(name: 'west').first

      if north.present?
        add_room_to_map(north.destination, map, x, y - 1, width, height)
      end
      if south.present?
        add_room_to_map(south.destination, map, x, y + 1, width, height)
      end
      if east.present?
        add_room_to_map(east.destination, map, x + 1, y, width, height)
      end
      if west.present?
        add_room_to_map(west.destination, map, x - 1, y, width, height)
      end
    end
  end

  def add_room_to_map(room, map, x, y, width, height)
    if map[y].blank?
      map[y] = []
    end

    if map[y][x].present?
      return
    end

    if x >= 0 && x < width && y >= 0 && y < height
      map[y][x] = room
      fill_adjacent(room, map, x, y, width, height)
    end
  end
end
