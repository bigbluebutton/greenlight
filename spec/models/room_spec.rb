# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  let!(:room) { create(:room) }

  context 'callbacks' do
    context 'before_validations' do
      describe '#set_friendly_id' do
        it 'sets a rooms friendly_id before creating' do
          expect(room.friendly_id).to be_present
        end

        it 'prevents duplicate friendly_ids' do
          duplicate_room = create(:room)
          expect { duplicate_room.friendly_id = room.friendly_id }.to change { duplicate_room.valid? }.to false
        end
      end

      describe '#set_meeting_id' do
        it 'sets a rooms meeting_id before creating' do
          expect(room.meeting_id).to be_present
        end

        it 'prevents duplicate meeting_ids' do
          duplicate_room = create(:room)
          expect { duplicate_room.meeting_id = room.meeting_id }.to change { duplicate_room.valid? }.to false
        end
      end
    end

    context 'after_create' do
      describe 'create_meeting_options' do
        it 'creates a RoomMeetingOption for each MeetingOption' do
          create_list(:meeting_option, 5)

          expect { create(:room) }.to change(RoomMeetingOption, :count).from(0).to(5)
        end

        context 'Auto generate forced enabled access codes' do
          before do
            create(:meeting_option, default_value: '', name: 'glViewerAccessCode')
            create(:meeting_option, default_value: '', name: 'glModeratorAccessCode')
            allow_any_instance_of(described_class).to receive(:generate_code).and_return('CODE')
          end

          it 'auto generates "glViewerAccessCode" when forced enabled' do
            allow(MeetingOption).to receive(:access_codes_configs).and_return([%w[glViewerAccessCode true], %w[glModeratorAccessCode false]])

            room = create(:room)
            room.reload
            expect(room.viewer_access_code).to eq('CODE')
            expect(room.moderator_access_code).to be_blank
          end

          it 'auto generates "glModeratorAccessCode" when forced enabled' do
            allow(MeetingOption).to receive(:access_codes_configs).and_return([%w[glViewerAccessCode false], %w[glModeratorAccessCode true]])

            room = create(:room)
            room.reload
            expect(room.moderator_access_code).to eq('CODE')
            expect(room.viewer_access_code).to be_blank
          end
        end
      end
    end

    context 'after_find' do
      describe 'Auto generate viewer access code' do
        before do
          meeting_option = create(:meeting_option, name: 'glViewerAccessCode')
          create(:room_meeting_option, meeting_option:, room:, value: nil)
          allow_any_instance_of(described_class).to receive(:generate_code).and_return('FILLED')
        end

        it 'auto generates "glViewerAccessCode" when #auto_generate_viewer_access_code? is :true' do
          allow(MeetingOption).to receive(:access_codes_configs).and_return([%w[glViewerAccessCode true]])
          expect_any_instance_of(described_class).to receive(:generate_viewer_access_code).and_call_original

          expect(room.reload.viewer_access_code).to eq('FILLED')
        end

        it 'does NOT auto generates "glViewerAccessCode" when #auto_generate_viewer_access_code? is :false' do
          allow(MeetingOption).to receive(:access_codes_configs).and_return([%w[glViewerAccessCode false]])
          expect_any_instance_of(described_class).not_to receive(:generate_viewer_access_code)

          expect(room.reload.viewer_access_code).to be_nil
        end
      end

      describe 'Auto generate moderator access code' do
        before do
          meeting_option = create(:meeting_option, name: 'glModeratorAccessCode')
          create(:room_meeting_option, meeting_option:, room:, value: nil)
          allow_any_instance_of(described_class).to receive(:generate_code).and_return('FILLED')
        end

        it 'auto generates "glModeratorAccessCode" when #auto_generate_moderator_access_code? is :true' do
          allow(MeetingOption).to receive(:access_codes_configs).and_return([%w[glModeratorAccessCode true]])
          expect_any_instance_of(described_class).to receive(:generate_moderator_access_code).and_call_original

          expect(room.reload.moderator_access_code).to eq('FILLED')
        end

        it 'does NOT auto "glModeratorAccessCode" code when #auto_generate_moderator_access_code? is :false' do
          allow(MeetingOption).to receive(:access_codes_configs).and_return([%w[glModeratorAccessCode false]])
          expect_any_instance_of(described_class).not_to receive(:generate_moderator_access_code)

          expect(room.reload.moderator_access_code).to be_nil
        end
      end
    end
  end

  context 'private methods' do
    describe '#generate_code' do
      before do
        allow_any_instance_of(described_class).to receive(:generate_code).and_call_original
      end

      it 'calls SecureRandom#alphanumeric(6) and downcase its returned value' do
        allow(SecureRandom).to receive(:alphanumeric).and_return('TEST')
        expect(SecureRandom).to receive(:alphanumeric).with(6)
        expect(room.generate_code).to eq('test')
      end
    end

    describe '#auto_generate_access_codes' do
      before do
        allow_any_instance_of(described_class).to receive(:auto_generate_access_codes).and_call_original
      end

      it 'calls #generate_viewer_access_code if viewer_access_code config is force enabled while the room viewer access code is blank?' do
        allow(MeetingOption).to receive(:access_codes_configs).and_return([%w[glViewerAccessCode true]])
        allow_any_instance_of(described_class).to receive(:viewer_access_code).and_return('')

        expect_any_instance_of(described_class).to receive(:viewer_access_code)
        expect_any_instance_of(described_class).to receive(:generate_viewer_access_code)
        expect(MeetingOption).to receive(:access_codes_configs).with(provider: 'greenlight')

        room.auto_generate_access_codes
      end

      it 'calls #generate_moderator_access_code if moderator_access_code config is force enabled while the room moderator access code is blank?' do
        allow(MeetingOption).to receive(:access_codes_configs).and_return([%w[glModeratorAccessCode true]])
        allow_any_instance_of(described_class).to receive(:moderator_access_code).and_return('')

        expect_any_instance_of(described_class).to receive(:moderator_access_code)
        expect_any_instance_of(described_class).to receive(:generate_moderator_access_code)
        expect(MeetingOption).to receive(:access_codes_configs).with(provider: 'greenlight')

        room.auto_generate_access_codes
      end
    end
  end

  describe '#anyone_joins_as_moderator?' do
    let!(:room) { create(:room) }

    it 'calls MeetingOption::get_setting_value and returns true if "glAnyoneJoinAsModerator" is set to "true"' do
      allow(MeetingOption).to receive(:get_setting_value).and_return(instance_double(RoomMeetingOption, value: 'true'))
      expect(MeetingOption).to receive(:get_setting_value).with(name: 'glAnyoneJoinAsModerator', room_id: room.id)

      expect(room).to be_anyone_joins_as_moderator
    end

    it 'calls MeetingOption::get_setting_value and returns false if "glAnyoneJoinAsModerator" is NOT set to "true"' do
      allow(MeetingOption).to receive(:get_setting_value).and_return(instance_double(RoomMeetingOption, value: 'false'))
      expect(MeetingOption).to receive(:get_setting_value).with(name: 'glAnyoneJoinAsModerator', room_id: room.id)

      expect(room).not_to be_anyone_joins_as_moderator
    end

    it 'calls MeetingOption::get_setting_value and returns false if "glAnyoneJoinAsModerator" is NOT set' do
      allow(MeetingOption).to receive(:get_setting_value).and_return(nil)
      expect(MeetingOption).to receive(:get_setting_value).with(name: 'glAnyoneJoinAsModerator', room_id: room.id)

      expect(room).not_to be_anyone_joins_as_moderator
    end
  end

  describe '#viewer_access_code' do
    before do
      meeting_option = create(:meeting_option, name: 'glViewerAccessCode')
      create(:room_meeting_option, meeting_option:, room:, value: 'VIEWER_CODE')
    end

    it 'returns the "glViewerAccessCode" setting value' do
      expect(room.reload.viewer_access_code).to eq('VIEWER_CODE')
    end
  end

  describe '#moderator_access_code' do
    before do
      meeting_option = create(:meeting_option, name: 'glModeratorAccessCode')
      create(:room_meeting_option, meeting_option:, room:, value: 'MODERATOR_CODE')
    end

    it 'returns the "glModeratorCode" setting value' do
      expect(room.reload.moderator_access_code).to eq('MODERATOR_CODE')
    end
  end

  describe '#generate_viewer_access_code' do
    before do
      meeting_option = create(:meeting_option, name: 'glViewerAccessCode')
      create(:room_meeting_option, meeting_option:, room:, value: 'VIEWER_CODE')
    end

    it 'updates the "glViewerAccessCode" room setting value with #generate_code' do
      allow_any_instance_of(described_class).to receive(:generate_code).and_return('NEW_CODE')

      expect(room.reload.generate_viewer_access_code).to be_truthy
      expect(room.viewer_access_code).to eq('NEW_CODE')
    end
  end

  describe '#generate_moderator_access_code' do
    before do
      meeting_option = create(:meeting_option, name: 'glModeratorAccessCode')
      create(:room_meeting_option, meeting_option:, room:, value: 'MODERATOR_CODE')
    end

    it 'updates the "glModeratorAccessCode" room setting value with #generate_code' do
      allow_any_instance_of(described_class).to receive(:generate_code).and_return('NEW_CODE')

      expect(room.reload.generate_moderator_access_code).to be_truthy
      expect(room.moderator_access_code).to eq('NEW_CODE')
    end
  end

  describe '#remove_viewer_access_code' do
    before do
      meeting_option = create(:meeting_option, name: 'glViewerAccessCode')
      create(:room_meeting_option, meeting_option:, room:, value: 'VIEWER_CODE')
    end

    it 'removes the "glViewerAccessCode" room setting value with #generate_code' do
      room.remove_viewer_access_code
      expect(room.reload.viewer_access_code).to be_nil
    end
  end

  describe '#remove_moderator_access_code' do
    before do
      meeting_option = create(:meeting_option, name: 'glModeratorAccessCode')
      create(:room_meeting_option, meeting_option:, room:, value: 'MODERATOR_CODE')
    end

    it 'removes the "glModeratorAccessCode" room setting value with #generate_code' do
      room.remove_moderator_access_code
      expect(room.reload.moderator_access_code).to be_nil
    end
  end

  describe '#get_setting' do
    it 'fetches a room setting by :name' do
      room = create(:room)
      meeting_option = create(:meeting_option, name: 'setting')
      room_meeting_option = create(:room_meeting_option, room:, meeting_option:)

      expect(room.get_setting(name: 'setting')).to eq(room_meeting_option)
    end

    it 'returns nil for unfound setting' do
      room = create(:room)

      expect(room.get_setting(name: '404')).to be_nil
    end
  end

  describe 'validations' do
    subject { create(:room) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:recordings).dependent(:destroy) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to have_many(:room_meeting_options).dependent(:destroy) }
    it { is_expected.to have_one(:viewer_access_code_setting).dependent(:destroy) }
    it { is_expected.to have_one(:moderator_access_code_setting).dependent(:destroy) }
    # Can't test validation on friendly_id and meeting_id due to before_validations
  end
end
