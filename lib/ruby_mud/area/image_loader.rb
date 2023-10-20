class Area::ImageLoader
  # Loads the world and creates the rooms and connections from the image file
  # given at `world_file`. Defaults to `assets/areas/world.png`.
  def self.load(area, world_file = 'assets/areas/world.png')
    puts 'Initializing world'
    room_rows = []
    world_image = ChunkyPNG::Image.from_file(world_file)

    world_image.height.times do |j|
      room_row = []
      room_rows << room_row

      world_image.width.times do |i|
        room_type = RoomType.where(image_color: ChunkyPNG::Color.to_hex(world_image[i, j], false)).first

        if room_type.blank?
          room_row << nil
          next
        end

        new_room = Room.create(
          room_type: room_type,
          area: area,
          x: i,
          y: j
        )
        room_row << new_room

        if j == (world_image.height / 2).to_i && i == (world_image.width / 2).to_i
          # TODO: this is just for testing and moving users to the middle.
          # change this later to be a real starting room
          area.starting_room = new_room

          new_room.items << Items::Item.all
          new_room.save
        end
      end
    end
  end
end
