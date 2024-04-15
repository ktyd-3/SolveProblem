class CreatePoints < ActiveRecord::Migration[7.1]
  def change
    create_table :points do |t|
      t.decimal :easy_points
      t.decimal :effect_points
      t.decimal :sum_points
      t.integer :idea_id

      t.timestamps
    end
  end
end
