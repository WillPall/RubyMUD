class AddWorldIdToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :world_id, :world
  end
end
