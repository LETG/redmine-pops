class CreateLabs < ActiveRecord::Migration
  def change
    create_table :labs do |t|
      t.string :name
      t.string :url
      t.integer :project_id
    end
  end
end
