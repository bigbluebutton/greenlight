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

require 'rails_helper'

RSpec.configure do |c|
  c.infer_base_class_for_anonymous_controllers = false
end

describe ApplicationController do
  controller do
    def index
      head :ok
    end

    def error
      raise BigBlueButton::BigBlueButtonException
    end
  end

  context "roles" do
    before do
      @user = create(:user)
    end

    it "redirects a banned user to a 401 and logs them out" do
      @user.add_role :denied
      @request.session[:user_id] = @user.id

      get :index
      expect(@request.session[:user_id]).to be_nil
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(root_path)
    end

    it "redirects a pending user to a 401 and logs them out" do
      @user.add_role :pending
      @request.session[:user_id] = @user.id

      get :index
      expect(@request.session[:user_id]).to be_nil
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(root_path)
    end
  end

  context "errors" do
    it "renders a BigBlueButton error if a BigBlueButtonException occurrs" do
      routes.draw { get "error" => "anonymous#error" }

      get :error
      expect(response).to render_template("errors/bigbluebutton_error")
    end
  end
end
