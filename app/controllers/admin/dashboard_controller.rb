class Admin::DashboardController < ApplicationController
  layout 'admin'
  before_action :require_admin
  before_action :ensure_app_config_exists

  # GET /admin
  def index
    # Total Users (excluding admins)
    @total_users = User.where.not(role: 'Admin').count
    
    # New Signups (users created in the last 30 days, excluding admins)
    @new_signups = User.where.not(role: 'Admin')
                       .where('created_at >= ?', 30.days.ago)
                       .count
    
    # Clients count
    @clients_count = User.where(role: 'Client').count
    
    # Professionals count
    @professionals_count = User.where(role: 'Professional').count
    
    # Pending Approvals (professionals with inactive status)
    @pending_approvals = User.where(role: 'Professional', status: 'inactive').count
    
    # Total Bookings
    @total_bookings = Booking.count
    
    # Recent Bookings (last 5)
    @recent_bookings = Booking.includes(:client, :professional, :professional_service)
                              .order(created_at: :desc)
                              .limit(5)
    
    # User registrations chart data based on scope
    @chart_scope = params[:chart_scope] || '12_months'
    @user_registrations_data = calculate_user_registrations_data(@chart_scope)
  end
  
  private
  
  def ensure_app_config_exists
    AppConfig.instance unless AppConfig.exists?
  end
  
  def calculate_user_registrations_data(scope)
    case scope
    when '30_days'
      calculate_user_registrations_by_day
    when '6_months'
      calculate_user_registrations_by_months(6)
    else # '12_months' (default)
      calculate_user_registrations_by_months(12)
    end
  end
  
  def calculate_user_registrations_by_day
    # Get the last 30 days
    days_data = []
    30.times do |i|
      day = (30 - i - 1).days.ago.beginning_of_day
      day_end = day.end_of_day
      
      count = User.where.not(role: 'Admin')
                  .where(created_at: day..day_end)
                  .count
      
      days_data << {
        label: I18n.l(day, format: '%d/%m'),
        label_full: I18n.l(day, format: :short),
        count: count
      }
    end
    
    days_data
  end
  
  def calculate_user_registrations_by_months(months_count)
    # Get the last N months
    months_data = []
    months_count.times do |i|
      month_start = (months_count - i - 1).months.ago.beginning_of_month
      month_end = month_start.end_of_month
      
      count = User.where.not(role: 'Admin')
                  .where(created_at: month_start..month_end)
                  .count
      
      months_data << {
        label: I18n.l(month_start, format: '%b'),
        label_full: I18n.l(month_start, format: :short),
        count: count
      }
    end
    
    months_data
  end
end
