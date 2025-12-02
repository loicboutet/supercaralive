class UserMailer < ApplicationMailer
  def welcome_email(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: "Bienvenue sur SuperCarAlive")
  end

  def professional_welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Bienvenue sur SuperCarAlive - Votre compte est en attente de validation")
  end

  def document_request_email(user, notes, admin_email = nil)
    @user = user
    @notes = notes
    @admin_email = admin_email
    
    mail(to: @user.email, subject: "Demande de documents complémentaires - SuperCarAlive")
  end

  def document_request_email_copy(user, notes, admin_email)
    @user = user
    @notes = notes
    @admin_email = admin_email
    
    mail(to: admin_email, subject: "Copie - Demande de documents complémentaires envoyée à #{user.get_full_name}")
  end
end

