require "test_helper"

class MomentPolicyTest < ActiveSupport::TestCase
  describe "#destroy?" do
    it "is allowed for the uploader or any admin" do
      moment = photos.tiles # uploaded by Jonas

      expect(MomentPolicy.new(users.jonas, moment).destroy?).to eq(true)  # uploader
      expect(MomentPolicy.new(users.marco, moment).destroy?).to eq(true)  # admin
      expect(MomentPolicy.new(users.priya, moment).destroy?).to eq(false) # a regular user, not the uploader
      expect(MomentPolicy.new(nil, moment).destroy?).to eq(false)         # guest
    end
  end
end
