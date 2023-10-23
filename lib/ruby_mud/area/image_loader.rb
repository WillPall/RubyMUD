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
          weapon = Items::Weapon.create(
            name: 'The best weapon',
            description: 'This is the best weapon ever',
            weight: 5,
            value: 5 
          )
          Items::Item.create(
            name: 'Blue Torch',
            description: 'This is a blue torch',
            weight: 5,
            value: 5 
          )
          Items::Item.create(
            name: 'Red Torch',
            description: 'This is a blue torch',
            weight: 5,
            value: 5 
          )
          new_room.items << Items::Item.all
          new_room.save
          
          NonPlayerCharacter.create(
            name: 'Shopkeeper',
            max_health: '1000',
            max_mana: '1000',
            max_stamina: '1000',
            current_health: '1000',
            current_mana: '1000',
            current_stamina: '1000',
            default_disposition: 0,
            room: new_room
          )
          NonPlayerCharacter.create(
            name: 'Rat',
            max_health: '5',
            max_mana: '5',
            max_stamina: '5',
            current_health: '5',
            current_mana: '5',
            current_stamina: '5',
            default_disposition: -1000,
            room_id: new_room.connections.where(name: 'north').first.destination_id
          )
          bandit = NonPlayerCharacter.create(
            name: 'Bandit',
            max_health: '50',
            max_mana: '50',
            max_stamina: '50',
            current_health: '50',
            current_mana: '50',
            current_stamina: '50',
            default_disposition: -1000,
            room_id: new_room.connections.where(name: 'north').first.destination.connections.where(name: 'north').first.destination_id
          )
          bandit.items << weapon.dup
          bandit.save
        end
      end
    end
  end
end
