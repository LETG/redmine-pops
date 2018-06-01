class AddAnnouncementDateToNews < ActiveRecord::Migration
  def change
    add_column :news, :announcement_date, :date
  end
end
