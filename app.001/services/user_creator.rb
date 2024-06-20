# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

class UserCreator
  def initialize(user_params:, provider:, role:)
    @user_params = user_params
    @provider = provider
    @role = role
    @roles_mappers = SettingGetter.new(setting_name: 'RoleMapping', provider:).call
  end

  def call
    @user_params[:email] = @user_params[:email].downcase
    email_role = infer_role_from_email(@user_params[:email])

    User.new({
      provider: @provider,
      role: email_role || @role
    }.merge(@user_params))
  end

  private

  def infer_role_from_email(email)
    matched_rule = if @roles_mappers
                     rules = @roles_mappers.split(',').map { |rule| rule.split('=') }

                     rules.find { |rule| email.ends_with? rule.second if rule.second }
                   end

    Role.find_by(name: matched_rule&.first, provider: @provider)
  end
end
