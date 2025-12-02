class PagesController < ApplicationController
  # Allow unauthenticated access to public pages
  skip_before_action :authenticate_user!, only: [:cgu, :confidentiality, :legal, :contact, :about, :faq]
  
  layout "application"
  
  # GET /pages/cgu
  def cgu
  end
  
  # GET /pages/confidentiality
  def confidentiality
  end
  
  # GET /pages/legal
  def legal
  end
  
  # GET /pages/contact
  def contact
  end
  
  # GET /pages/about
  def about
  end
  
  # GET /pages/faq
  def faq
  end
end

