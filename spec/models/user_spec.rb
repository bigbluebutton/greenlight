require "rails_helper"

describe User, type: :model do
  before { @user = create(:user) }

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(24) }

    it { should validate_presence_of(:provider) }

    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:email).is_at_most(60) }
    it { should allow_value("", nil).for(:email) }
    it { should allow_value("valid@email.com").for(:email) }
    it { should_not allow_value("invalid_email").for(:email) }

    it { should allow_value("valid.jpg").for(:image) }
    it { should allow_value("valid.png").for(:image) }
    it { should_not allow_value("invalid.txt").for(:image) }
    it { should allow_value("", nil).for(:image) }

    context 'is greenlight account' do
      before { allow(subject).to receive(:greenlight_account?).and_return(true) }
      it { should validate_presence_of(:password) }
      it { should validate_length_of(:password).is_at_least(6) }
    end

    context 'is not greenlight account' do
      before { allow(subject).to receive(:greenlight_account?).and_return(false) }
      it { should_not validate_presence_of(:password) }
    end
  end

  context 'associations' do
    it { should belong_to(:main_room).class_name("Room").with_foreign_key("room_id") }
    it { should have_many(:rooms) }
  end

  context '#initialize_main_room' do
    it 'creates random uid and main_room' do
      expect(@user.uid).to_not be_nil
      expect(@user.main_room).to be_a(Room)
    end
  end

  context "#to_param" do
    it "uses uid as the default identifier for routes" do
      expect(@user.to_param).to eq(@user.uid)
    end
  end

  context '#first_name' do
    it 'properly finds the users first name' do
      user = create(:user, name: "Example User")
      expect(user.firstname).to eq("Example")
    end
  end
end
