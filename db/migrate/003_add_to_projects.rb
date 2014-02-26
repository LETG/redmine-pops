class AddToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :support_id, :integer
  end
end
