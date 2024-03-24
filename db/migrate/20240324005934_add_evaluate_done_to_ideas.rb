class AddEvaluateDoneToIdeas < ActiveRecord::Migration[7.1]
  def change
    add_column :ideas, :evaluate_done, :integer, default: 0
  end
end
