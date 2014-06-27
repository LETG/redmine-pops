class AddVisibleInTimelineToNews < ActiveRecord::Migration
  def change
    add_column :news, :visible_in_timeline, :boolean
  end
end
