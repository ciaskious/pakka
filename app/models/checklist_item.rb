class ChecklistItem < ApplicationRecord
  belongs_to :trip
  belongs_to :item
end
