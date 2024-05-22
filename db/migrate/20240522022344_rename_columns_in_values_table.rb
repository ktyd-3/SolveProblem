class RenameColumnsInValuesTable < ActiveRecord::Migration[7.1]
  def change
      rename_column :values, :easy, :easy_rate
      rename_column :values, :effect, :effect_rate
  end
end
