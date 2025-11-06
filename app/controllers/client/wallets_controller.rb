class Client::WalletsController < Client::BaseController

  def show
    # Redirect to the combined maintenance log page
    # which now includes both wallet info and maintenance reminders
    redirect_to client_maintenance_reminders_path
  end

end
