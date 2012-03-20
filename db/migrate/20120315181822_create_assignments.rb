class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :project_id
      t.integer :user_id
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
