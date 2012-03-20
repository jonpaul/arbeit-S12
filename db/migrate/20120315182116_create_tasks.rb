class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.datetime :due_on
      t.string :due_string
      t.integer :project_id
      t.integer :created_by
      t.boolean :completed, :default => false
      t.integer :completed_by
      t.integer :priority

      t.timestamps
    end
  end
end
