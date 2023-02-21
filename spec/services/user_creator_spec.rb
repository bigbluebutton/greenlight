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
    let(:users) { create(:role, name: 'User') }

    before do
      setting = create(:setting, name: 'RoleMapping')
      create(:site_setting, setting:, provider: 'greenlight', value: 'Decepticons=@decepticons.cybertron,Autobots=autobots.cybertron')
    end

    it 'creates a user with the role matching a rule instead of the default role if email role is found' do
      decepticons = create(:role, name: 'Decepticons')
      user_params = {
        name: 'Megatron',
        email: 'megatron@decepticons.cybertron',
        password: 'Decepticons',
        language: 'teletraan'
      }
      res = described_class.new(user_params:, provider: 'greenlight', role: users).call

      expect(res).to be_instance_of(User)
      expect(res).not_to be_persisted
      expect(res.name).to eq(user_params[:name])
      expect(res.email).to eq(user_params[:email])
      expect(res.language).to eq(user_params[:language])
      expect(res.authenticate(user_params[:password])).to be_truthy
      expect(res.role).to eq(decepticons)
    end

    it 'creates user with the \'User\' role if there is no matching rule' do
      user_params = {
        name: 'Megatron Prime',
        email: 'mega-prime@auto-decepticons.cybertron',
        password: 'Cybertron',
        language: 'teletraan'
      }
      res = described_class.new(user_params:, provider: 'greenlight', role: users).call

      expect(res).to be_instance_of(User)
      expect(res).not_to be_persisted
      expect(res.name).to eq(user_params[:name])
      expect(res.email).to eq(user_params[:email])
      expect(res.language).to eq(user_params[:language])
      expect(res.authenticate(user_params[:password])).to be_truthy
      expect(res.role).to eq(users)
    end

    it 'creates a user with the \'User\' role if role not found' do
      user_params = {
        name: 'Optimus Prime',
        email: 'optimus@autobots.cybertron',
        password: 'Autobots',
        language: 'teletraan'
      }
      res = described_class.new(user_params:, provider: 'greenlight', role: users).call

      expect(res).to be_instance_of(User)
      expect(res).not_to be_persisted
      expect(res.name).to eq(user_params[:name])
      expect(res.email).to eq(user_params[:email])
      expect(res.language).to eq(user_params[:language])
      expect(res.authenticate(user_params[:password])).to be_truthy
      expect(res.role).to eq(users)
    end
  end
end
