class PagesController < ApplicationController
  # Allow unauthenticated access to public pages
  skip_before_action :authenticate_user!, only: [:cgu, :confidentiality]
  
  layout "application"
  
  # GET /pages/cgu
  def cgu
  end
  
  # GET /pages/confidentiality
  def confidentiality
  end
end

