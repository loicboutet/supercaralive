class MockupsController < ApplicationController
  # Set the layout based on the action
  layout "application"
  
  # Mockups are only accessible to admins
  before_action :require_admin
  
  def index
    # Main index page that will list all mockup journeys
  end
end
