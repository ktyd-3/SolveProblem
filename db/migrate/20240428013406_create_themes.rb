class CreateThemes < ActiveRecord::Migration[7.1]
  def change
    create_table :themes do |t|
      t.integer :idea_id
      t.boolean :evaluation_done
      t.integer :parent_theme_id
      t.integer :child_theme_id

      t.timestamps
    end
  end
end
