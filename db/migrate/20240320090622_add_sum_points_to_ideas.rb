class AddSumPointsToIdeas < ActiveRecord::Migration[7.1]
  def change
    add_column :ideas, :sum_points, :integer
  end
end
