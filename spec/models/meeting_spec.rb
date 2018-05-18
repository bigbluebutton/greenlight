require "rails_helper"

describe Meeting, type: :model do

  it "should be valid." do
    meeting = create(:meeting)
    expect(meeting).to be_valid
  end

  it "name should be present." do
    meeting = build(:meeting, name: nil)
    expect(meeting).to_not be_valid
  end

  it "#random_password is random." do
    meeting = create(:meeting)
    expect(meeting.send(:random_password, 10)).to_not eql(meeting.send(:random_password, 10))
  end
end
