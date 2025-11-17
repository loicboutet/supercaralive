# == Schema Information
#
# Table name: vehicles
# Database name: primary
#
#  id                             :integer          not null, primary key
#  brand                          :string
#  maintenance_reminders_enabled  :boolean          default(FALSE)
#  mileage                        :integer
#  model                          :string
#  next_maintenance_date          :date
#  next_technical_inspection_date :date
#  upcoming_service               :text
#  vin_number                     :string
#  year                           :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  user_id                        :integer          not null
#
# Indexes
#
#  index_vehicles_on_user_id  (user_id)
#
class Vehicle < ApplicationRecord
  belongs_to :user
  has_many :reminders, dependent: :destroy

  validates :brand, presence: true
  validates :model, presence: true
  validates :year, presence: true, numericality: { greater_than_or_equal_to: 1900, less_than_or_equal_to: -> { Date.current.year + 1 } }
  validates :mileage, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :vin_number, length: { maximum: 17 }, allow_blank: true
  validates :user_id, presence: true

  # Ensure user is a client
  validate :user_must_be_client

  # Callbacks to create/update reminders when dates change
  after_save :sync_maintenance_reminder
  after_save :sync_technical_inspection_reminder

  private

  def user_must_be_client
    if user.present? && !user.client?
      errors.add(:user, "must be a client")
    end
  end

  def sync_maintenance_reminder
    if next_maintenance_date.present?
      reminder = reminders.find_or_initialize_by(reminder_type: 'maintenance')
      reminder.due_date = next_maintenance_date
      reminder.save if reminder.changed?
    else
      reminders.where(reminder_type: 'maintenance').destroy_all
    end
  end

  def sync_technical_inspection_reminder
    if next_technical_inspection_date.present?
      reminder = reminders.find_or_initialize_by(reminder_type: 'technical_inspection')
      reminder.due_date = next_technical_inspection_date
      reminder.save if reminder.changed?
    else
      reminders.where(reminder_type: 'technical_inspection').destroy_all
    end
  end
end

