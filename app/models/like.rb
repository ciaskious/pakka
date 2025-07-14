class Like < ApplicationRecord
  belongs_to :user
  belongs_to :checklist_item

  validates :user_id, uniqueness: { scope: :checklist_item_id, message: "has already liked this item" }
end
