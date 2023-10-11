admin_user = User.new(
  username: 'admin',
  name: 'admin',
  max_health: '1000000',
  max_mana: '1000000',
  current_health: '1000000',
  current_mana: '1000000',
  superuser: true
)

# TODO: update the `create` and `new` methods on `User` to also automatically apply BCrypt for password
admin_user.password = 'admin'
admin_user.save

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
