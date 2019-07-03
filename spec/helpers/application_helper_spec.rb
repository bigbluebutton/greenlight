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

describe ApplicationHelper do
  describe "#getter functions" do
    it "returns whether user signup is allowed" do
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)

      expect(helper.allow_user_signup?).to eql(true)
    end

    it "returns whether the default bbb endpoint is being used" do
      allow(Rails.configuration).to receive(:bigbluebutton_endpoint)
        .and_return("http://test-install.blindsidenetworks.com/bigbluebutton/api/")
      allow(Rails.configuration).to receive(:bigbluebutton_endpoint_default)
        .and_return("http://test-install.blindsidenetworks.com/bigbluebutton/api/")

      expect(helper.bigbluebutton_endpoint_default?).to eql(true)
    end

    it "returns the correct omniauth login url" do
      allow(Rails.configuration).to receive(:relative_url_root).and_return("/b")
      provider = Faker::Company.name

      expect(helper.omniauth_login_url(provider)).to eql("/b/auth/#{provider}")
    end
  end

  describe "#allow_greenlight_accounts" do
    it "allows if user sign up is turned on" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(false)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)

      expect(helper.allow_greenlight_accounts?).to eql(true)
    end

    it "doesn't allow if user sign up is turned off" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(false)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(false)

      expect(helper.allow_greenlight_accounts?).to eql(false)
    end

    it "doesn't allow if user_domain is blank" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)

      expect(helper.allow_greenlight_accounts?).to eql(false)
    end

    it "allows if user provider is set to greenlight" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)
      allow(helper).to receive(:retrieve_provider_info).and_return("provider" => "greenlight")

      @user_domain = "provider1"

      expect(helper.allow_greenlight_accounts?).to eql(true)
    end

    it "doesnt allow if user provider is not set to greenlight" do
      allow(Rails.configuration).to receive(:loadbalanced_configuration).and_return(true)
      allow(Rails.configuration).to receive(:allow_user_signup).and_return(true)
      allow(helper).to receive(:retrieve_provider_info).and_return("provider" => "google")

      @user_domain = "provider1"

      expect(helper.allow_greenlight_accounts?).to eql(false)
    end
  end
end
