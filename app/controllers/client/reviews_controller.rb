require 'ostruct'

class Client::ReviewsController < Client::BaseController

  def new
    # New review form
    @review = OpenStruct.new
  end

  def create
    # In production, this would save review to database
    redirect_to client_booking_path(params[:booking_id]), notice: 'Avis publié avec succès.'
  end

end
