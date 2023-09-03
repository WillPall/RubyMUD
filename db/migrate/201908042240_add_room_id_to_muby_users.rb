class AddRoomIdToMubyUsers < ActiveRecord::Migration[5.2]
  def self.up
    add_column :muby_users, :room_id, :integer
  end
  def self.down
    remove_column :muby_users, :room_id, :integer
  end
end
