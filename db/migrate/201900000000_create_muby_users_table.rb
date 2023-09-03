# NOTE: This was actually created later than the date given, but the abilility
# to support migrations was added after this table originally existed during
# initial development. Date string is just for ordering.
class CreateMubyUsersTable < ActiveRecord::Migration[5.2]
  def self.up
    create_table :muby_users do |t|
      t.string :username
      t.string :name
      t.string :password
      t.integer :room_id
      t.integer :max_health
      t.integer :max_mana
      t.integer :current_health
      t.integer :current_mana
    end
  end
  def self.down
    drop_table :muby_users
  end
end
