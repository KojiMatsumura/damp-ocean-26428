class CreateRepeats < ActiveRecord::Migration[5.2]
  def change
    create_table :repeats do |t|
      t.integer :user_id
      t.integer :group_id
      t.string :rep

      t.timestamps
    end
  end
end
