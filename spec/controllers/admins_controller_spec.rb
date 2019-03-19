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
  context "GET #index" do
    before do
      @user = create(:user)
      @admin = create(:user)
      @admin.add_role :admin
    end

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
end
