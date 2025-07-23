class ChecklistItem < ApplicationRecord
  belongs_to :trip
  belongs_to :item, optional: true  # Pour les items prédéfinis
  has_many :likes, dependent: :destroy

  validates :checked, inclusion: { in: [true, false] }, allow_nil: false
end
