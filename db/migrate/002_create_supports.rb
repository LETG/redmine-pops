class CreateSupports < ActiveRecord::Migration
  def change
    create_table :supports do |t|
      t.string :name
      t.integer :order
    end
  end
end
