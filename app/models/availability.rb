# == Schema Information
#
# Table name: availabilities
# Database name: primary
#
#  id          :integer          not null, primary key
#  day_of_week :integer          not null
#  end_time    :time             not null
#  start_time  :time             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_availabilities_on_user_id                  (user_id)
#  index_availabilities_on_user_id_and_day_of_week  (user_id,day_of_week)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class Availability < ApplicationRecord
  belongs_to :user

  # Day of week: 0 = Monday, 6 = Sunday
  DAYS_OF_WEEK = {
    monday: 0,
    tuesday: 1,
    wednesday: 2,
    thursday: 3,
    friday: 4,
    saturday: 5,
    sunday: 6
  }.freeze

  validates :day_of_week, presence: true, inclusion: { in: DAYS_OF_WEEK.values }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_slots

  scope :for_day, ->(day) { where(day_of_week: day) }
  scope :ordered_by_day, -> { order(:day_of_week, :start_time) }

  def day_name
    DAYS_OF_WEEK.key(day_of_week)&.to_s&.humanize
  end

  def formatted_time_range
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end

  private

  def end_time_after_start_time
    return unless start_time.present? && end_time.present?

    if end_time <= start_time
      errors.add(:end_time, "doit être après l'heure de début")
    end
  end

  def no_overlapping_slots
    return unless user_id.present? && day_of_week.present? && start_time.present? && end_time.present?

    overlapping = user.availabilities
                       .where(day_of_week: day_of_week)
                       .where.not(id: id || 0)
                       .where(
                         "(start_time < ? AND end_time > ?)",
                         end_time, start_time
                       )

    if overlapping.exists?
      errors.add(:base, "Ce créneau chevauche un autre créneau existant pour ce jour")
    end
  end
end

