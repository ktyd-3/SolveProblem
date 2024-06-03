class AddDefaultToRateInValues < ActiveRecord::Migration[7.1]
  def change
    change_column_default :values, :easy_rate, 1.0
    change_column_default :values, :effect_rate, 1.0
  end
end
