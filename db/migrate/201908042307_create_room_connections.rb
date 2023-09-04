class CreateRoomConnections < ActiveRecord::Migration[5.2]
  def self.up
    create_table :room_connections do |t|
      t.integer :source_id
      t.integer :destination_id

      t.timestamps
    end
  end
  def self.down
    drop_table :room_connections
  end
end
