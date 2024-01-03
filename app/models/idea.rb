class Idea < ApplicationRecord
  acts_as_tree order: "name"
  extend ActsAsTree::TreeView


  validates :name, presence: true
end
