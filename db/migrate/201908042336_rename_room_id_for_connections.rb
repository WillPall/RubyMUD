class RenameRoomIdForConnections < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :muby_room_connections, :source_id, :room_id
  end
  def self.down
    rename_column :muby_room_connections, :room_id, :source_id
  end
end
