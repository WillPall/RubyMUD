class AddSuperuserToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :superuser, :boolean, default: false
  end
end
