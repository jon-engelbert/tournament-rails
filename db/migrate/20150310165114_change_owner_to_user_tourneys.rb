class ChangeOwnerToUserTourneys < ActiveRecord::Migration
  def change
    rename_column :tourneys, :owner_id, :user_id
  end
end
