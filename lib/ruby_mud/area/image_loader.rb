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
          # TODO: this is just for testing and moving users to the middle. change this later to be a real starting room
          area.starting_room = new_room

          # TODO: these are for testing and should come from the editor/game instead
          Items::Item.all.each do |item|
            new_room.item_instances << item.create_instance
          end
          new_room.save
          
          shopkeeper = NonPlayerCharacter.where(name: 'Shopkeeper').first
          shopkeeper.room = new_room
          shopkeeper.save

          rat = NonPlayerCharacter.where(name: 'Rat').first
          rat.room = new_room.connections.where(name: 'north').first.destination
          rat.save

          bandit = NonPlayerCharacter.where(name: 'Bandit').first
          bandit.room = new_room.connections.where(name: 'north').first.destination.connections.where(name: 'north').first.destination
          bandit.item_instances << Items::Weapon.first.create_instance
          bandit.save
        end
      end
    end
  end
end
