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

describe ThemesController, type: :controller do
  context "GET #index" do
    before do
      @user = create(:user)
    end

    it "responds with css file" do
      @request.session[:user_id] = @user.id

      get :index, format: :css

      expect(response.content_type).to eq("text/css")
    end
  end

  context "CSS file creation" do
    before do
      @fake_color = Faker::Color.hex_color
      allow(Rails.configuration).to receive(:primary_color_default).and_return(@fake_color)
    end

    it "returns the correct color based on provider" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow_any_instance_of(User).to receive(:greenlight_account?).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:set_user_domain).and_return("provider1")

      color1 = Faker::Color.hex_color
      provider1 = Faker::Company.name

      controller.instance_variable_set(:@user_domain, provider1)

      Setting.create(provider: provider1).features.create(name: "Primary Color", value: color1, enabled: true)
      user1 = create(:user, provider: provider1)

      @request.session[:user_id] = user1.id

      get :index, format: :css

      expect(response.content_type).to eq("text/css")
      expect(response.body).to include(color1)
    end

    it "uses the default color option" do
      provider1 = Faker::Company.name
      user1 = create(:user, provider: provider1)

      @request.session[:user_id] = user1.id

      get :index, format: :css

      expect(response.content_type).to eq("text/css")
      expect(response.body).to include(@fake_color)
    end
  end
end
