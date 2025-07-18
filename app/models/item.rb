class Item < ApplicationRecord
  belongs_to :user
  has_many :checklist_items, dependent: :destroy
  has_many :trips, through: :checklist_items
  has_many :likes, through: :checklist_items

  validates :name, presence: true
  validates :description, presence: true
end
