class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :category
      t.text :description
      t.boolean :complete
      t.references :user, index: true

      t.timestamps
    end
  end
end
