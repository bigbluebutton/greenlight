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

describe ProviderCredentials, type: :service do
  # Enable caching for this test
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  let(:service) { described_class.new(provider: 'bbb') }
  let(:request_url) { 'http://test.com/api/getUser?checksum=14727e995e790f61f6f0be878d52efb248b00e92&name=bbb' }

  before do
    ENV['LOADBALANCER_ENDPOINT'] = 'http://test.com/'
    ENV['LOADBALANCER_SECRET'] = 'test'

    # Enable caching
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe '#call' do
    context 'no caching' do
      it 'returns credentials if a success returncode is returned' do
        stub_request(:get, request_url).to_return(body: success_response)

        expect(service.call).to eq(['https://test.com', 'secret'])
      end

      it 'returns false if an error returncode is returned' do
        stub_request(:get, request_url).to_return(body: error_response)

        expect(service.call).to be false
      end
    end

    context 'caching' do
      it 'returns true if a success returncode is returned' do
        stub_request(:get, request_url).to_return(body: success_response)

        expect(Net::HTTP).to receive(:get_response).exactly(:once).and_call_original # Make sure http request is only made once

        service.call
        service.call
        service.call

        expect(service.call).to eq(['https://test.com', 'secret'])
        expect(Rails.cache.read('v3/bbb/getUser')).to eq(['https://test.com', 'secret'])
      end
    end
  end

  private

  def success_response
    "<response>\n
      <returncode>SUCCESS</returncode>\n
      <user>\n
        <apiURL>https://test.com</apiURL>\n
        <secret>secret</secret>\n
      </user>\n
    </response>\n"
  end

  def error_response
    "<response>\n<returncode>ERROR</returncode>\n</response>\n"
  end
end
