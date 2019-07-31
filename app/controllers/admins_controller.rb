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
  include Pagy::Backend
  include Themer
  include Emailer
  include Recorder

  manage_users = [:edit_user, :promote, :demote, :ban_user, :unban_user, :approve]
  site_settings = [:branding, :coloring, :coloring_lighten, :coloring_darken,
                   :registration_method, :room_authentication, :room_limit, :default_recording_visibility]

  authorize_resource class: false
  before_action :find_user, only: manage_users
  before_action :verify_admin_of_user, only: manage_users
  before_action :find_setting, only: site_settings

  # GET /admins
  def index
    @search = params[:search] || ""
    @order_column = params[:column] && params[:direction] != "none" ? params[:column] : "created_at"
    @order_direction = params[:direction] && params[:direction] != "none" ? params[:direction] : "DESC"
    @role = params[:role] || ""

    @pagy, @users = pagy(user_list)
  end

  # GET /admins/site_settings
  def site_settings
  end

  # GET /admins/server_recordings
  def server_recordings
    server_rooms = if Rails.configuration.loadbalanced_configuration
      Room.includes(:owner).where(users: { provider: user_settings_provider }).pluck(:bbb_id)
    else
      Room.pluck(:bbb_id)
    end

    @search, @order_column, @order_direction, recs =
      all_recordings(server_rooms, @user_domain, params.permit(:search, :column, :direction), true, true)
    @pagy, @recordings = pagy_array(recs)
  end

  # MANAGE USERS

  # GET /admins/edit/:user_uid
  def edit_user
  end

  # POST /admins/promote/:user_uid
  def promote
    @user.add_role :admin

    send_user_promoted_email(@user)

    redirect_to admins_path, flash: { success: I18n.t("administrator.flash.promoted") }
  end

  # POST /admins/demote/:user_uid
  def demote
    @user.remove_role :admin

    send_user_demoted_email(@user)

    redirect_to admins_path, flash: { success: I18n.t("administrator.flash.demoted") }
  end

  # POST /admins/ban/:user_uid
  def ban_user
    @user.roles = []
    @user.add_role :denied
    redirect_to admins_path, flash: { success: I18n.t("administrator.flash.banned") }
  end

  # POST /admins/unban/:user_uid
  def unban_user
    @user.remove_role :denied
    @user.add_role :user
    redirect_to admins_path, flash: { success: I18n.t("administrator.flash.unbanned") }
  end

  # POST /admins/approve/:user_uid
  def approve
    @user.remove_role :pending

    send_user_approved_email(@user)

    redirect_to admins_path, flash: { success: I18n.t("administrator.flash.approved") }
  end

  # POST /admins/invite
  def invite
    email = params[:invite_user][:email]

    begin
      invitation = create_or_update_invite(email)

      send_invitation_email(current_user.name, email, invitation.invite_token)
    rescue => e
      logger.error "Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    else
      flash[:success] = I18n.t("administrator.flash.invite", email: email)
    end

    redirect_to admins_path
  end

  # SITE SETTINGS

  # POST /admins/branding
  def branding
    @settings.update_value("Branding Image", params[:url])
    redirect_to admin_site_settings_path, flash: { success: I18n.t("administrator.flash.settings") }
  end

  # POST /admins/color
  def coloring
    @settings.update_value("Primary Color", params[:color])
    @settings.update_value("Primary Color Lighten", color_lighten(params[:color]))
    @settings.update_value("Primary Color Darken", color_darken(params[:color]))
    redirect_to admin_site_settings_path, flash: { success: I18n.t("administrator.flash.settings") }
  end

  def coloring_lighten
    @settings.update_value("Primary Color Lighten", params[:color])
    redirect_to admin_site_settings_path, flash: { success: I18n.t("administrator.flash.settings") }
  end

  def coloring_darken
    @settings.update_value("Primary Color Darken", params[:color])
    redirect_to admin_site_settings_path, flash: { success: I18n.t("administrator.flash.settings") }
  end

  # POST /admins/room_authentication
  def room_authentication
    @settings.update_value("Room Authentication", params[:value])
    redirect_to admin_site_settings_path, flash: { success: I18n.t("administrator.flash.settings") }
  end

  # POST /admins/registration_method/:method
  def registration_method
    new_method = Rails.configuration.registration_methods[params[:method].to_sym]

    # Only allow change to Join by Invitation if user has emails enabled
    if !Rails.configuration.enable_email_verification && new_method == Rails.configuration.registration_methods[:invite]
      redirect_to admin_site_settings_path,
        flash: { alert: I18n.t("administrator.flash.invite_email_verification") }
    else
      @settings.update_value("Registration Method", new_method)
      redirect_to admin_site_settings_path,
        flash: { success: I18n.t("administrator.flash.registration_method_updated") }
    end
  end

  # POST /admins/room_limit
  def room_limit
    @settings.update_value("Room Limit", params[:limit])
    redirect_to admin_site_settings_path, flash: { success: I18n.t("administrator.flash.settings") }
  end

  # POST /admins/default_recording_visibility
  def default_recording_visibility
    @settings.update_value("Default Recording Visibility", params[:visibility])
    redirect_to admin_site_settings_path, flash: {
      success: I18n.t("administrator.flash.settings") + ". " +
               I18n.t("administrator.site_settings.recording_visibility.warning")
    }
  end

  private

  def find_user
    @user = User.where(uid: params[:user_uid]).includes(:roles).first
  end

  def find_setting
    @settings = Setting.find_or_create_by!(provider: user_settings_provider)
  end

  def verify_admin_of_user
    redirect_to admins_path,
      flash: { alert: I18n.t("administrator.flash.unauthorized") } unless current_user.admin_of?(@user)
  end

  # Gets the list of users based on your configuration
  def user_list
    initial_list = if current_user.has_cached_role? :super_admin
      User.where.not(id: current_user.id).includes(:roles)
    else
      User.without_role(:super_admin).where.not(id: current_user.id).includes(:roles)
    end

    if Rails.configuration.loadbalanced_configuration
      initial_list.where(provider: user_settings_provider)
                  .admins_search(@search, @role)
                  .admins_order(@order_column, @order_direction)
    else
      initial_list.admins_search(@search, @role)
                  .admins_order(@order_column, @order_direction)
    end
  end

  # Creates the invite if it doesn't exist, or updates the updated_at time if it does
  def create_or_update_invite(email)
    invite = Invitation.find_by(email: email, provider: @user_domain)

    # Invite already exists
    if invite.present?
      # Updates updated_at to now
      invite.touch
    else
      # Creates invite
      invite = Invitation.create(email: email, provider: @user_domain)
    end

    invite
  end
end
