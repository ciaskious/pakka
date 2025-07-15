class Item < ApplicationRecord
  has_many :checklist_items, dependent: :destroy
  has_many :trips, through: :checklist_items
  has_many :likes, through: :checklist_items

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: %w[clothing electronics toiletries documents food medication entertainment gear other] }
end
