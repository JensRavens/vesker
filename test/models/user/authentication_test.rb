require "test_helper"

class User::AuthenticationTest < ActiveSupport::TestCase
  describe ".for_login" do
    it "finds or creates a user by normalized email" do
      expect(User.for_login("PRIYA@example.com ")).to eq(users.priya)
      expect { User.for_login("brand-new@example.com") }.to change(User, :count).by(1)
    end
  end

  describe "#generate_login_code" do
    it "is a six-digit numeric code" do
      expect(users.priya.generate_login_code).to match(/\A\d{6}\z/)
    end
  end

  describe "#verify_login_code" do
    it "accepts only the matching code" do
      expect(users.priya.verify_login_code("123456", expected: "123456")).to eq(true)
      expect(users.priya.verify_login_code("000000", expected: "123456")).to eq(false)
      expect(users.priya.verify_login_code("123456", expected: nil)).to eq(false)
    end
  end
end
