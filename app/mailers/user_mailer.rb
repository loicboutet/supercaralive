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
end

