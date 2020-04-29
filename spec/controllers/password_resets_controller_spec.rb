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

describe PasswordResetsController, type: :controller do
  describe "POST #create" do
    context "allow mail notifications" do
      before { allow(Rails.configuration).to receive(:enable_email_verification).and_return(true) }

      it "redirects to root url if email is sent" do
        user = create(:user)

        params = {
          password_reset: {
            email: user.email,
          },
        }

        post :create, params: params
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root with success flash if email does not exists" do
        params = {
          password_reset: {
            email: nil,
          },
        }

        post :create, params: params
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(root_path)
      end
    end

    context "does not allow mail notifications" do
      before { allow(Rails.configuration).to receive(:enable_email_verification).and_return(false) }

      it "renders a 404 page upon if email notifications are disabled" do
        get :create
        expect(response).to redirect_to("/404")
      end
    end
  end

  describe "PATCH #update" do
    before do
      allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)
    end

    context "valid user" do
      it "reloads page with notice if password is empty" do
        token = "reset_token"
        allow(controller).to receive(:check_expiration).and_return(nil)

        params = {
          id: token,
          user: {
            password: nil,
          },
        }

        patch :update, params: params
        expect(response).to render_template(:edit)
      end

      it "reloads page with notice if password is confirmation doesn't match" do
        token = "reset_token"

        allow(controller).to receive(:check_expiration).and_return(nil)

        params = {
          id: token,
          user: {
            password: :password,
            password_confirmation: nil,
          },
        }

        patch :update, params: params
        expect(response).to render_template(:edit)
      end

      it "updates attributes if the password update is a success" do
        user = create(:user, provider: "greenlight")
        old_digest = user.password_digest

        allow(controller).to receive(:check_expiration).and_return(nil)

        params = {
          id: user.create_reset_digest,
          user: {
            password: :password,
            password_confirmation: :password,
          },
        }

        patch :update, params: params

        user.reload

        expect(old_digest.eql?(user.password_digest)).to be false
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
