class User < ApplicationRecord
  has_secure_password

  validates :user_name, presence: true, length: { maximum: 20 }
  validates :email, presence: true, uniqueness: true
end
