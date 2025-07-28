class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :trips, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :username, presence: true

  def name
    username || email
  end

  def favorite_destination
    trips.group(:destination).order("count_id DESC").count("id").first&.first
  end
end
