class ChecklistItem < ApplicationRecord
  belongs_to :trip
  has_many :likes, dependent: :destroy

  validates :name, presence: true
  validates :checked, inclusion: { in: [true, false] }
  validates :generated_by_ai, inclusion: { in: [true, false] }
end
