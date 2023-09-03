class AddTitleDescriptionToMubyRooms < ActiveRecord::Migration[5.2]
  def self.up
    add_column :muby_rooms, :title, :string
    add_column :muby_rooms, :description, :string
  end
  def self.down
    remove_column :muby_rooms, :title
    remove_column :muby_rooms, :description
  end
end
