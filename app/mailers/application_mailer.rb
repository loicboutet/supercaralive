class ApplicationMailer < ActionMailer::Base
  default from: -> { Rails.env.production? ? "no-reply@5000.dev" : "from@example.com" }
  layout "mailer"
end
