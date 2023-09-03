class AddOnlineToMubyUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :muby_users, :online, :boolean
  end
end
