# frozen_string_literal: true

require 'rails_helper'

describe UserCreator, type: :service do
  describe '#call' do
    let!(:users) { create(:role, name: 'User') }
    let(:fake_setting_getter) { instance_double(SettingGetter) }

    before do
      setting = create(:setting, name: 'RoleMapping')
      create(:site_setting, setting:, provider: 'greenlight', value: 'Decepticons=@decepticons.cybertron,Autobots=autobots.cybertron')
      allow(SettingGetter).to receive(:new).and_call_original
      allow(SettingGetter).to receive(:new).with(setting_name: 'DefaultRole', provider: 'greenlight').and_return(fake_setting_getter)
      allow(fake_setting_getter).to receive(:call).and_return('User')
    end

    it 'creates a user with the default User role' do
      user_params = {
        name: 'Lorem',
        email: 'lorem@ipsum.com',
        password: 'Password1+',
        language: 'eng'
      }
      res = described_class.new(user_params:, provider: 'greenlight').call
      expect(res.role).to eq(users)
    end

    context 'default role is not User' do
      let!(:teachers) { create(:role, name: 'Teacher') }

      before do
        allow(fake_setting_getter).to receive(:call).and_return('Teacher')
      end

      it 'creates a user with the default Teacher role' do
        user_params = {
          name: 'Lorem',
          email: 'lorem@ipsum.com',
          password: 'Password1+',
          language: 'eng'
        }
        res = described_class.new(user_params:, provider: 'greenlight').call
        expect(res.role).to eq(teachers)
      end
    end


    it 'creates a user with the role matching a rule if role found' do
      decepticons = create(:role, name: 'Decepticons')
      user_params = {
        name: 'Megatron',
        email: 'megatron@decepticons.cybertron',
        password: 'Decepticons',
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
