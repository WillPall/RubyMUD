class FixStatsOnMubyUsers < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :muby_users, :health, :max_health
    rename_column :muby_users, :mana, :max_mana

    add_column :muby_users, :current_health, :integer
    add_column :muby_users, :current_mana, :integer
  end
  def self.down
    remove_column :muby_users, :current_health
    remove_column :muby_users, :current_mana

    rename_column :muby_users, :max_health, :health
    rename_column :muby_users, :max_mana, :mana
  end
end
