class CreateEntrants < ActiveRecord::Migration
  def change
    create_table :entrants do |t|
      t.integer :player_id
      t.integer :tourney_id

      t.timestamps null: false
    end
  end
end
