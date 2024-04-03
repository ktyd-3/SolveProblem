class AddPublicToValues < ActiveRecord::Migration[7.1]
  def change
    add_column :values, :public, :boolean, default: false
  end
end
