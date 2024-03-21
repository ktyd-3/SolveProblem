class Idea < ApplicationRecord
  has_many :children, class_name: "Idea", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Idea", optional: true
  belongs_to :user

  acts_as_tree order: "name"

  def sum_points
    easy_point.to_i + effect_point.to_i
  end

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
