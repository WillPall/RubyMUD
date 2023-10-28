class MoveRoomsToModule < ActiveRecord::Migration[7.0]
  def change
    rename_column :rooms, :room_type_id, :type_id

    rename_table :rooms, :rooms_rooms
    rename_table :room_types, :rooms_types
    rename_table :room_connections, :rooms_connections
  end
end
