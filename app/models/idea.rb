class Idea < ApplicationRecord
  has_many :children, class_name: "Idea", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Idea", optional: true
  has_one :value,dependent: :destroy
  has_one :point, dependent: :destroy
  has_one :theme, dependent: :destroy
  belongs_to :user


  acts_as_tree order: "name"

  def sum_points
    ((easy_point.to_f + effect_point.to_f)* 10**3).ceil / 10.0**3
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


  validates :name, presence: true, length: { maximum: 255 }
end
