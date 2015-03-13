class AddMultiIndexToEntrants < ActiveRecord::Migration
  def change
  	add_index :entrants, :player_id
  	add_index :entrants, :tourney_id
    add_index :entrants, [:player_id, :tourney_id], unique: true
  end
end
