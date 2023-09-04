class RenameStartingRoomColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :worlds, :starting_room, :starting_room_id
  end
end
