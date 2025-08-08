class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :trips, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :username, presence: false
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true

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

  def favorite_destination_count
    trips.group(:destination).count.max_by { |_, v| v }&.last || 0
  end

  def visited_countries
    trips.pluck(:country).compact.uniq
  end

  def longest_trip_duration
    trips.pluck(:start_date, :end_date).map { |s, e| (e - s).to_i }.max || 0
  end

  def favorite_destination_info
    trips
      .group(:destination)
      .order('count(destination) desc')
      .limit(1)
      .pluck(:destination, 'count(destination)')
      .first || [nil, 0] # Returns [destination, count] or [nil, 0] if no trips
  end
end
