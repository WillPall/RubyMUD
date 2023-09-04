class World::ImageLoader
  # Loads the world and creates the rooms and connections from the image file
  # given at `world_file`. Defaults to `assets/worlds/world.png`.
  def self.load(world_file = 'assets/worlds/world.png')
    puts 'Initializing world'
    room_rows = []
    world_image = ChunkyPNG::Image.from_file(world_file)
    starting_room = nil

    world_image.height.times do |j|
      room_row = []
      room_rows << room_row

      world_image.width.times do |i|
        if ROOM_MAPPING[ChunkyPNG::Color.to_hex(world_image[i, j], false)].to_s.blank?
          room_row << nil
          next
        end

        new_room = Room.create(
          room_type: ROOM_MAPPING[ChunkyPNG::Color.to_hex(world_image[i, j], false)].to_s
        )
        room_row << new_room

        if j == (world_image.height / 2).to_i && i == (world_image.width / 2).to_i
          # TODO: this is just for testing and moving users to the middle.
          # change this later to be a real starting room
          starting_room = new_room
        end
      end
    end

    room_rows.each_with_index do |row, y|
      row.each_with_index do |room, x|
        # NORTH
        if room_rows[y - 1].present? && room_rows[y - 1][x].present?
          Room::Connection.create(
            room: room,
            destination: room_rows[y - 1][x],
            name: 'north'
          )
        end
        # SOUTH
        if room_rows[y + 1].present? && room_rows[y + 1][x].present?
          Room::Connection.create(
            room: room,
            destination: room_rows[y + 1][x],
            name: 'south'
          )
        end
        # EAST
        if room_rows[y].present? && room_rows[y][x + 1].present?
          Room::Connection.create(
            room: room,
            destination: room_rows[y][x + 1],
            name: 'east'
          )
        end
        # WEST
        if room_rows[y].present? && room_rows[y][x - 1].present?
          Room::Connection.create(
            room: room,
            destination: room_rows[y][x - 1],
            name: 'west'
          )
        end
      end
    end

    starting_room
  end

  ROOM_MAPPING = {
    '#0000ff' => :water,
    '#00ff00' => :grass,
    '#ffff00' => :sand,
    '#329632' => :forest,
    '#aaaa00' => :road
  }.freeze
end