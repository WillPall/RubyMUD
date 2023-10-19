class AddRoomTypes < ActiveRecord::Migration[7.0]
  def up
    create_table :room_types do |t|
      t.string :name
      t.string :code_name
      t.string :default_title
      t.text :default_description
      t.string :map_character
      t.string :map_color
      t.boolean :map_is_bright
      t.string :image_color

      t.timestamps
    end

    change_column :rooms, :room_type, :integer
    rename_column :rooms, :room_type, :room_type_id
  end

  def down
    drop_table :room_types

    rename_column :rooms, :room_type_id, :room_type
    change_column :rooms, :room_type, :string
  end
end
