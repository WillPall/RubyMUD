class AddTypeToRooms < ActiveRecord::Migration[5.2]
  def self.up
    add_column :rooms, :room_type, :string
  end
  def self.down
    remove_column :rooms, :room_type
  end
end
