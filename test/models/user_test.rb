require "test_helper"

class UserTest < ActiveSupport::TestCase
  describe "#name" do
    it "is pre-filled from the title-cased email local-part when blank" do
      expect(User.create!(email: "neo@matrix.io").name).to eq("Neo")
      expect(User.create!(email: "neo.m@matrix.io").name).to eq("Neo M")
    end
  end

  describe "#admin?" do
    it "reflects the admin flag" do
      expect(User.new(admin: true).admin?).to eq(true)
      expect(User.new(admin: false).admin?).to eq(false)
    end
  end

  describe "#id" do
    it "is a uuid v7" do
      expect(users.priya.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end
  end
end
