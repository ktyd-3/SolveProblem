class ChangeColumnTypesInIdeas < ActiveRecord::Migration[7.1]
  def change
    change_column :ideas, :easy_point, :float
    change_column :ideas, :effect_point, :float
    change_column :ideas, :sum_points, :float
  end
end
