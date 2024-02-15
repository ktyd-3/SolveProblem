class AddPointsToIdeas < ActiveRecord::Migration[7.1]
  def change
    add_column :ideas, :easy_point, :integer
    add_column :ideas, :effect_point, :integer
  end
end
