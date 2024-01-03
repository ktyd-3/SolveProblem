class Idea < ApplicationRecord

  extend ActsAsTree::TreeView
  acts_as_tree order: "name"


  validates :name, presence: true
end
