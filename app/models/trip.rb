class Trip < ApplicationRecord
  belongs_to :user
  has_many :checklist_items, dependent: :destroy
  has_many :likes, through: :checklist_items
  has_many :items, through: :checklist_items

  has_one_attached :cover_image

  validates :title, presence: true
  validates :destination, presence: true
  validates :country, presence: true
  validates :accommodation_type, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  validate :start_date_not_in_past

  def duration
    return 0 unless start_date && end_date

    (end_date - start_date).to_i + 1 # +1 to include both start and end days
  end

  before_save :calculate_duration

  ACCOMMODATION_OPTIONS = %w[hostel hotel appartment campsite homestay cabin resort].freeze

  validates :accommodation_type, inclusion: { in: ACCOMMODATION_OPTIONS }

  # Generate AI-powered packing suggestions
  def generate_packing_suggestions
    AiPackingService.call(self)
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "must be after start date") if end_date < start_date
  end

  def start_date_not_in_past
    return unless start_date

    errors.add(:start_date, "cannot be in the past") if start_date < Date.current
  end

  def calculate_duration
    self.duration = (end_date - start_date).to_i + 1 if start_date && end_date
  end
end
