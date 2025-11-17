class Admin::BookingsController < ApplicationController
  layout 'admin'
  before_action :require_admin

  # GET /admin/bookings
  def index
    # Renders view with dummy data
  end

  # GET /admin/bookings/:id
  def show
    # Renders view with dummy data
  end
end
