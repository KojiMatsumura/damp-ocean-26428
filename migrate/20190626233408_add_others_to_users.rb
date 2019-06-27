class AddOthersToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users,:email,:string
    add_column :users,:password_digest,:string
    add_column :users,:admin,:boolean
    add_column :users,:image_name,:string
  end
end
