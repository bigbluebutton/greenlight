# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require "rails_helper"

describe SessionsController, type: :controller do
  before(:all) do
    @user = create(:user, provider: "greenlight", password: "example", password_confirmation: "example")
    @omni_user = create(:user, password: "example", password_confirmation: "example")
  end

  describe "GET #destroy" do
    before(:each) do
      @request.session[:user_id] = @user.id
      get :destroy
    end

    it "should logout user" do
      expect(@request.session[:user_id]).to be_nil
    end

    it "should redirect to root" do
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST #create" do
    it "should login user in if credentials valid" do
      post :create, params: {
        session: {
          email: @user.email,
          password: "example",
        },
      }

      expect(@request.session[:user_id]).to eql(@user.id)
    end

    it "should not login user in if credentials invalid" do
      post :create, params: {
        session: {
          email: @user.email,
          password: "invalid",
        },
      }

      expect(@request.session[:user_id]).to be_nil
    end

    it "should not login user in if account mismatch" do
      post :create, params: {
        session: {
          email: @omni_user.email,
          password: "example",
        },
      }

      expect(@request.session[:user_id]).to be_nil
    end
  end

  describe "GET/POST #omniauth" do
    before(:all) do
      OmniAuth.config.test_mode = true

      OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
        provider: "twitter",
        uid: "twitter-user",
        info: {
          email: "user@twitter.com",
          name: "Twitter User",
          nickname: "username",
          image: "example.png",
        },
      )

      OmniAuth.config.mock_auth[:bn_launcher] = OmniAuth::AuthHash.new(
        provider: "bn_launcher",
        uid: "bn-launcher-user",
        info: {
          email: "user1@google.com",
          name: "User1",
          nickname: "nick",
          image: "touch.png",
          customer: 'ocps',
        }
      )

      OmniAuth.config.on_failure = proc { |env|
        OmniAuth::FailureEndpoint.new(env).redirect_to_failure
      }
    end

    it "should create and login user with omniauth twitter" do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
      get :omniauth, params: { provider: :twitter }

      u = User.last
      expect(u.provider).to eql("twitter")
      expect(u.email).to eql("user@twitter.com")
      expect(@request.session[:user_id]).to eql(u.id)
    end

    it "should create and login user with omniauth bn launcher" do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:bn_launcher]
      get :omniauth, params: { provider: 'bn_launcher' }

      u = User.last
      expect(u.provider).to eql("ocps")
      expect(u.email).to eql("user1@google.com")
      expect(@request.session[:user_id]).to eql(u.id)
    end

    it "should redirect to root on invalid omniauth login" do
      request.env["omniauth.auth"] = :invalid_credentials
      get :omniauth, params: { provider: :twitter }

      expect(response).to redirect_to(root_path)
    end

    it "should not create session without omniauth env set for google" do
      get :omniauth, params: { provider: 'google' }

      expect(response).to redirect_to(root_path)
    end

    it "should not create session without omniauth env set for bn_launcher" do
      get :omniauth, params: { provider: 'bn_launcher' }

      expect(response).to redirect_to(root_path)
    end
  end
end
