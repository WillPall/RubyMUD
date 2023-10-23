class AddStaminaToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :max_stamina, :integer
    add_column :users, :current_stamina, :integer
  end
end
