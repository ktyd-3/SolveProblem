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

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "easy_point", "effect_point", "id", "id_value", "name", "parent_id", "updated_at"]
  end


  validates :name, presence: true
end
