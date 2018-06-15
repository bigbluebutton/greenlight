require "rails_helper"

describe Room, type: :model do
  before { @room = create(:room) }

  context 'validations' do
    it { should validate_presence_of :name }
  end

  context 'associations' do
    it { should belong_to(:owner).class_name("User") }
  end

  context '#setup' do
    it 'creates random uid and bbb_id' do
      expect(@room.uid).to_not be_nil
      expect(@room.bbb_id).to_not be_nil
    end
  end

  context "#to_param" do
    it "uses uid as the default identifier for routes" do
      expect(@room.to_param).to eq(@room.uid)
    end
  end

end
