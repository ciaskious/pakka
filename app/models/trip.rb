class Trip < ApplicationRecord
  attr_accessor :skip_date_validation

  belongs_to :user
  has_many :checklist_items, dependent: :destroy
  has_many :likes, through: :checklist_items
  has_many :items, through: :checklist_items

  has_one_attached :cover_image

  # all trips marked public
  scope :public_trips, -> { where(public: true) }

  # all private trips
  scope :private_trips, -> { where(public: false) }

  # optionally exclude own trips when showing community:
  scope :community_trips, ->(user) {
          where(public: true).where.not(user_id: user&.id)
        }

  validates :title, presence: true
  validates :destination, presence: true
  validates :country, presence: true
  validates :start_date, presence: true, unless: :skip_date_validation
  validates :end_date, presence: true, unless: :skip_date_validation
  validates :accommodation_type, presence: true
  validate :start_date_not_in_past, on: :create # Only validate on create
  validate :end_date_after_start_date

  validates :public, inclusion: { in: [true, false] }

  scope :upcoming, -> { where("start_date >= ?", Date.current).order(start_date: :asc) }
  scope :past, -> { where("start_date < ?", Date.current).order(start_date: :desc) }
  scope :chronological, -> { order(start_date: :asc) }

  def duration
    return 0 unless valid_dates?

    (end_date - start_date).to_i + 1
  end

  before_save :calculate_duration

  ACCOMMODATION_OPTIONS = %w[hotel hostel appartment campsite homestay cabin resort].freeze

  validates :accommodation_type, inclusion: { in: ACCOMMODATION_OPTIONS }

  # Generate AI-powered packing suggestions
  def generate_packing_suggestions
    AiPackingService.call(self)
  end

  private

  def valid_dates?
    start_date.present? && end_date.present? && end_date >= start_date
  end

  def start_date_not_in_past
    return unless start_date.present?

    errors.add(:start_date, "must be today or in the future for new trips") if start_date < Date.current
  end

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    elsif end_date == start_date
      errors.add(:end_date, "must be at least 1 day after start date")
    end
  end

  def calculate_duration
    self.duration = (end_date - start_date).to_i + 1 if start_date && end_date
  end
end
