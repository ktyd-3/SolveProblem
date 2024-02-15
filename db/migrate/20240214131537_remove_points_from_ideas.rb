class RemovePointsFromIdeas < ActiveRecord::Migration[7.1]
  def change
    remove_column :ideas, :easy_point, :integer
    remove_column :ideas, :effect_point, :integer
  end
end
