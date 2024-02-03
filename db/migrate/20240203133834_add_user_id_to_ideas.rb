class AddUserIdToIdeas < ActiveRecord::Migration[7.1]
  def change
    add_reference :ideas, :user, null: false, foreign_key: true
  end

end
