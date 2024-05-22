# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_05_22_022440) do
  create_table "ideas", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "easy_point"
    t.float "effect_point"
    t.integer "user_id", null: false
    t.float "sum_points"
    t.integer "evaluate_done", default: 0
    t.index ["user_id"], name: "index_ideas_on_user_id"
  end

  create_table "points", force: :cascade do |t|
    t.decimal "easy_points"
    t.decimal "effect_points"
    t.decimal "sum_points"
    t.integer "idea_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "themes", force: :cascade do |t|
    t.integer "idea_id"
    t.boolean "evaluation_done"
    t.integer "parent_theme_id"
    t.integer "child_theme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "values", force: :cascade do |t|
    t.decimal "easy_rate"
    t.decimal "effect_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "idea_id", null: false
    t.boolean "public", default: false
    t.index ["idea_id"], name: "index_values_on_idea_id"
  end

  add_foreign_key "ideas", "users"
  add_foreign_key "values", "ideas"
end
