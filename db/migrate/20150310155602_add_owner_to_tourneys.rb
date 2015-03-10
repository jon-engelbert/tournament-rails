class AddOwnerToTourneys < ActiveRecord::Migration
  def change
    add_column :tourneys, :owner_id, :int
  end
end
