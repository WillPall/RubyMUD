class AddNonPlayerCharacters < ActiveRecord::Migration[7.0]
  def change
    create_table :non_player_characters do |t|
      t.string :name
      t.integer :room_id
      t.integer :max_health
      t.integer :max_mana
      t.integer :max_stamina
      t.integer :current_health
      t.integer :current_mana
      t.integer :current_stamina
      t.integer :default_disposition

      t.timestamps
    end
  end
end
