class RemoveUrlProjectToProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :url_project
  end
end
