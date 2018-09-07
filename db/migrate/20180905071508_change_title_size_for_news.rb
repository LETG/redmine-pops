class ChangeTitleSizeForNews < ActiveRecord::Migration
  def self.up
    change_column :news, :title, :string, :limit => 150
  end

  def self.down
    change_column :news, :title, :string, :limit => 60
  end
end
