class CreateIdeas < ActiveRecord::Migration[7.1]
  def change
    create_table :ideas do |t|
      t.string :name
      t.integer :parent_id

      t.timestamps
    end
  end
end
