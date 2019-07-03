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
    it "assigns a blank user to the view" do
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)

      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it "redirects to root if allow_user_signup is false" do
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(false)

      get :new
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #edit" do
    it "renders the edit template" do
      user = create(:user)

      @request.session[:user_id] = user.id

      get :edit, params: { user_uid: user.uid }

      expect(response).to render_template(:edit)
    end

    it "does not allow you to edit other users if you're not an admin" do
      user = create(:user)
      user2 = create(:user)

      @request.session[:user_id] = user.id

      get :edit, params: { user_uid: user2.uid }

      expect(response).to redirect_to(user.main_room)
    end

    it "allows admins to edit other users" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)

      user = create(:user, provider: "provider1")
      user.add_role :admin
      user2 = create(:user, provider: "provider1")

      @request.session[:user_id] = user.id

      get :edit, params: { user_uid: user2.uid }

      expect(response).to render_template(:edit)
    end

    it "redirect to root if user isn't signed in" do
      user = create(:user)

      get :edit, params: { user_uid: user }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #ldap_signin" do
    it "should render ldap signin page" do
      get :ldap_signin
      expect(response).to render_template(:ldap_signin)
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

      it "sends activation email if email verification is on" do
        allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)

        params = random_valid_user_params
        expect { post :create, params: params }.to change { ActionMailer::Base.deliveries.count }.by(1)

        u = User.find_by(name: params[:user][:name], email: params[:user][:email])

        expect(u).to_not be_nil
        expect(u.name).to eql(params[:user][:name])

        expect(flash[:success]).to be_present
        expect(response).to redirect_to(root_path)
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
      before do
        allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)
      end

      it "should raise if there there is a delivery failure" do
        params = random_valid_user_params

        expect do
          post :create, params: params
          raise :anyerror
        end.to raise_error { :anyerror }
      end

      context "enable invite registration" do
        before do
          allow_any_instance_of(Registrar).to receive(:invite_registration).and_return(true)
          allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)
          @user = create(:user, provider: "greenlight")
          @admin = create(:user, provider: "greenlight", email: "test@example.com")
          @admin.add_role :admin
        end

        it "should notify admins that user signed up" do
          params = random_valid_user_params
          invite = Invitation.create(email: params[:user][:email], provider: "greenlight")
          @request.session[:invite_token] = invite.invite_token

          expect { post :create, params: params }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        it "rejects the user if they are not invited" do
          get :new

          expect(flash[:alert]).to be_present
          expect(response).to redirect_to(root_path)
        end

        it "allows the user to signup if they are invited" do
          allow(Rails.configuration).to receive(:enable_email_verification).and_return(false)

          params = random_valid_user_params
          invite = Invitation.create(email: params[:user][:name], provider: "greenlight")
          @request.session[:invite_token] = invite.invite_token

          post :create, params: params

          u = User.find_by(name: params[:user][:name], email: params[:user][:email])
          expect(response).to redirect_to(u.main_room)
        end

        it "verifies the user if they sign up with the email they receieved the invite with" do
          allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)

          params = random_valid_user_params
          invite = Invitation.create(email: params[:user][:email], provider: "greenlight")
          @request.session[:invite_token] = invite.invite_token

          post :create, params: params

          u = User.find_by(name: params[:user][:name], email: params[:user][:email])
          expect(response).to redirect_to(u.main_room)
        end

        it "asks the user to verify if they signup with a different email" do
          allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)

          params = random_valid_user_params
          invite = Invitation.create(email: Faker::Internet.email, provider: "greenlight")
          @request.session[:invite_token] = invite.invite_token

          post :create, params: params

          expect(User.exists?(name: params[:user][:name], email: params[:user][:email])).to eq(true)
          expect(flash[:success]).to be_present
          expect(response).to redirect_to(root_path)
        end
      end

      context "enable approval registration" do
        before do
          allow_any_instance_of(Registrar).to receive(:approval_registration).and_return(true)
          allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)
          @user = create(:user, provider: "greenlight")
          @admin = create(:user, provider: "greenlight", email: "test@example.com")
          @admin.add_role :admin
        end

        it "allows any user to sign up" do
          allow(Rails.configuration).to receive(:enable_email_verification).and_return(false)

          params = random_valid_user_params

          post :create, params: params

          expect(User.exists?(name: params[:user][:name], email: params[:user][:email])).to eq(true)
          expect(flash[:success]).to be_present
          expect(response).to redirect_to(root_path)
        end

        it "sets the user to pending on sign up" do
          allow(Rails.configuration).to receive(:enable_email_verification).and_return(false)

          params = random_valid_user_params

          post :create, params: params

          u = User.find_by(name: params[:user][:name], email: params[:user][:email])

          expect(u.has_role?(:pending)).to eq(true)
        end

        it "notifies admins that a user signed up" do
          allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)

          params = random_valid_user_params

          expect { post :create, params: params }.to change { ActionMailer::Base.deliveries.count }.by(2)
        end
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
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(edit_user_path(user))
    end

    it "renders #edit on unsuccessful save" do
      @user = create(:user)

      patch :update, params: invalid_params.merge!(user_uid: @user)
      expect(response).to render_template(:edit)
    end
  end

  describe "DELETE #user" do
    before { allow(Rails.configuration).to receive(:allow_user_signup).and_return(true) }

    it "properly deletes user" do
      user = create(:user)
      @request.session[:user_id] = user.id

      delete :destroy, params: { user_uid: user.uid }

      expect(response).to redirect_to(root_path)
    end

    it "allows admins to delete users" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)
      allow_any_instance_of(Room).to receive(:delete_all_recordings).and_return('')

      user = create(:user, provider: "provider1")
      admin = create(:user, provider: "provider1")
      admin.add_role :admin
      @request.session[:user_id] = admin.id

      delete :destroy, params: { user_uid: user.uid }

      expect(flash[:success]).to be_present
      expect(response).to redirect_to(admins_path)
    end

    it "doesn't allow admins of other providers to delete users" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)

      user = create(:user, provider: "provider1")
      admin = create(:user, provider: "provider2")
      admin.add_role :admin
      @request.session[:user_id] = admin.id

      delete :destroy, params: { user_uid: user.uid }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET | POST #terms" do
    before { allow(Rails.configuration).to receive(:allow_user_signup).and_return(true) }
    before { allow(Rails.configuration).to receive(:terms).and_return(false) }

    it "Redirects to 404 if terms is disabled" do
      post :terms, params: { accept: "false" }

      expect(response).to redirect_to('/404')
    end
  end

  describe "GET #recordings" do
    before do
      @user1 = create(:user)
      @user2 = create(:user)
    end

    it "redirects to root if the incorrect user tries to access the page" do
      get :recordings, params: { current_user: @user2, user_uid: @user1.uid }

      expect(response).to redirect_to(root_path)
    end
  end
end
