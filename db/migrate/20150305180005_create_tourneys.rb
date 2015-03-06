class CreateTourneys < ActiveRecord::Migration
  def change
    create_table :tourneys do |t|
      t.string :name
      t.datetime :date
      t.string :location

      t.timestamps null: false
    end
  end
end
