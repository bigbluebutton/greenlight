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

describe BigBlueButtonApi, type: :service do
  let(:bbb_service) { described_class.new(provider: 'greenlight') }

  before do
    Rails.configuration.bigbluebutton_endpoint = 'http://test.com/bigbluebutton/api'
    Rails.configuration.bigbluebutton_secret = 'test'
  end

  describe 'Instance of BigBlueButtonApi being created' do
    it 'Created an instance of BigBlueButtonApi' do
      expect(BigBlueButton::BigBlueButtonApi).to receive(:new).with(
        Rails.configuration.bigbluebutton_endpoint,
        Rails.configuration.bigbluebutton_secret,
        '1.8'
      )
      bbb_service.bbb_server
    end

    it 'BigBlueButton client initialized once per request' do
      bbb_api = bbb_service.bbb_server
      bbb_api2 = bbb_service.bbb_server
      bbb_api3 = bbb_service.bbb_server

      expect(bbb_api).to eq(bbb_api2).and eq(bbb_api3)
    end
  end

  describe '#update_recordings' do
    it 'calls bbb_api #update_recordings with the passed options' do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:update_recordings).and_return(true)
      expect_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:update_recordings).with('recording_id', nil,
                                                                                                  { 'meta_recording-name': 'recording_new_name' })
      bbb_service.update_recordings(record_id: 'recording_id', meta_hash: { 'meta_recording-name': 'recording_new_name' })
    end
  end

  describe '#update_recording_visibility' do
    let(:recording) { create(:recording) }

    def expect_to_update_recording_props_to(publish:, protect:, list:, visibility:)
      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: recording.record_id, publish:)
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: recording.record_id,
                                                                                   meta_hash: {
                                                                                     protect:, 'meta_gl-listed': list
                                                                                   })

      bbb_service.update_recording_visibility(record_id: recording.record_id, visibility:)
    end

    it 'changes the recording visibility to "Published"' do
      expect_to_update_recording_props_to(publish: true, protect: false, list: false, visibility: Recording::VISIBILITIES[:published])
    end

    it 'changes the recording visibility to "Unpublished"' do
      expect_to_update_recording_props_to(publish: false, protect: false, list: false, visibility: Recording::VISIBILITIES[:unpublished])
    end

    it 'changes the recording visibility to "Protected"' do
      expect_to_update_recording_props_to(publish: true, protect: true, list: false, visibility: Recording::VISIBILITIES[:protected])
    end

    it 'changes the recording visibility to "Public"' do
      expect_to_update_recording_props_to(publish: true, protect: false, list: true, visibility: Recording::VISIBILITIES[:public])
    end

    it 'changes the recording visibility to "Public/Protected"' do
      expect_to_update_recording_props_to(publish: true, protect: true, list: true, visibility: Recording::VISIBILITIES[:public_protected])
    end
  end
end
