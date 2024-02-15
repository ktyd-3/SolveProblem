class ModifyIdeasColumns < ActiveRecord::Migration[7.1]
  def change
    change_column_default :ideas, :easy_point, from: nil, to: 0
    change_column_default :ideas, :effect_point, from: nil, to: 0
  end
end
