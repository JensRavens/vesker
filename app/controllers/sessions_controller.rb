class SessionsController < ApplicationController
  include Shimmer::RemoteNavigation

  # Basic brute-force protection (per IP): cap code requests and code guesses.
  rate_limit to: 5, within: 3.minutes, only: :create, name: "session-create"
  rate_limit to: 10, within: 3.minutes, only: :verify, name: "session-verify"

  # Step 1: the email form (loaded into the modal).
  def new
    render Views::Sessions::New.new, layout: false
  end

  # Step 1 → 2: start the login, then swap the modal to the code form.
  def create
    user = login.start(params[:email])
    render Views::Sessions::Verify.new(email: user.email), layout: false
  end

  # Step 2: verify the code. On success close the modal + morph the host page.
  def verify
    if login.verify(params[:code])
      ui.navigate_to(request.referer)
    else
      render Views::Sessions::Verify.new(email: login.pending_email, error: t(".invalid_code")),
        layout: false, status: :unprocessable_entity
    end
  end

  def destroy
    login.sign_out
    redirect_back fallback_location: "/", allow_other_host: false
  end
end
