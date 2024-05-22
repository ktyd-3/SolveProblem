class ChangeColumnTypeInValuesTable < ActiveRecord::Migration[7.1]
  def change
    change_column :values, :easy_rate, :decimal
    change_column :values, :effect_rate, :decimal
  end
end
