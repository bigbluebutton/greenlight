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
    it "returns the correct omniauth login url" do
      allow(Rails.configuration).to receive(:relative_url_root).and_return("/b")
      provider = Faker::Company.name

      expect(helper.omniauth_login_url(provider)).to eql("/b/auth/#{provider}")
    end
  end
  describe "#html_decode" do
    let(:expr_with_html_entities) { '&lt;&gt;&amp;&quot;' }
    let(:expr_with_html_entities_decoded) { '<>&"' }
    let(:expr_with_no_html_entities) { "this is some regular text!!" }
    context "with html charachter entities" do
     it "should return the decoded version of the expression" do
       expect(html_entities_decode(expr_with_html_entities)).to eq(expr_with_html_entities_decoded)
     end
    end
    context "with no html charachter entities" do
      it "should return the expression stringified" do
        expect(html_entities_decode(expr_with_no_html_entities)).to eq(expr_with_no_html_entities)
      end
    end
  end
  describe "role_colur" do
    it "should use default if the user doesn't have a role" do
      expect(helper.role_colour(Role.create(name: "test"))).to eq(Rails.configuration.primary_color_default)
    end

    it "should use role colour if provided" do
      expect(helper.role_colour(Role.create(name: "test", colour: "#1234"))).to eq("#1234")
    end
  end
end
