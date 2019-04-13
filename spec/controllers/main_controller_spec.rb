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

describe MainController, type: :controller do
  before { allow(Rails.configuration).to receive(:allow_user_signup).and_return(true) }

  describe "GET #index" do
    describe "LDAP is NOT active" do

      it "returns success if user is logged in" do
        user = create(:user)
        @request.session[:user_id] = user.id

        get :index

        expect(response).to have_http_status(200)
      end

      it "returns succes if user is NOT logged in" do
        get :index

        expect(response).to have_http_status(200)
      end
    end 

    describe "LDAP is active" do
      before { Rails.application.config.omniauth_ldap = true }
      after { Rails.application.config.omniauth_ldap = false }

      it "returns success if user is logged in" do
        user = create(:user, provider: "ldap")
        @request.session[:user_id] = user.id

        get :index

        expect(response).to have_http_status(200)
      end

      it "redirects to LDAP login page if user is NOT logged in" do
        get :index

        expect(response).to have_http_status(302)
      end
    end 
  end
end
