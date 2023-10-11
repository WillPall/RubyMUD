class CreateItemsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :items_items do |t|
      # type for STI
      t.string :type

      t.string :name
      t.string :description
      t.integer :weight
      t.integer :value

      # can be a room, an entity, or something else that can hold items
      t.integer :holdable_id
      t.string :holdable_type

      t.timestamps
    end
  end
end
