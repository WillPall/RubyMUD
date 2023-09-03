class AddNameToRoomConnections < ActiveRecord::Migration[5.2]
  def self.up
    add_column :room_connections, :name, :string
  end
  def self.down
    remove_column :room_connections, :name
  end
end
