require "rails_helper"

describe Room, type: :model do

  describe "#owned_by?" do
    it "should identify correct owner." do
      room = create(:room)
      expect(room.owned_by?(room.user)).to eql(true)
    end

    it "should identify incorrect owner." do
      room = create(:room)
      expect(room.owned_by?(create(:user))).to eql(false)
    end

    it "should return false when user is nil." do
      room = create(:room)
      expect(room.owned_by?(nil)).to eql(false)
    end
  end
end