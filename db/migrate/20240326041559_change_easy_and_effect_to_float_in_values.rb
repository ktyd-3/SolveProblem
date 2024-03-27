class ChangeEasyAndEffectToFloatInValues < ActiveRecord::Migration[7.1]
  def change
    change_column :values, :easy, :float, default: 1, null: false
    change_column :values, :effect, :float, default: 1, null: false
  end
end
