class UserMailer < ApplicationMailer
  # Passwordless login: emails the one-time code. The code lives only in the session.
  def login_code
    @user = params[:user]
    @code = params[:code]
    mail(to: @user.email, subject: "Your sign-in code")
  end
end
