class CreateValues < ActiveRecord::Migration[7.1]
  def change
    create_table :values do |t|
      t.integer :easy, default: 1, null: false
      t.integer :effect, default: 1, null: false

      t.timestamps
    end
  end
end
