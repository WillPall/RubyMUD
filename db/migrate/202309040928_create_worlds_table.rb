class CreateWorldsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :worlds do |t|
      t.integer :starting_room

      t.timestamps
    end
  end
end
