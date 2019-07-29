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
  describe "GET #destroy" do
    before(:each) do
      user = create(:user, provider: "greenlight")
      @request.session[:user_id] = user.id
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
    before { allow(Rails.configuration).to receive(:enable_email_verification).and_return(true) }
    before(:each) do
      @user1 = create(:user, provider: 'greenlight', password: 'example', password_confirmation: 'example')
      @user2 = create(:user, password: 'example', password_confirmation: "example")
    end

    it "should login user in if credentials valid" do
      post :create, params: {
        session: {
          email: @user1.email,
          password: 'example',
        },
      }

      expect(@request.session[:user_id]).to eql(@user1.id)
    end

    it "should not login user in if credentials invalid" do
      post :create, params: {
        session: {
          email: @user1.email,
          password: 'invalid',
        },
      }

      expect(@request.session[:user_id]).to be_nil
    end

    it "should not login user in if account mismatch" do
      post :create, params: {
        session: {
          email: @user2.email,
          password: "example",
        },
      }

      expect(@request.session[:user_id]).to be_nil
    end

    it "should not login user if account is not verified" do
      @user3 = create(:user, email_verified: false, provider: "greenlight",
        password: "example", password_confirmation: 'example')

      post :create, params: {
        session: {
          email: @user3.email,
          password: 'example',
        },
      }

      expect(@request.session[:user_id]).to be_nil
      expect(response).to redirect_to(account_activation_path(email: @user3.email))
    end

    it "redirects the user to the page they clicked sign in from" do
      user = create(:user, provider: "greenlight",
        password: "example", password_confirmation: 'example')

      url = Faker::Internet.domain_name

      @request.cookies[:return_to] = url

      post :create, params: {
        session: {
          email: user.email,
          password: 'example',
        },
      }

      expect(@request.session[:user_id]).to eql(user.id)
      expect(response).to redirect_to(url)
    end

    it "redirects the user to their home room if they clicked the sign in button from root" do
      user = create(:user, provider: "greenlight",
        password: "example", password_confirmation: 'example')

      @request.cookies[:return_to] = root_url

      post :create, params: {
        session: {
          email: user.email,
          password: 'example',
        },
      }

      expect(@request.session[:user_id]).to eql(user.id)
      expect(response).to redirect_to(user.main_room)
    end

    it "redirects the user to their home room if return_to cookie doesn't exist" do
      user = create(:user, provider: "greenlight",
        password: "example", password_confirmation: 'example')

      post :create, params: {
        session: {
          email: user.email,
          password: 'example',
        },
      }

      expect(@request.session[:user_id]).to eql(user.id)
      expect(response).to redirect_to(user.main_room)
    end

    it "redirects to the admins page for admins" do
      user = create(:user, provider: "greenlight",
        password: "example", password_confirmation: 'example')
      user.add_role :super_admin

      post :create, params: {
        session: {
          email: user.email,
          password: 'example',
        },
      }

      expect(@request.session[:user_id]).to eql(user.id)
      expect(response).to redirect_to(admins_path)
    end

    it "should migrate old rooms from the twitter account to the new user" do
      twitter_user = User.create(name: "Twitter User", email: "user@twitter.com", image: "example.png",
        username: "twitteruser", email_verified: true, provider: 'twitter', social_uid: "twitter-user")

      room = Room.new(name: "Test")
      room.owner = twitter_user
      room.save!

      post :create, params: {
        session: {
          email: @user1.email,
          password: 'example',
        },
      }, session: {
        old_twitter_user_id: twitter_user.id
      }

      @user1.reload
      expect(@user1.rooms.count).to eq(3)
      expect(@user1.rooms.find { |r| r.name == "Old Home Room" }).to_not be_nil
      expect(@user1.rooms.find { |r| r.name == "Test" }).to_not be_nil
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
          nickname: "twitteruser",
          image: "example.png",
        },
      )

      OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(
        provider: "google",
        uid: "google-user",
        info: {
          email: "user@google.com",
          name: "Google User",
          nickname: "googleuser",
          image: "touch.png",
          customer: 'customer1',
        }
      )

      OmniAuth.config.mock_auth[:bn_launcher] = OmniAuth::AuthHash.new(
        provider: "bn_launcher",
        uid: "bn-launcher-user",
        info: {
          email: "user@google.com",
          name: "Google User",
          nickname: "googleuser",
          image: "touch.png",
          customer: 'customer1',
        }
      )

      OmniAuth.config.on_failure = proc { |env|
        OmniAuth::FailureEndpoint.new(env).redirect_to_failure
      }
    end

    it "should create and login user with omniauth google" do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google]
      get :omniauth, params: { provider: :google }

      u = User.last
      expect(u.provider).to eql("google")
      expect(u.email).to eql("user@google.com")
      expect(@request.session[:user_id]).to eql(u.id)
    end

    it "should create and login user with omniauth bn launcher" do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:bn_launcher]
      get :omniauth, params: { provider: 'bn_launcher' }

      u = User.last
      expect(u.provider).to eql("customer1")
      expect(u.email).to eql("user@google.com")
      expect(@request.session[:user_id]).to eql(u.id)
    end

    it "should redirect to root on invalid omniauth login" do
      request.env["omniauth.auth"] = :invalid_credentials
      get :omniauth, params: { provider: :google }

      expect(response).to redirect_to(root_path)
    end

    it "should not create session without omniauth env set for google" do
      get :omniauth, params: { provider: 'google' }

      expect(response).to redirect_to(root_path)
    end

    context 'twitter deprecation' do
      it "should not allow new user sign up with omniauth twitter" do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
        get :omniauth, params: { provider: :twitter }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t("registration.deprecated.twitter_signup"))
      end

      it "should notify twitter users that twitter is deprecated" do
        allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)
        twitter_user = User.create(name: "Twitter User", email: "user@twitter.com", image: "example.png",
          username: "twitteruser", email_verified: true, provider: 'twitter', social_uid: "twitter-user")

        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
        get :omniauth, params: { provider: :twitter }

        expect(flash[:alert]).to eq(I18n.t("registration.deprecated.twitter_signin",
          link: signup_path(old_twitter_user_id: twitter_user.id)))
      end

      it "should migrate rooms from the twitter account to the google account" do
        twitter_user = User.create(name: "Twitter User", email: "user@twitter.com", image: "example.png",
          username: "twitteruser", email_verified: true, provider: 'twitter', social_uid: "twitter-user")

        room = Room.new(name: "Test")
        room.owner = twitter_user
        room.save!

        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google]
        get :omniauth, params: { provider: :google }, session: { old_twitter_user_id: twitter_user.id }

        u = User.last
        expect(u.provider).to eql("google")
        expect(u.email).to eql("user@google.com")
        expect(@request.session[:user_id]).to eql(u.id)
        expect(u.rooms.count).to eq(3)
        expect(u.rooms.find { |r| r.name == "Old Home Room" }).to_not be_nil
        expect(u.rooms.find { |r| r.name == "Test" }).to_not be_nil
      end
    end

    context 'registration notification emails' do
      before do
        allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)
        @user = create(:user, provider: "greenlight")
        @admin = create(:user, provider: "greenlight", email: "test@example.com")
        @admin.add_role :admin
      end

      it "should notify admin on new user signup with approve/reject registration" do
        allow_any_instance_of(Registrar).to receive(:approval_registration).and_return(true)

        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:bn_launcher]

        expect { get :omniauth, params: { provider: 'bn_launcher' } }
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "should notify admin on new user signup with invite registration" do
        allow_any_instance_of(Registrar).to receive(:invite_registration).and_return(true)

        invite = Invitation.create(email: "user@google.com", provider: "greenlight")
        @request.session[:invite_token] = invite.invite_token

        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:bn_launcher]

        expect { get :omniauth, params: { provider: 'bn_launcher' } }
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    it "should not create session without omniauth env set for bn_launcher" do
      get :omniauth, params: { provider: 'bn_launcher' }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST #ldap" do
    it "should create and login a user with a ldap login" do
      entry = Net::LDAP::Entry.new("cn=Test User,ou=people,dc=planetexpress,dc=com")
      entry[:cn] = "Test User"
      entry[:givenName] = "Test"
      entry[:sn] = "User"
      entry[:mail] = "test@example.com"
      allow_any_instance_of(Net::LDAP).to receive(:bind_as).and_return([entry])

      post :ldap, params: {
        session: {
          user: "test",
          password: 'password',
        },
      }

      u = User.last
      expect(u.provider).to eql("ldap")
      expect(u.email).to eql("test@example.com")
      expect(@request.session[:user_id]).to eql(u.id)
    end

    it "should redirect to signin on invalid credentials" do
      allow_any_instance_of(Net::LDAP).to receive(:bind_as).and_return(false)

      post :ldap, params: {
        session: {
          user: "test",
          password: 'passwor',
        },
      }

      expect(response).to redirect_to(ldap_signin_path)
      expect(flash[:alert]).to eq(I18n.t("invalid_credentials"))
    end
  end
end
