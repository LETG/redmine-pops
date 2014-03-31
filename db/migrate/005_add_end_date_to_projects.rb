class AddEndDateToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :ends_date, :datetime
  end
end
