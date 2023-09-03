class AddTypeToMubyRooms < ActiveRecord::Migration[5.2]
  def self.up
    add_column :muby_rooms, :room_type, :string
  end
  def self.down
    remove_column :muby_rooms, :room_type
  end
end
