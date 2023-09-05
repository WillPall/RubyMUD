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
