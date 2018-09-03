class AddPrivateToNews < ActiveRecord::Migration
  def change
    add_column :news, :private, :boolean
  end
end
