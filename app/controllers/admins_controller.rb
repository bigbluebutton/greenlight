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

class AdminsController < ApplicationController
  authorize_resource class: false
  before_action :find_user, only: [:edit_user, :promote, :demote]
  before_action :verify_admin_of_user, only: [:edit_user, :promote, :demote]
  before_action :find_setting, only: [:branding, :coloring]

  # GET /admins
  def index
    @users = []
    User.find_each do |user|
      if current_user.admin_of? user
        @users.push(user)
      end
    end
    @users.reverse!
  end

  # GET /admins/edit/:user_uid
  def edit_user
    render "admins/index", locals: { setting_id: "account" }
  end

  # POST /admins/promote/:user_uid
  def promote
    @user.add_role :admin
    redirect_to admins_path, flash: { success: I18n.t("administrator.flash.promoted") }
  end

  # POST /admins/demote/:user_uid
  def demote
    @user.remove_role :admin
    redirect_to admins_path, flash: { success: I18n.t("administrator.flash.demoted") }
  end

  # POST /admins/branding
  def branding
    @settings.update_value("Branding Image", params[:url])
    redirect_to admins_path
  end

  # POST /admins/color
  def coloring
    @settings.update_value("Primary Color", params[:color])
    redirect_to admins_path(setting: "design")
  end

  private

  def find_user
    @user = User.find_by!(uid: params[:user_uid])
  end

  def find_setting
    @settings = Setting.find_or_create_by!(provider: user_settings_provider)
  end

  def verify_admin_of_user
    redirect_to admins_path,
      flash: { alert: I18n.t("administrator.flash.unauthorized") } unless current_user.admin_of?(@user)
  end
end
