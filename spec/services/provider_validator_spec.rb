# frozen_string_literal: true

require 'rails_helper'

describe ProviderValidator, type: :service do
  # Enable caching for this test
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  let(:service) { described_class.new(provider: 'greenlight') }
  let(:request_url) { 'http://test.com/api2/getUserGreenlightCredentials?name=greenlight&checksum=b36706f149f97a535da7144b851be87cf0d4c045' }

  before do
    ENV['LOADBALANCER_ENDPOINT'] = 'http://test.com/'
    ENV['LOADBALANCER_SECRET'] = 'test'

    # Enable caching
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe '#call' do
    context 'no caching' do
      it 'returns true if a success returncode is returned' do
        stub_request(:get, request_url).to_return(body: success_response)

        expect(service.call).to be true
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

        expect(service.call).to be true
        expect(Rails.cache.read('greenlight/getUserGreenlightCredentials')).to be(true)
      end
    end
  end

  private

  def success_response
    "<response>\n<returncode>SUCCESS</returncode>\n</response>\n"
  end

  def error_response
    "<response>\n<returncode>ERROR</returncode>\n</response>\n"
  end
end
