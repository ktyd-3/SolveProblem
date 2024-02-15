class ModifyIdeasColumns < ActiveRecord::Migration[7.1]
  def change
    change_column_default :ideas, :easy_point, nil
    change_column_default :ideas, :effect_point, nil
  end
end
