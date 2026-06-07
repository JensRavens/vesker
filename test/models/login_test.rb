require "test_helper"

class LoginTest < ActiveSupport::TestCase
  describe "#start" do
    it "finds the existing user, emails a code, and remembers the email" do
      expect { login.start("priya@example.com") }.not_to change(User, :count)

      expect(login.pending_email).to eq("priya@example.com")
      run_jobs
      expect(last_mail!.to.to_s).to include("priya@example.com")
    end

    it "creates a brand-new user" do
      expect { login.start("brand-new@example.com") }.to change(User, :count).by(1)
    end

    it "normalizes the email before remembering it" do
      login.start("  PRIYA@EXAMPLE.COM ")

      expect(login.pending_email).to eq("priya@example.com")
    end
  end

  describe "#verify" do
    it "signs the user in when the code matches" do
      login.start("priya@example.com")
      run_jobs

      expect(login.verify(last_mail!.text[/\b\d{6}\b/])).to eq(true)
      expect(login.user).to eq(users.priya)
      expect(login.signed_in?).to eq(true)
    end

    it "rejects a wrong code and stays signed out" do
      login.start("priya@example.com")

      expect(login.verify("000000")).to eq(false)
      expect(login.user).to be_nil
      expect(login.signed_in?).to eq(false)
    end
  end

  describe "#sign_out" do
    it "clears the session cookie" do
      login.start("priya@example.com")
      run_jobs
      login.verify(last_mail!.text[/\b\d{6}\b/])

      login.sign_out

      # A fresh Login reading the same jar no longer sees a signed-in user.
      expect(Login.new(cookie_jar).signed_in?).to eq(false)
    end
  end

  private

  def login
    @login ||= Login.new(cookie_jar)
  end

  def cookie_jar
    @cookie_jar ||= ActionDispatch::TestRequest.create.cookie_jar
  end
end
