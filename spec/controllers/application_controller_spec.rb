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

    def user_not_found
      set_user_domain
    end
  end

  context "roles" do
    before do
      @user = create(:user)
    end

    it "redirects a banned user to a 401 and logs them out" do
      @user.set_role :denied
      @request.session[:user_id] = @user.id

      get :index
      expect(@request.session[:user_id]).to be_nil
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(root_path)
    end

    it "redirects a pending user to a 401 and logs them out" do
      @user.set_role :pending
      @request.session[:user_id] = @user.id

      get :index
      expect(@request.session[:user_id]).to be_nil
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(root_path)
    end
  end

  context "getters" do
    it "returns whether user signup is allowed" do
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)

      expect(controller.allow_user_signup?).to eql(true)
    end

    it "returns whether the default bbb endpoint is being used" do
      allow(Rails.configuration).to receive(:bigbluebutton_endpoint)
        .and_return("http://test-install.blindsidenetworks.com/bigbluebutton/api/")
      allow(Rails.configuration).to receive(:bigbluebutton_endpoint_default)
        .and_return("http://test-install.blindsidenetworks.com/bigbluebutton/api/")

      expect(controller.bigbluebutton_endpoint_default?).to eql(true)
    end
  end

  context "setters" do
    it "sets the user locale correctly" do
      user = create(:user, language: "ru")

      expect(controller.user_locale(user)).to eql("ru")
    end

    it "defaults to English locale if invalid language is set" do
      user = create(:user, language: "asdasd")

      expect(controller.user_locale(user)).to eql("en")
    end
  end

  context "allow_greenlight_accounts" do
    it "allows if user sign up is turned on" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(false)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)

      expect(controller.allow_greenlight_accounts?).to eql(true)
    end

    it "doesn't allow if user sign up is turned off" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(false)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(false)

      expect(controller.allow_greenlight_accounts?).to eql(false)
    end

    it "doesn't allow if user_domain is blank" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)

      expect(controller.allow_greenlight_accounts?).to eql(false)
    end

    it "allows if user provider is set to greenlight" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)
      allow(controller).to receive(:retrieve_provider_info).and_return("provider" => "greenlight")
      controller.instance_variable_set(:@user_domain, "provider1")

      expect(controller.allow_greenlight_accounts?).to eql(true)
    end

    it "doesnt allow if user provider is not set to greenlight" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)
      allow(controller).to receive(:retrieve_provider_info).and_return("provider" => "google")
      controller.instance_variable_set(:@user_domain, "provider1")

      expect(controller.allow_greenlight_accounts?).to eql(false)
    end
  end

  context "errors" do
    it "renders a BigBlueButton error if a BigBlueButtonException occurrs" do
      routes.draw { get "error" => "anonymous#error" }

      get :error
      expect(response).to render_template("errors/bigbluebutton_error")
    end

    it "renders a 404 error if user is not found" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow(Rails.env).to receive(:test?).and_return(false)
      allow_any_instance_of(ApplicationController).to receive(:parse_user_domain).and_return("fake_provider")
      allow_any_instance_of(BbbApi).to receive(:retrieve_provider_info).and_raise("No user with that id exists")

      routes.draw { get "user_not_found" => "anonymous#user_not_found" }

      get :user_not_found
      expect(response).to render_template("errors/greenlight_error")
    end

    it "renders a 404 error if user is not given" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow(Rails.env).to receive(:test?).and_return(false)
      allow_any_instance_of(ApplicationController).to receive(:parse_user_domain).and_return("")
      allow_any_instance_of(BbbApi).to receive(:retrieve_provider_info).and_raise("Provider not included.")

      routes.draw { get "user_not_found" => "anonymous#user_not_found" }

      get :user_not_found
      expect(response).to render_template("errors/greenlight_error")
    end

    it "renders a 500 error if any other error related to bbb api" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow(Rails.env).to receive(:test?).and_return(false)
      allow_any_instance_of(ApplicationController).to receive(:parse_user_domain).and_return("")
      allow_any_instance_of(BbbApi).to receive(:retrieve_provider_info).and_raise("Other error")

      routes.draw { get "user_not_found" => "anonymous#user_not_found" }

      get :user_not_found
      expect(response).to render_template("errors/greenlight_error")
    end
  end
end
