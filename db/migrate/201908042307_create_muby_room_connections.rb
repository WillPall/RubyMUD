class CreateMubyRoomConnections < ActiveRecord::Migration[5.2]
  def self.up
    create_table :muby_room_connections do |t|
      t.integer :source_id
      t.integer :destination_id
    end
  end
  def self.down
    drop_table :muby_room_connections
  end
end
