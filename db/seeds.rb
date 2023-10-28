admin_user = User.new(
  username: 'admin',
  name: 'admin',
  max_health: '1000000',
  max_mana: '1000000',
  max_stamina: '1000000',
  current_health: '1000000',
  current_mana: '1000000',
  current_stamina: '1000000',
  superuser: true
)

# TODO: update the `create` and `new` methods on `User` to also automatically apply BCrypt for password
admin_user.password = 'admin'
admin_user.save

Rooms::Type.create(
  name: 'Water',
  code_name: 'water',
  default_title: 'Deep Water',
  default_description: "You're in the middle of a deep pool of water",
  map_character: '~',
  map_color: 'blue',
  map_is_bright: false,
  image_color: '#0000ff'
)
Rooms::Type.create(
  name: 'Grass',
  code_name: 'grass',
  default_title: 'Grassy Plain',
  default_description: 'Waves of grass and wheat surround you',
  map_character: '"',
  map_color: 'green',
  map_is_bright: true,
  image_color: '#00ff00'
)
Rooms::Type.create(
  name: 'Beach',
  code_name: 'beach',
  default_title: 'Sandy Beach',
  default_description: 'The sand crunches between your toes',
  map_character: '.',
  map_color: 'yellow',
  map_is_bright: true,
  image_color: '#ffff00'
)
Rooms::Type.create(
  name: 'Forest',
  code_name: 'forest',
  default_title: 'Dense Forest',
  default_description: 'The trees whisper in the wind around you',
  map_character: 't',
  map_color: 'green',
  map_is_bright: false,
  image_color: '#329632'
)
Rooms::Type.create(
  name: 'Road',
  code_name: 'road',
  default_title: 'Road',
  default_description: "You're on a road that leads somewhere",
  map_character: '+',
  map_color: 'yellow',
  map_is_bright: false,
  image_color: '#aaaa00'
)

Items::Weapon.create(
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

NonPlayerCharacter.create(
  name: 'Shopkeeper',
  max_health: '1000',
  max_mana: '1000',
  max_stamina: '1000',
  current_health: '1000',
  current_mana: '1000',
  current_stamina: '1000',
  default_disposition: 0
)
NonPlayerCharacter.create(
  name: 'Rat',
  max_health: '5',
  max_mana: '5',
  max_stamina: '5',
  current_health: '5',
  current_mana: '5',
  current_stamina: '5',
  default_disposition: -1000
)
NonPlayerCharacter.create(
  name: 'Bandit',
  max_health: '50',
  max_mana: '50',
  max_stamina: '50',
  current_health: '50',
  current_mana: '50',
  current_stamina: '50',
  default_disposition: -1000
)
