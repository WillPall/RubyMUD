class AddNameToRoomConnections < ActiveRecord::Migration[5.2]
  def self.up
    add_column :muby_room_connections, :name, :string
  end
  def self.down
    remove_column :muby_room_connections, :name
  end
end
