class AddTitleDescriptionToRooms < ActiveRecord::Migration[5.2]
  def self.up
    add_column :rooms, :title, :string
    add_column :rooms, :description, :string
  end
  def self.down
    remove_column :rooms, :title
    remove_column :rooms, :description
  end
end
