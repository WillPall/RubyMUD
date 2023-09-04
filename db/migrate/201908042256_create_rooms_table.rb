class CreateRoomsTable < ActiveRecord::Migration[5.2]
  def self.up
    create_table :rooms do |t|
      t.timestamps
    end
  end
  def self.down
    drop_table :rooms
  end
end
