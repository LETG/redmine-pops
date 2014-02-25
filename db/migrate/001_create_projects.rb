class CreateProjects < ActiveRecord::Migration
  def change
    add_column :projects, :objectifs, :text
    add_column :projects, :summary, :text
    add_column :projects, :start_date, :datetime
  end
end
