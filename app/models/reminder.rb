# == Schema Information
#
# Table name: reminders
# Database name: primary
#
#  id                     :integer          not null, primary key
#  done                   :boolean          default(FALSE), not null
#  due_date               :date             not null
#  overdue_reminder_sent  :boolean          default(FALSE), not null
#  reminder_type          :string           not null
#  upcoming_reminder_sent :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  vehicle_id             :integer          not null
#
# Indexes
#
#  index_reminders_on_vehicle_id  (vehicle_id)
#
class Reminder < ApplicationRecord
  belongs_to :vehicle

  validates :vehicle_id, presence: true
  validates :reminder_type, presence: true, inclusion: { in: %w[maintenance technical_inspection] }
  validates :due_date, presence: true
  validates :done, inclusion: { in: [true, false] }

  scope :not_done, -> { where(done: false) }
  scope :done, -> { where(done: true) }
  scope :for_user, ->(user) { joins(:vehicle).where(vehicles: { user_id: user.id }) }
  scope :ordered_by_due_date, -> { order(due_date: :asc) }

  def days_until_due
    (due_date - Date.current).to_i
  end

  def status_color
    return 'green' if done
    
    days = days_until_due
    if days < 0
      'red' # En retard
    elsif days <= 15
      'red' # Urgent (moins de 15 jours)
    elsif days <= 60
      'yellow' # À venir (entre 15 et 60 jours)
    else
      'green' # Loin (plus de 60 jours)
    end
  end

  def status_label
    return 'Effectué' if done
    
    days = days_until_due
    if days < 0
      'Urgent'
    elsif days <= 15
      'Urgent'
    elsif days <= 60
      'À venir'
    else
      'À venir'
    end
  end

  def humanized_time_until_due
    days = days_until_due
    
    return "Retard de #{days.abs} jour#{days.abs > 1 ? 's' : ''}" if days < 0
    return "Aujourd'hui !" if days == 0
    
    # Moins d'une semaine
    if days <= 7
      "Dans #{days} jour#{days > 1 ? 's' : ''}"
    # Moins d'un mois
    elsif days < 30
      weeks = days / 7
      remaining_days = days % 7
      if weeks > 0 && remaining_days > 0
        "Dans #{weeks} semaine#{weeks > 1 ? 's' : ''} et #{remaining_days} jour#{remaining_days > 1 ? 's' : ''}"
      elsif weeks > 0
        "Dans #{weeks} semaine#{weeks > 1 ? 's' : ''}"
      else
        "Dans #{days} jour#{days > 1 ? 's' : ''}"
      end
    # Moins d'un an
    elsif days < 365
      months = days / 30
      remaining_days = days % 30
      if remaining_days >= 7
        weeks = remaining_days / 7
        remaining_days_after_weeks = remaining_days % 7
        parts = ["#{months} mois"]
        parts << "#{weeks} semaine#{weeks > 1 ? 's' : ''}" if weeks > 0
        parts << "#{remaining_days_after_weeks} jour#{remaining_days_after_weeks > 1 ? 's' : ''}" if remaining_days_after_weeks > 0
        "Dans #{parts.join(' et ')}"
      elsif remaining_days > 0
        "Dans #{months} mois et #{remaining_days} jour#{remaining_days > 1 ? 's' : ''}"
      else
        "Dans #{months} mois"
      end
    # Plus d'un an
    else
      years = days / 365
      remaining_days = days % 365
      months = remaining_days / 30
      if months > 0
        "Dans #{years} an#{years > 1 ? 's' : ''} et #{months} mois"
      else
        "Dans #{years} an#{years > 1 ? 's' : ''}"
      end
    end
  end
end

