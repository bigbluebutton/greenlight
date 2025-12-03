# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:provider).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:reset_digest) }
    it { is_expected.to validate_uniqueness_of(:verification_digest) }
    it { is_expected.to validate_presence_of(:password).on(:create) }

    it { is_expected.to validate_presence_of(:session_token) }
    it { is_expected.to validate_presence_of(:session_expiry) }
    it { is_expected.to validate_presence_of(:language) }

    it { is_expected.to validate_length_of(:name).is_at_least(1).is_at_most(255) }
    it { is_expected.to validate_length_of(:email).is_at_least(5).is_at_most(255) }

    context 'password complexity' do
      it 'passes if there is atleast 1 capital, 1 lowercase, 1 number, 1 symbol' do
        user = build(:user, password: 'Password1!')
        expect(user).to be_valid
      end

      it 'fails if there is no capitals' do
        user = build(:user, password: 'password1!')
        expect(user).to be_invalid
      end

      it 'fails if there is no symbols' do
        user = build(:user, password: 'Password1')
        expect(user).to be_invalid
      end

      it 'fails if there is no lowercase' do
        user = build(:user, password: 'PASSWORD1!')
        expect(user).to be_invalid
      end

      it 'fails if there is no numbers' do
        user = build(:user, password: 'Password!')
        expect(user).to be_invalid
      end

      context 'update' do
        context 'password changed' do
          it 'fails if new password is invalid' do
            user = create(:user)

            user.update(name: 'TOUCHED', password: 'INVALID')
            expect(user).to be_invalid
            expect(user.reload.name).not_to eq('TOUCHED')
            expect(user.authenticate('INVALID')).not_to be_truthy
          end

          it 'passes if new password is valid' do
            user = create(:user)

            user.update(name: 'TOUCHED', password: 'Password1!')
            expect(user).to be_valid
            expect(user.reload.name).to eq('TOUCHED')
            expect(user.authenticate('Password1!')).to be_truthy
          end
        end

        context 'password unchanged' do
          it 'does not validate password' do
            user = create(:user)

            user.update(name: 'TOUCHED')
            expect(user).to be_valid
            expect(user.reload.name).to eq('TOUCHED')
          end
        end
      end
    end

    context 'email format' do
      it 'accepts valid email format' do
        user = build(:user, email: 'user-1.dep-1@users.org-1.tld')
        expect(user).to be_valid
      end

      it 'refuses invalid email formats' do
        user = build(:user, email: 'INVALID')
        expect(user).to be_invalid
        expect(user.errors.attribute_names).to match_array([:email])
      end
    end

    context 'avatar validations' do
      it 'fails if the avatar is not an image' do
        user = build(:user, avatar: fixture_file_upload(file_fixture('default-pdf.pdf'), 'pdf'))
        expect(user).to be_invalid
      end

      it 'fails if the image is too large' do
        user = build(:user, avatar: fixture_file_upload(file_fixture('large-avatar.jpg'), 'jpg'))
        expect(user).to be_invalid
      end
    end

    describe 'before_validations' do
      describe '#set_session_token' do
        it 'sets a rooms session_token and session_expiry before creating' do
          user = create(:user, session_token: nil, session_expiry: nil)
          expect(user.session_token).to be_present
          expect(user.session_expiry).to be_present
        end
      end
    end
  end

  describe 'scopes' do
    context 'with_provider' do
      it 'only includes users with the specified provider' do
        create_list(:user, 5, provider: 'greenlight')
        role_with_provider_test = create(:role, provider: 'test')
        create_list(:user, 5, provider: 'test', role: role_with_provider_test)

        users = described_class.with_provider('greenlight')
        expect(users.count).to eq(5)
        expect(users.pluck(:provider).uniq).to eq(['greenlight'])
      end
    end
  end

  describe '#search' do
    it 'returns the searched users' do
      searched_users = create_list(:user, 5, name: 'Jane Doe')
      create_list(:user, 5)
      expect(described_class.search('jane doe').pluck(:id)).to match_array(searched_users.pluck(:id))
    end

    it 'returns all users if input is empty' do
      create_list(:user, 10)
      expect(described_class.search('').pluck(:id)).to match_array(described_class.pluck(:id))
    end
  end

  context 'instance methods' do
    describe '#generate_reset_token!' do
      let!(:user) { create(:user, email: 'test@greenlight.com') }

      it 'generates/returns a token and saves its digest' do
        freeze_time
        token = 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu'
        allow(SecureRandom).to receive(:alphanumeric).and_return token

        expect(user.generate_reset_token!).to eq(token)
        expect(user.reload.reset_digest).to eq(described_class.generate_digest(token))
        expect(user.reset_sent_at).to eq(Time.current)
      end
    end

    describe '#generate_activation_token!' do
      let!(:user) { create(:user, email: 'test@greenlight.com') }

      it 'generates/returns a token and saves its digest' do
        freeze_time
        token = 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu'
        allow(SecureRandom).to receive(:alphanumeric).and_return token

        expect(user.generate_activation_token!).to eq(token)
        expect(user.reload.verification_digest).to eq(described_class.generate_digest(token))
        expect(user.verification_sent_at).to eq(Time.current)
      end
    end

    describe '#invalidate_reset_token' do
      it 'removes the user token data and returns the record' do
        user = create(:user, reset_digest: 'something', reset_sent_at: Time.current)
        expect(user.invalidate_reset_token).to be(true)
        expect(user.reload.reset_digest).to be_nil
        expect(user.reset_sent_at).to be_nil
      end
    end

    describe '#invalidate_activation_token' do
      it 'removes the user activation token data and returns the record' do
        user = create(:user, verification_digest: 'something', verification_sent_at: Time.current)

        expect(user.invalidate_activation_token).to be(true)
        expect(user.reload.verification_digest).to be_nil
        expect(user.verification_sent_at).to be_nil
      end
    end

    describe '#verify!' do
      it 'activates the user' do
        user = create(:user)
        user.verify!
        expect(user).to be_verified
      end
    end

    describe '#deverify!' do
      it 'deactivates the user' do
        user = create(:user)
        user.deverify!
        expect(user).not_to be_verified
      end
    end
  end

  context 'static methods' do
    describe '#generate_digest' do
      it 'calls Digest::SHA2#hexdigest to generate a digest' do
        expect(described_class.generate_digest('test')).to eq(Digest::SHA2.hexdigest('test'))
      end
    end

    describe '#reset_token_expired?' do
      let(:period) { User::RESET_TOKEN_VALIDITY_PERIOD }

      it 'returns FALSE when the current time does not exceed the given time within the allowed period' do
        freeze_time
        expect(described_class).not_to be_reset_token_expired(Time.current - period)
      end

      it 'returns TRUE when the current time exceed the given time within the allowed period' do
        freeze_time
        expect(described_class).to be_reset_token_expired(Time.current - (period + 1.second))
      end
    end

    describe '#activation_token_expired?' do
      let(:period) { User::ACTIVATION_TOKEN_VALIDITY_PERIOD }

      it 'returns FALSE when the current time does not exceed the given time within the allowed period' do
        freeze_time
        expect(described_class).not_to be_activation_token_expired(Time.current - period)
      end

      it 'returns TRUE when the current time exceed the given time within the allowed period' do
        freeze_time
        expect(described_class).to be_activation_token_expired(Time.current - (period + 1.second))
      end
    end

    describe '#verify_reset_token' do
      let(:period) { User::RESET_TOKEN_VALIDITY_PERIOD }
      let!(:user) do
        create(:user, reset_digest: 'token_digest', reset_sent_at: Time.zone.at(1_655_290_260))
      end

      before do
        travel_to Time.zone.at(1_655_290_260)
        allow(described_class).to receive(:generate_digest).and_return('random_stuff')
        allow(described_class).to receive(:generate_digest).with('token').and_return('token_digest')
      end

      it 'returns the user found by token digest when the token is valid' do
        travel period

        expect(described_class.verify_reset_token('token')).to eq(user)
        expect(user.reload.reset_digest).to be_present
        expect(user.reset_sent_at).to be_present
      end

      it 'does not return the user but reset its token if expired' do
        travel period + 1.second

        expect(described_class.verify_reset_token('token')).to be(false)
        expect(user.reload.reset_digest).to be_blank
        expect(user.reset_sent_at).to be_blank
      end

      it 'return FALSE for inexistent tokens' do
        travel period

        expect(described_class.verify_reset_token('SOME_BAD_TOKEN')).to be(false)
      end
    end

    describe '#verify_activation_token' do
      let(:period) { User::ACTIVATION_TOKEN_VALIDITY_PERIOD }
      let!(:user) do
        create(:user, verification_digest: 'token_digest', verification_sent_at: Time.zone.at(1_655_290_260))
      end

      before do
        travel_to Time.zone.at(1_655_290_260)
        allow(described_class).to receive(:generate_digest).and_return('random_stuff')
        allow(described_class).to receive(:generate_digest).with('token').and_return('token_digest')
      end

      it 'returns the user found by token digest when the token is valid' do
        travel period

        expect(described_class.verify_activation_token('token')).to eq(user)
        expect(user.reload.verification_digest).to be_present
        expect(user.verification_sent_at).to be_present
      end

      it 'does not return the user but reset its token if expired' do
        travel period + 1.second

        expect(described_class.verify_activation_token('token')).to be(false)
        expect(user.reload.verification_digest).to be_blank
        expect(user.verification_sent_at).to be_blank
      end

      it 'return FALSE for inexistent tokens' do
        travel period

        expect(described_class.verify_activation_token('SOME_BAD_TOKEN')).to be(false)
      end
    end
  end

  describe '#check_user_role_provider' do
    it 'returns a user if the user provider is the same as its role' do
      role = create(:role, provider: 'google')
      user = build(:user, provider: 'google', role:)
      expect(user).to be_valid
      expect(user.provider).to eq(user.role.provider)
    end

    it 'fails if the user provider is not the same as its role provider' do
      role = create(:role, provider: 'google')
      user = build(:user, provider: 'microsoft', role:)
      expect(user).to be_invalid
      expect(user.provider).not_to eq(user.role.provider)
      expect(user.errors[:user_provider]).not_to be_empty
    end
  end

  describe '#scan_avatar_for_virus' do
    let(:user) { create(:user) }

    before do
      allow_any_instance_of(described_class).to receive(:virus_scan?).and_return(true)
    end

    it 'makes a call to ClamAV if CLAMAV_SCANNING=true' do
      expect(Clamby).to receive(:safe?)

      user.avatar.attach(fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
    end

    it 'adds an error if the file is not safe' do
      allow(Clamby).to receive(:safe?).and_return(false)
      user.avatar.attach(fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
      expect(user.errors[:avatar]).to eq(['MalwareDetected'])
    end

    it 'does not makes a call to ClamAV if the image is not changing' do
      expect(Clamby).not_to receive(:safe?)

      user.update(name: 'New Name')
    end

    it 'does not makes a call to ClamAV if CLAMAV_SCANNING=false' do
      allow_any_instance_of(described_class).to receive(:virus_scan?).and_return(false)

      expect(Clamby).not_to receive(:safe?)

      user.avatar.attach(fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
    end
  end
end
