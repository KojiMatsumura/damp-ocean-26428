class AddContentToRepeats < ActiveRecord::Migration[5.2]
  def change
    add_column :repeats,:content,:text
  end
end
