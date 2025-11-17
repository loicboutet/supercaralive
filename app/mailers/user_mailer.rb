class UserMailer < ApplicationMailer
  def welcome_email(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: "Bienvenue sur SuperCarAlive")
  end
end

