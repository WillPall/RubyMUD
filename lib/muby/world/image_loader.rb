class Muby::World::ImageLoader
  def self.load
    room_rows = []
    world_image = ChunkyPNG::Image.from_file('assets/worlds/world.png')
    world_image.width.times do |i|
      room_row = []
      room_rows << room_row

      world_image.height.times do |j|
        if ROOM_MAPPING[ChunkyPNG::Color.to_hex(world_image[j, i], false)].to_s.blank?
          binding.pry
        end

        room_row << Muby::Room.create(
          room_type: ROOM_MAPPING[ChunkyPNG::Color.to_hex(world_image[j, i], false)].to_s
        )
      end
    end

    room_rows.each do |row|
      row.each do |room|
        begin
          print Paint['#', ROOM_COLOR_MAPPING[room.room_type.to_sym][0], ROOM_COLOR_MAPPING[room.room_type.to_sym][1]]
        rescue
          binding.pry
        end
      end
      puts
    end
  end

  ROOM_MAPPING = {
    '#0000ff' => :water,
    '#00ff00' => :grass,
    '#ffff00' => :sand,
    '#329632' => :forest,
    '#aaaa00' => :road
  }

  ROOM_COLOR_MAPPING = {
    water: [:blue],
    grass: [:green, :bright],
    sand: [:yellow, :bright],
    forest: [:green],
    road: [:yellow]
  }
end
