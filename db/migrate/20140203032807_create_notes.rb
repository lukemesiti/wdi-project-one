class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :name
      t.text :details
      t.references :task, index: true

      t.timestamps
    end
  end
end
