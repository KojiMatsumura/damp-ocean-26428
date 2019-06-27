class AddOthersToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts,:user_id,:integer
    add_column :posts,:group_id,:integer
    add_column :posts,:buyer_id,:integer
    add_column :posts,:shop,:string
  end
end
