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

def random_valid_user_params
  pass = Faker::Internet.password(8)
  {
    user: {
      name: Faker::Name.first_name,
      email: Faker::Internet.email,
      password: pass,
      password_confirmation: pass,
      accepted_terms: true,
      email_verified: true,
    },
  }
end

describe UsersController, type: :controller do
  let(:invalid_params) do
    {
      user: {
        name: "Invalid",
        email: "example.com",
        password: "pass",
        password_confirmation: "invalid",
        accepted_terms: false,
        email_verified: false,
      },
    }
  end

  describe "GET #new" do
    before { allow(Rails.configuration).to receive(:allow_user_signup).and_return(true) }

    it "assigns a blank user to the view" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "POST #create" do
    context "allow greenlight accounts" do
      before { allow(Rails.configuration).to receive(:allow_user_signup).and_return(true) }
      before { allow(Rails.configuration).to receive(:enable_email_verification).and_return(false) }

      it "redirects to user room on successful create" do
        params = random_valid_user_params
        post :create, params: params

        u = User.find_by(name: params[:user][:name], email: params[:user][:email])

        expect(u).to_not be_nil
        expect(u.name).to eql(params[:user][:name])

        expect(response).to redirect_to(room_path(u.main_room))
      end

      it "user saves with greenlight provider" do
        params = random_valid_user_params
        post :create, params: params

        u = User.find_by(name: params[:user][:name], email: params[:user][:email])

        expect(u.provider).to eql("greenlight")
      end

      it "renders #new on unsuccessful save" do
        post :create, params: invalid_params

        expect(response).to render_template(:new)
      end
    end

    context "disallow greenlight accounts" do
      before { allow(Rails.configuration).to receive(:allow_user_signup).and_return(false) }

      it "redirect to root on attempted create" do
        params = random_valid_user_params
        post :create, params: params

        u = User.find_by(name: params[:user][:name], email: params[:user][:email])

        expect(u).to be_nil
      end
    end

    context "allow email verification" do
      before { allow(Rails.configuration).to receive(:enable_email_verification).and_return(true) }

      it "should raise if there there is a delivery failure" do
        params = random_valid_user_params

        expect do
          post :create, params: params
          raise :anyerror
        end.to raise_error { :anyerror }
      end
    end

    it "redirects to main room if already authenticated" do
      user = create(:user)
      @request.session[:user_id] = user.id

      post :create, params: random_valid_user_params
      expect(response).to redirect_to(room_path(user.main_room))
    end
  end

  describe "PATCH #update" do
    it "properly updates user attributes" do
      user = create(:user)

      params = random_valid_user_params
      patch :update, params: params.merge!(user_uid: user)
      user.reload

      expect(user.name).to eql(params[:user][:name])
      expect(user.email).to eql(params[:user][:email])
    end

    it "renders #edit on unsuccessful save" do
      @user = create(:user)

      patch :update, params: invalid_params.merge!(user_uid: @user)
      expect(response).to render_template(:edit)
    end
  end

  describe "GET | POST #resend" do
    before { allow(Rails.configuration).to receive(:allow_user_signup).and_return(true) }
    before { allow(Rails.configuration).to receive(:enable_email_verification).and_return(true) }

    it "redirects to main room if verified" do
      params = random_valid_user_params
      post :create, params: params

      u = User.find_by(name: params[:user][:name], email: params[:user][:email])
      u.email_verified = false

      get :resend
      expect(response).to render_template(:verify)
    end

    it "resend email upon click if unverified" do
      params = random_valid_user_params
      post :create, params: params

      u = User.find_by(name: params[:user][:name], email: params[:user][:email])
      u.email_verified = false

      expect { post :resend, params: { email_verified: false } }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(response).to render_template(:verify)
    end

    it "should raise if there there is a delivery failure" do
      params = random_valid_user_params
      post :create, params: params

      u = User.find_by(name: params[:user][:name], email: params[:user][:email])
      u.email_verified = false

      expect do
        post :resend, params: { email_verified: false }
        raise Net::SMTPAuthenticationError
      end.to raise_error { Net::SMTPAuthenticationError }
    end
  end

  describe "GET | POST #confirm" do
    before { allow(Rails.configuration).to receive(:allow_user_signup).and_return(true) }
    before { allow(Rails.configuration).to receive(:enable_email_verification).and_return(true) }

    it "redirects to main room if already verified" do
      params = random_valid_user_params
      post :create, params: params

      u = User.find_by(name: params[:user][:name], email: params[:user][:email])

      post :confirm, params: { user_uid: u.uid, email_verified: true }
      expect(response).to redirect_to(room_path(u.main_room))
    end

    it "renders confirmation pane if unverified" do
      params = random_valid_user_params
      post :create, params: params

      u = User.find_by(name: params[:user][:name], email: params[:user][:email])
      u.email_verified = false

      get :confirm, params: { user_uid: u.uid }
      expect(response).to render_template(:verify)
    end
  end
end
