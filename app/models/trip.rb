class Trip < ApplicationRecord
  belongs_to :user, optional: true  # Temporaire en attendant Devise
  has_many :checklist_items, dependent: :destroy
  has_many :likes, through: :checklist_items

  validates :title, presence: true
  validates :destination, presence: true
  validates :country, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  validate :start_date_not_in_past

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "must be after start date") if end_date < start_date
  end

  def start_date_not_in_past
    return unless start_date

    errors.add(:start_date, "cannot be in the past") if start_date < Date.current
  end
end
