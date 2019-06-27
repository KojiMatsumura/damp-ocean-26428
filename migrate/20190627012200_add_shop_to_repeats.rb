class AddShopToRepeats < ActiveRecord::Migration[5.2]
  def change
    add_column :repeats, :shop, :string
  end
end
