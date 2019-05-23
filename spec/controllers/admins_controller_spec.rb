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

describe AdminsController, type: :controller do
  before do
    @user = create(:user, provider: "provider1")
    @admin = create(:user, provider: "provider1")
    @admin.add_role :admin
  end

  describe "User Roles" do
    before do
      allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)
    end

    context "GET #index" do
      it "renders a 404 if a user tries to acccess it" do
        @request.session[:user_id] = @user.id
        get :index

        expect(response).to render_template(:not_found)
      end

      it "renders the admin settings if an admin tries to acccess it" do
        @request.session[:user_id] = @admin.id
        get :index

        expect(response).to render_template(:index)
      end
    end

    context "GET #edit_user" do
      it "renders the index page" do
        @request.session[:user_id] = @admin.id

        get :edit_user, params: { user_uid: @user.uid }

        expect(response).to render_template(:index)
      end
    end

    context "POST #promote" do
      it "promotes a user to admin" do
        @request.session[:user_id] = @admin.id

        expect(@user.has_role?(:admin)).to eq(false)

        post :promote, params: { user_uid: @user.uid }

        expect(@user.has_role?(:admin)).to eq(true)
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admins_path)
      end

      it "sends an email to the user being promoted" do
        @request.session[:user_id] = @admin.id

        params = { user_uid: @user.uid }

        expect { post :promote, params: params }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context "POST #demote" do
      it "demotes an admin to user" do
        @request.session[:user_id] = @admin.id

        @user.add_role :admin
        expect(@user.has_role?(:admin)).to eq(true)

        post :demote, params: { user_uid: @user.uid }

        expect(@user.has_role?(:admin)).to eq(false)
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admins_path)
      end

      it "sends an email to the user being demoted" do
        @request.session[:user_id] = @admin.id

        @user.add_role :admin

        params = { user_uid: @user.uid }

        expect { post :demote, params: params }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context "POST #ban" do
      it "bans a user from the application" do
        @request.session[:user_id] = @admin.id

        expect(@user.has_role?(:denied)).to eq(false)

        post :ban_user, params: { user_uid: @user.uid }

        expect(@user.has_role?(:denied)).to eq(true)
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admins_path)
      end
    end

    context "POST #unban" do
      it "unbans the user from the application" do
        @request.session[:user_id] = @admin.id
        @user.add_role :denied

        expect(@user.has_role?(:denied)).to eq(true)

        post :unban_user, params: { user_uid: @user.uid }

        expect(@user.has_role?(:denied)).to eq(false)
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admins_path)
      end
    end

    context "POST #invite" do
      before do
        allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
        allow_any_instance_of(ApplicationController).to receive(:allow_greenlight_users?).and_return(true)
        allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)
      end

      it "invites a user" do
        @request.session[:user_id] = @admin.id
        email = Faker::Internet.email
        post :invite, params: { invite_user: { email: email } }

        invite = Invitation.find_by(email: email, provider: "greenlight")

        expect(invite.present?).to eq(true)
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admins_path)
      end

      it "sends an invitation email" do
        @request.session[:user_id] = @admin.id
        email = Faker::Internet.email

        params = { invite_user: { email: email } }
        expect { post :invite, params: params }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context "POST #approve" do
      it "approves a pending user" do
        @request.session[:user_id] = @admin.id

        @user.add_role :pending

        post :approve, params: { user_uid: @user.uid }

        expect(@user.has_role?(:pending)).to eq(false)
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admins_path)
      end

      it "sends the user an email telling them theyre approved" do
        @request.session[:user_id] = @admin.id

        @user.add_role :pending
        params = { user_uid: @user.uid }
        expect { post :approve, params: params }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  describe "User Design" do
    context "POST #branding" do
      it "changes the branding image on the page" do
        allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
        allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)

        @request.session[:user_id] = @admin.id
        fake_image_url = "example.com"

        post :branding, params: { url: fake_image_url }

        feature = Setting.find_by(provider: "provider1").features.find_by(name: "Branding Image")

        expect(feature[:value]).to eq(fake_image_url)
        expect(response).to redirect_to(admins_path)
      end
    end

    context "POST #coloring" do
      it "changes the primary on the page" do
        allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
        allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)

        @request.session[:user_id] = @admin.id
        primary_color = Faker::Color.hex_color

        post :coloring, params: { color: primary_color }

        feature = Setting.find_by(provider: "provider1").features.find_by(name: "Primary Color")

        expect(feature[:value]).to eq(primary_color)
        expect(response).to redirect_to(admins_path)
      end

      it "changes the primary-lighten on the page" do
        allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
        allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)

        @request.session[:user_id] = @admin.id
        primary_color = Faker::Color.hex_color

        post :coloring_lighten, params: { color: primary_color }

        feature = Setting.find_by(provider: "provider1").features.find_by(name: "Primary Color Lighten")

        expect(feature[:value]).to eq(primary_color)
        expect(response).to redirect_to(admins_path)
      end

      it "changes the primary-darken on the page" do
        allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
        allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)

        @request.session[:user_id] = @admin.id
        primary_color = Faker::Color.hex_color

        post :coloring_darken, params: { color: primary_color }

        feature = Setting.find_by(provider: "provider1").features.find_by(name: "Primary Color Darken")

        expect(feature[:value]).to eq(primary_color)
        expect(response).to redirect_to(admins_path)
      end
    end

    context "POST #registration_method" do
      it "changes the registration method for the given context" do
        allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)
        allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
        allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)

        @request.session[:user_id] = @admin.id

        post :registration_method, params: { method: "invite" }

        feature = Setting.find_by(provider: "provider1").features.find_by(name: "Registration Method")

        expect(feature[:value]).to eq(Rails.configuration.registration_methods[:invite])
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admins_path)
      end

      it "does not allow the user to change to invite if emails are off" do
        allow(Rails.configuration).to receive(:enable_email_verification).and_return(false)
        allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
        allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)

        @request.session[:user_id] = @admin.id

        post :registration_method, params: { method: "invite" }

        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(admins_path)
      end
    end

    context "POST #room_authentication" do
      it "changes the room authentication required setting" do
        allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
        allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)

        @request.session[:user_id] = @admin.id

        post :room_authentication, params: { value: "true" }

        feature = Setting.find_by(provider: "provider1").features.find_by(name: "Room Authentication")

        expect(feature[:value]).to eq("true")
        expect(response).to redirect_to(admins_path)
      end
    end
  end
end
