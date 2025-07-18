class User < ApplicationRecord
  # Include default devise modules
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable

  has_many :trips, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :username, presence: true
  validates :email, presence: true
end
