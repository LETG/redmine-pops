class RenameStartDateToProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :start_date, :starts_date
  end
end
