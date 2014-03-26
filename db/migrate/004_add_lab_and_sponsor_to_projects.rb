class AddLabAndSponsorToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :lab_name, :string
    add_column :projects, :sponsor, :string
  end
end
