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
        primary_color = "#000000"

        post :coloring, params: { color: primary_color }

        feature = Setting.find_by(provider: "provider1").features.find_by(name: "Primary Color")

        expect(feature[:value]).to eq(primary_color)
        expect(response).to redirect_to(admins_path(setting: "site_settings"))
      end
    end
  end
end
