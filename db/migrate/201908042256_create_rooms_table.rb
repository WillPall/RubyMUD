class CreateRoomsTable < ActiveRecord::Migration[5.2]
  def self.up
    create_table :rooms do |t|
    end
  end
  def self.down
    drop_table :rooms
  end
end
