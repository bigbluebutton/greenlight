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

describe UsersHelper do
    describe "disabled roles" do
        it "should return roles with a less than or equal to priority for non admins" do
            user = create(:user)
            allow_any_instance_of(SessionsHelper).to receive(:current_user).and_return(user)

            disabled_roles = helper.disabled_roles(user)

            expect(disabled_roles.count).to eq(1)
        end

        it "should return roles with a lesser priority for admins" do
            admin = create(:user)
            admin.add_role :admin
            user = create(:user)

            allow_any_instance_of(SessionsHelper).to receive(:current_user).and_return(admin)

            disabled_roles = helper.disabled_roles(user)

            expect(disabled_roles.count).to eq(1)
        end
    end
end
