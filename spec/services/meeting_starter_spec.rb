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
require 'bigbluebutton_api'

describe MeetingStarter, type: :service do
  let(:user) { create(:user) }
  let(:room) { create(:room) }

  let(:base_url) { 'http://test.host' }

  let(:service) do
    described_class.new(
      room:,
      base_url:,
      current_user: user,
      provider: 'greenlight'
    )
  end

  let(:options) do
    url = File.join(base_url, '/rooms/', room.friendly_id, '/join')
    {
      moderatorOnlyMessage: "To invite someone to the meeting, send them this link:<br>#{url}",
      logoutURL: url,
      meta_endCallbackUrl: File.join(base_url, '/meeting_ended'),
      'meta_bbb-recording-ready-url': File.join(base_url, '/recording_ready'),
      'meta_bbb-origin-version': 'v3',
      'meta_bbb-origin': 'greenlight',
      setting: 'value'
    }
  end

  describe '#call' do
    let(:room_setting_getter_service) { instance_double(RoomSettingsGetter) }

    before do
      allow(RoomSettingsGetter).to receive(:new).and_return(room_setting_getter_service)
      allow(room_setting_getter_service).to receive(:call).and_return({ setting: 'value' })
    end

    it 'calls BigBlueButtonApi and RoomSettingsGetter with the right params' do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(meeting_starter_response)

      expect(RoomSettingsGetter)
        .to receive(:new)
        .with(room_id: room.id, provider: 'greenlight', current_user: user, only_bbb_options: true)

      expect(room_setting_getter_service)
        .to receive(:call)

      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options:, presentation_url: nil)

      service.call
    end

    it 'merges the options with the computed options' do
      allow_any_instance_of(described_class)
        .to receive(:computed_options)
        .and_return({ test: 'test' })

      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(meeting_starter_response)

      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options: { setting: 'value', test: 'test' }, presentation_url: nil)

      service.call
    end

    it 'broadcasts to ActionCable that the meeting has started' do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(meeting_starter_response)

      expect(ActionCable.server)
        .to receive(:broadcast)
        .with("#{room.friendly_id}_rooms_channel", 'started')

      service.call
    end

    it 'passes the presentation url to BigBlueButton' do
      room.presentation.attach(fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))

      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(meeting_starter_response)

      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options:, presentation_url: Rails.application.routes.url_helpers.rails_blob_url(room.presentation, host: 'test.host'))

      service.call
    end

    it 'updates the last session date when a meeting is started' do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options:, presentation_url: nil)
        .and_return(meeting_starter_response)

      service.call

      expect(room.last_session).to eql(DateTime.strptime(meeting_starter_response[:createTime].to_s, '%Q').utc)
    end

    context 'retry' do
      it 'retries 3 times if the call fails' do
        allow(BigBlueButtonApi)
          .to receive(:new)
          .and_raise(BigBlueButton::BigBlueButtonException)

        expect(BigBlueButtonApi)
          .to receive(:new)
          .exactly(3).times

        expect { service.call }.to raise_error(BigBlueButton::BigBlueButtonException)
      end

      it 'doesnt retry if the messageKey is idNotUnique' do
        exception = BigBlueButton::BigBlueButtonException.new('idNotUnique')
        exception.key = 'idNotUnique'

        allow(BigBlueButtonApi)
          .to receive(:new)
          .and_raise(exception)

        expect(BigBlueButtonApi)
          .to receive(:new)
          .once

        expect { service.call }.to raise_error(BigBlueButton::BigBlueButtonException)
      end
    end
  end

  private

  def meeting_starter_response
    {
      returncode: true,
      meetingID: 'hulsdzwvitlk1dbekzxdprshsxmvycvar0jeaszc',
      attendeePW: '12345',
      moderatorPW: '54321',
      createTime: 1_389_464_535_956,
      hasBeenForciblyEnded: false,
      messageKey: '',
      message: ''
    }
  end
end
