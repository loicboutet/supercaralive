class Client::MaintenanceRemindersController < Client::BaseController
  before_action :set_reminder, only: [:mark_as_done, :invalidate]

  def index
    @reminders = Reminder.for_user(current_user).ordered_by_due_date.includes(:vehicle)
    
    # Count reminders by status
    not_done_reminders = @reminders.not_done
    @urgent_count = not_done_reminders.count { |r| r.status_color == 'red' }
    @upcoming_count = not_done_reminders.count { |r| r.status_color == 'yellow' }
    @completed_count = @reminders.done.count
  end

  def toggle_reminders
    current_user.update(maintenance_reminders_enabled: !current_user.maintenance_reminders_enabled?)
    respond_to do |format|
      format.html { redirect_to client_maintenance_reminders_path, notice: current_user.maintenance_reminders_enabled? ? 'Rappels d\'entretien activés.' : 'Rappels d\'entretien désactivés.' }
    end
  end

  def mark_as_done
    if @reminder.update(done: true)
      respond_to do |format|
        format.html { redirect_to client_maintenance_reminders_path, notice: 'Rappel marqué comme fait.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to client_maintenance_reminders_path, alert: 'Erreur lors de la mise à jour.' }
      end
    end
  end

  def invalidate
    if @reminder.update(done: false)
      respond_to do |format|
        format.html { redirect_to client_maintenance_reminders_path, notice: 'Rappel invalidé.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to client_maintenance_reminders_path, alert: 'Erreur lors de la mise à jour.' }
      end
    end
  end

  private

  def set_reminder
    @reminder = Reminder.joins(:vehicle).where(vehicles: { user_id: current_user.id }).find(params[:id])
  end
end
