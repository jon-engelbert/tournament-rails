class AddByeToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :bye, :boolean
  end
end
