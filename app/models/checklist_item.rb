class ChecklistItem < ApplicationRecord
  belongs_to :trip
  belongs_to :item
  accepts_nested_attributes_for :item

  has_many :likes, dependent: :destroy

  validates :checked, inclusion: { in: [true, false] }, allow_nil: false
end
