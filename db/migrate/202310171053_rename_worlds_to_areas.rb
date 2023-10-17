class RenameWorldsToAreas < ActiveRecord::Migration[7.0]
  def change
    rename_table :worlds, :areas
    rename_column :rooms, :world_id, :area_id
  end
end
