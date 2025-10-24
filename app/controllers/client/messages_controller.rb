class Client::MessagesController < Client::BaseController

  def index
    # List all message conversations
    # In production, this would load from database
  end

  def create
    # In production, this would save message to database
    redirect_to client_messages_path, notice: 'Message envoyé avec succès.'
  end

end
