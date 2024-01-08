class Idea < ApplicationRecord
  acts_as_tree order: "name"
  extend ActsAsTree::TreeView

  def dig
    if children.empty?
      self
    else
      children.map(&:dig)
    end
  end


  validates :name, presence: true
end
