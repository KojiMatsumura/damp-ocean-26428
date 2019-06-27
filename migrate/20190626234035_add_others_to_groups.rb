class AddOthersToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups,:password_digest,:string
    add_column :groups,:image_name,:string
  end
end
