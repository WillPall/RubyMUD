class AddStatsToMubyUsers < ActiveRecord::Migration[5.2]
  def self.up
    add_column :muby_users, :health, :integer
    add_column :muby_users, :mana, :integer
  end
  def self.down
    remove_column :muby_users, :health
    remove_column :muby_users, :mana
  end
end
