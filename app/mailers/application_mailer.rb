class ApplicationMailer < ActionMailer::Base
  default from: Config.smtp_from
  layout "mailer"
end
