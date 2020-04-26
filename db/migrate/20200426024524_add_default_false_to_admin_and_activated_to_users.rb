class AddDefaultFalseToAdminAndActivatedToUsers < ActiveRecord::Migration[6.0]

  def up
    change_column :users, :admin, :boolean, default: false
    change_column :users, :activated, :boolean, default: false
  end
  
  def down
    change_column :users, :admin, :boolean, default: nil
    change_column :users, :activated, :boolean, default: nil
  end


end
