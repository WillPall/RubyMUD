class AddItemAndNpcInstances < ActiveRecord::Migration[7.0]
  def change
    create_table :items_item_instances do |t|
      t.integer :item_id
      t.integer :holdable_id
      t.string :holdable_type
      
      t.timestamps
    end

    remove_column :items_items, :holdable_id, :integer
    remove_column :items_items, :holdable_type, :string
  end
end
