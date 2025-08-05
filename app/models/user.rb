class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :trips, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :likes, dependent: :destroy


  validates :first_name, presence: true
  
  # Methods
  def name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    else
      username || email.split('@').first
    end
  end

  def favorite_destination
    trips.group(:destination).order("count_id DESC").count("id").first&.first
  end

  # For ActiveAdmin or other admin interfaces
  def display_name
    name
  end
end
