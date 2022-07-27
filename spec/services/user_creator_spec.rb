# frozen_string_literal: true

require 'rails_helper'

describe UserCreator, type: :service do
  describe '#call' do
    let!(:users) { create(:role, name: 'User') }

    before do
      setting = create(:setting, name: 'RoleMapping')
      create(:site_setting, setting:, provider: 'greenlight', value: 'Decepticons=@decepticons.cybertron,Autobots=autobots.cybertron')
    end

    it 'creates a user with the role matching a rule if role found' do
      decepticons = create(:role, name: 'Decepticons')
      user_params = {
        name: 'Megatron',
        email: 'megatron@decepticons.cybertron',
        password: 'Decepticons',
        password_confirmation: 'Decepticons',
        language: 'teletraan'
      }
      res = described_class.new(user_params:, provider: 'greenlight').call

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
        password_confirmation: 'Cybertron',
        language: 'teletraan'
      }
      res = described_class.new(user_params:, provider: 'greenlight').call

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
        password_confirmation: 'Autobots',
        language: 'teletraan'
      }
      res = described_class.new(user_params:, provider: 'greenlight').call

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
