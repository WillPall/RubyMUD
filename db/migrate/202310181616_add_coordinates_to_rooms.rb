class AddCoordinatesToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :x, :integer
    add_column :rooms, :y, :integer
  end
end
