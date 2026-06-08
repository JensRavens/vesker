require "test_helper"

class UserTest < ActiveSupport::TestCase
  describe "#name" do
    it "is pre-filled from the title-cased email local-part when blank" do
      expect(User.create!(email: "neo@matrix.io").name).to eq("Neo")
      expect(User.create!(email: "neo.m@matrix.io").name).to eq("Neo M")
    end
  end

  describe "#admin?" do
    it "is true only when the roles array contains \"admin\"" do
      expect(User.new(roles: ["admin"]).admin?).to eq(true)
      expect(User.new(roles: []).admin?).to eq(false)
    end
  end

  describe "roles validation" do
    it "rejects unknown roles" do
      user = User.new(email: "x@y.io", roles: ["wizard"])
      expect(user).not_to be_valid
      expect(user.errors[:roles]).to be_present
    end
  end

  describe "#id" do
    it "is a uuid v7" do
      expect(users.priya.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end
  end
end
