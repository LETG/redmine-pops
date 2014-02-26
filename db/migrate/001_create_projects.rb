class CreateProjects < ActiveRecord::Migration
  def change
    add_column :projects, :objectifs, :text
    add_column :projects, :accronym, :string
    add_column :projects, :resume, :text
    add_column :projects, :methodologies, :text
    add_column :projects, :results, :text
    add_column :projects, :perspectives, :text
    add_column :projects, :comments, :text
    add_column :projects, :url_public, :string
    add_column :projects, :url_project, :string
    add_column :projects, :start_date, :datetime
  end
end
