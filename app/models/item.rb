class Item < ApplicationRecord
  belongs_to :user
  has_many :checklist_items, dependent: :destroy
  has_many :trips, through: :checklist_items
  has_many :likes, through: :checklist_items

  validates :name, :category, presence: true

  validates :reusable, inclusion: { in: [true, false] }

  CATEGORIES = %w[clothes toiletries tech food documents].freeze

  validates :category, inclusion: { in: CATEGORIES }

  scope :reusable, -> { where(reusable: true) }
end
