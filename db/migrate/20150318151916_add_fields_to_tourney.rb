class AddFieldsToTourney < ActiveRecord::Migration
  def change
    add_column :tourneys, :points_win, :integer
    add_column :tourneys, :points_tie, :integer
    add_column :tourneys, :points_bye, :integer
  end
end
