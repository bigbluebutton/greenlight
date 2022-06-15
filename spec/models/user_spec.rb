# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { create(:user) }

    it { is_expected.to belong_to(:role) }

    it { is_expected.to have_many(:rooms).dependent(:destroy) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:provider) }

    it { is_expected.to validate_presence_of(:email) }

    # TODO: samuel - need to find a solution for this
    # it { is_expected.to validate_presence_of(:password_confirmation) }

    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:provider).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:reset_digest).on(:update) }

    context 'password confirmation' do
      it 'invalidate the record for mismatched password confirmation' do
        user = build(:user, password: 'something', password_confirmation: 'something_else')
        expect(user).to be_invalid
        expect(user.errors.first.details).to eq({ error: :confirmation, attribute: 'Password' })
      end
    end

    describe '#search' do
      it 'returns the searched users' do
        searched_users = create_list(:user, 5, name: 'Jane Doe')
        create_list(:user, 5)
        expect(described_class.all.search('jane doe').pluck(:id)).to match_array(searched_users.pluck(:id))
      end

      it 'returns all users if input is empty' do
        create_list(:user, 10)
        expect(described_class.all.search('').pluck(:id)).to match_array(described_class.all.pluck(:id))
      end
    end
  end

  context 'instance methods' do
    describe '#generate_unique_token' do
      let!(:user) { create(:user, email: 'test@greenlight.com') }

      it 'generates/returns a token and saves its digest' do
        freeze_time
        token = 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu'
        allow(SecureRandom).to receive(:alphanumeric).and_return token

        expect(user.generate_unique_token).to eq(token)
        expect(user.reload.reset_digest).to eq(described_class.generate_digest(token))
        expect(user.reset_sent_at).to eq(Time.current)
      end
    end
  end

  context 'static methods' do
    describe '#generate_digest' do
      it 'calls Digest::SHA2#hexdigest to generate a digest' do
        expect(described_class.generate_digest('test')).to eq(Digest::SHA2.hexdigest('test'))
      end
    end

    describe '#token_expired?' do
      let(:period) { Rails.configuration.reset_token_validity_period }

      it 'returns FALSE when the current time does not exceed the given time within the allowed period' do
        freeze_time
        expect(described_class).not_to be_token_expired(Time.current - period)
      end

      it 'returns TRUE when the current time exceed the given time within the allowed period' do
        freeze_time
        expect(described_class).to be_token_expired(Time.current - (period + 1.second))
      end
    end

    describe '#verify_token' do
      let(:period) { Rails.configuration.reset_token_validity_period }
      let(:token) { 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu' }
      let!(:user) do
        create(:user, reset_digest: described_class.generate_digest(token), reset_sent_at: Time.zone.at(1_655_290_260))
      end

      before { travel_to Time.zone.at(1_655_290_260) }

      it 'returns and resets the user found by token digest when the token is valid' do
        travel period

        expect(described_class.verify_token(token)).to eq(user)
        expect(user.reload.reset_digest).to be_blank
        expect(user.reset_sent_at).to be_blank
      end

      it 'does not return the user but reset its token if expired' do
        travel period + 1.second

        expect(described_class.verify_token(token)).to be_falsy
        expect(user.reload.reset_digest).to be_blank
        expect(user.reload.reset_sent_at).to be_blank
      end

      it 'return FALSE for inexistent tokens' do
        travel period

        expect(described_class.verify_token('SOME_BAD_TOKEN')).to be_falsy
      end
    end
  end
end
