class AddIdeaIdToValues < ActiveRecord::Migration[7.1]
  def change
    add_reference :values, :idea, null: false, foreign_key: true
  end
end
