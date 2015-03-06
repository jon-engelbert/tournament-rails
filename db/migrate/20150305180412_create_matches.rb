class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :player1_id
      t.integer :player2_id
      t.integer :tourney_id
      t.integer :round
      t.integer :player1_score
      t.integer :player2_score
      t.integer :ties

      t.timestamps null: false
    end
  end
end
