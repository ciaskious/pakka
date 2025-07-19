class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Include default devise modules
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable

  has_many :trips, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :name, presence: true

  # workaround method to solve a devise error
  # "no name method found"
  def name
    username || email
  end
end
