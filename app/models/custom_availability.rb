# == Schema Information
#
# Table name: custom_availabilities
# Database name: primary
#
#  id          :integer          not null, primary key
#  date        :date             not null
#  end_time    :time             not null
#  start_time  :time             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_custom_availabilities_on_user_id_and_date  (user_id,date)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class CustomAvailability < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_slots_for_date
  validate :date_not_in_past

  scope :for_date, ->(date) { where(date: date) }
  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :ordered_by_time, -> { order(:date, :start_time) }

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

  def no_overlapping_slots_for_date
    return unless user_id.present? && date.present? && start_time.present? && end_time.present?

    overlapping = user.custom_availabilities
                      .for_date(date)
                      .where.not(id: id || 0)
                      .where(
                        "(start_time < ? AND end_time > ?)",
                        end_time, start_time
                      )

    if overlapping.exists?
      errors.add(:base, "Ce créneau chevauche un autre créneau existant pour ce jour")
    end
  end

  def date_not_in_past
    return unless date.present?

    if date < Date.current
      errors.add(:date, "ne peut pas être dans le passé")
    end
  end
end

