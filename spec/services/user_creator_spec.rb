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

describe UserCreator, type: :service do
  describe '#call' do
    let(:fallback_role) { create(:role, name: 'Fallback', provider: 'greenlight') }

    before do
      setting = create(:setting, name: 'RoleMapping')
      create(:site_setting, setting:, provider: 'greenlight', value: 'Decepticons=@decepticons.cybertron,Autobots=autobots.cybertron')
    end

    def expectations(expected_role)
      res = described_class.new(user_params:, provider: 'greenlight', role: fallback_role).call

      expect(res).to be_instance_of(User)
      expect(res).not_to be_persisted
      expect(res.name).to eq(user_params[:name])
      expect(res.email).to eq(user_params[:email])
      expect(res.language).to eq(user_params[:language])
      expect(res.authenticate(user_params[:password])).to be_truthy
      expect(res.role).to eq(expected_role)
    end

    context 'Rule matched and role exist' do
      let!(:matched_role) { create(:role, name: 'Decepticons', provider: 'greenlight') }
      let(:user_params) do
        {
          name: 'Megatron',
          email: 'megatron@decepticons.cybertron',
          password: 'Decepticons',
          language: 'teletraan'
        }
      end

      describe 'Matched rule role is blacklisted' do
        before do
          stub_const('UserCreator::BLACKLIST', [matched_role.name])
        end

        it 'creates a user with the provided fallback role' do
          expectations(fallback_role)
        end
      end

      describe 'Matched rule role have a different provider' do
        let!(:matched_role) { create(:role, name: 'Decepticons', provider: 'not_greenlight') }

        it 'creates a user with the provided fallback role' do
          expectations(fallback_role)
        end
      end

      describe 'Matched rule role is NOT blacklisted and have the same provider' do
        it 'creates a user with the role matching a rule instead of the fallback role if email role is found' do
          expectations(matched_role)
        end
      end
    end

    context 'No matched rule' do
      let(:user_params) do
        {
          name: 'Megatron Prime',
          email: 'mega-prime@auto-decepticons.cybertron',
          password: 'Cybertron',
          language: 'teletraan'
        }
      end

      it 'creates user with the provided fallback role' do
        expectations(fallback_role)
      end

      describe 'Fallback role have a different provider' do
        let(:fallback_role) { create(:role, name: 'Fallback', provider: 'not_greenlight') }

        it 'creates user with no role' do
          expectations(nil)
        end
      end
    end

    context 'Rule matched and role is not blacklisted but is unfound' do
      let(:user_params) do
        {
          name: 'Optimus Prime',
          email: 'optimus@autobots.cybertron',
          password: 'Autobots',
          language: 'teletraan'
        }
      end

      it 'creates a user with the provided fallback role' do
        expectations(fallback_role)
      end
    end
  end
end
