class Admin::PaymentsController < ApplicationController
  layout 'admin'
  before_action :require_admin

  # GET /admin/payments
  def index
    # Renders view with dummy data
  end

  # GET /admin/payments/:id
  def show
    # Renders view with dummy data
  end
end
