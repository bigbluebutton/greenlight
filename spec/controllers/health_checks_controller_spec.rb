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

RSpec.describe HealthChecksController, type: :controller do
  describe '#check' do
    # Disable all checks initially
    before do
      allow(ENV).to receive(:fetch).with('DATABASE_HEALTH_CHECK_DISABLED', false).and_return('true')
      allow(ENV).to receive(:fetch).with('REDIS_HEALTH_CHECK_DISABLED', false).and_return('true')
      allow(ENV).to receive(:fetch).with('SMTP_HEALTH_CHECK_DISABLED', false).and_return('true')
      allow(ENV).to receive(:fetch).with('BBB_HEALTH_CHECK_DISABLED', false).and_return('true')
    end

    context 'when all services are running' do
      it 'returns success' do
        get :check
        expect(response.body).to eq('success')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when database connection fails' do
      before do
        allow(ActiveRecord::Base).to receive(:connected?).and_return(false)
        allow(ENV).to receive(:fetch).with('DATABASE_HEALTH_CHECK_DISABLED', false).and_return(false)
      end

      it 'returns failure message' do
        get :check
        expect(response.body).to include('Unable to connect to Database')
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when redis connection fails' do
      before do
        allow(Redis).to receive(:new).and_raise(StandardError.new('Redis connection error'))
        allow(ENV).to receive(:fetch).with('REDIS_HEALTH_CHECK_DISABLED', false).and_return(false)
      end

      it 'returns failure message' do
        get :check
        expect(response.body).to include('Unable to connect to Redis')
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when smtp check fails' do
      before do
        allow(Net::SMTP).to receive(:new).and_raise(StandardError.new('SMTP error'))
        allow(ENV).to receive(:fetch).with('SMTP_SENDER_EMAIL', nil).and_return('test@test.test')
        allow(ENV).to receive(:fetch).with('SMTP_HEALTH_CHECK_DISABLED', false).and_return(false)
      end

      it 'returns failure message' do
        get :check
        expect(response.body).to include('Unable to connect to SMTP Server')
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when big_blue_button check fails' do
      before do
        allow(Net::HTTP).to receive(:get).and_raise(StandardError.new('BBB error'))
        allow(ENV).to receive(:fetch).with('BBB_HEALTH_CHECK_DISABLED', false).and_return(false)
      end

      it 'returns failure message' do
        get :check
        expect(response.body).to include('Unable to connect to BigBlueButton')
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
