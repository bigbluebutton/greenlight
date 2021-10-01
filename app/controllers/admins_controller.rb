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
  include Rolify
  include Populator

  manage_users = [:edit_user, :promote, :demote, :ban_user, :unban_user, :approve, :reset, :merge_user]
  manage_deleted_users = [:undelete]
  authorize_resource class: false
  before_action :find_user, only: manage_users
  before_action :find_deleted_user, only: manage_deleted_users
  before_action :verify_admin_of_user, only: [manage_users, manage_deleted_users]

  # GET /admins
  def index
    # Initializa the data manipulation variables
    @search = params[:search] || ""
    @order_column = params[:column] && params[:direction] != "none" ? params[:column] : "created_at"
    @order_direction = params[:direction] && params[:direction] != "none" ? params[:direction] : "DESC"
    @tab = params[:tab] || "active"
    @role = params[:role] ? Role.find_by(name: params[:role], provider: @user_domain) : nil

    users = if @tab == "invited"
      invited_users_list
    else
      manage_users_list
    end

    @pagy, @users = pagy(users)
  end

  # GET /admins/site_settings
  def site_settings
    @tab = params[:tab] || "appearance"
  end

  # GET /admins/server_recordings
  def server_recordings
    @search = params[:search] || ""

    if @search.present?
      if @search.include? "@"
        user_email = @search
      else
        room_uid = @search
      end
    else
      @latest = true
    end

    @pagy, @recordings = pagy_array(recordings_to_show(user_email, room_uid))
  end

  # GET /admins/rooms
  def server_rooms
    @search = params[:search] || ""
    @order_column = params[:column] && params[:direction] != "none" ? params[:column] : "status"
    @order_direction = params[:direction] && params[:direction] != "none" ? params[:direction] : "DESC"

    begin
      meetings = all_running_meetings[:meetings]
    rescue BigBlueButton::BigBlueButtonException
      flash[:alert] = I18n.t("administrator.rooms.timeout", server: I18n.t("bigbluebutton"))
      meetings = []
    end

    @order_column = "created_at" if meetings.empty?
    @running_room_bbb_ids = meetings.pluck(:meetingID)

    @participants_count = {}
    meetings.each do |meet|
      @participants_count[meet[:meetingID]] = meet[:participantCount]
    end

    @pagy, @rooms = pagy_array(server_rooms_list)
  end

  # GET /admins/room_configuration
  def room_configuration
  end

  # MANAGE USERS

  # GET /admins/edit/:user_uid
  def edit_user
    session[:prev_url] = request.referer if request.referer.present?
  end

  # POST /admins/ban/:user_uid
  def ban_user
    @user.set_role :denied

    redirect_back fallback_location: admins_path, flash: { success: I18n.t("administrator.flash.banned") }
  end

  # POST /admins/unban/:user_uid
  def unban_user
    @user.set_role :user

    redirect_back fallback_location: admins_path, flash: { success: I18n.t("administrator.flash.unbanned") }
  end

  # POST /admins/approve/:user_uid
  def approve
    @user.set_role :user

    send_user_approved_email(@user)

    redirect_back fallback_location: admins_path, flash: { success: I18n.t("administrator.flash.approved") }
  end

  # POST /admins/approve/:user_uid
  def undelete
    # Undelete the user and all of his rooms
    @user.undelete!
    @user.rooms.deleted.each(&:undelete!)

    redirect_back fallback_location: admins_path, flash: { success: I18n.t("administrator.flash.restored") }
  end

  # POST /admins/invite
  def invite
    emails = params[:invite_user][:email].split(",")

    emails.each do |email|
      invitation = create_or_update_invite(email)

      send_invitation_email(current_user.name, email, invitation)
    end

    redirect_back fallback_location: admins_path,
      flash: { success: I18n.t("administrator.flash.invite", email: emails.join(", ")) }
  end

  # GET /admins/reset
  def reset
    send_password_reset_email(@user, @user.create_reset_digest)

    if session[:prev_url].present?
      redirect_path = session[:prev_url]
      session.delete(:prev_url)
    else
      redirect_path = admins_path
    end

    redirect_to redirect_path, flash: { success: I18n.t("administrator.flash.reset_password") }
  end

  # POST /admins/merge/:user_uid
  def merge_user
    begin
      # Get uid of user that will be merged into the other account
      uid_to_merge = params[:merge]
      logger.info "#{current_user.uid} is attempting to merge #{uid_to_merge} into #{@user.uid}"

      # Check to make sure the 2 users are unique
      raise "Can not merge the user into themself" if uid_to_merge == @user.uid

      # Find user to merge
      user_to_merge = User.find_by(uid: uid_to_merge)

      # Move over user's rooms
      user_to_merge.rooms.each do |room|
        room.owner = @user

        room.name = "(#{I18n.t('merged')}) #{room.name}"

        room.save!
      end

      # Reload user to update merge rooms
      user_to_merge.reload

      # Delete merged user
      user_to_merge.destroy(true)
    rescue => e
      logger.info "Failed to merge #{uid_to_merge} into #{@user.uid}: #{e}"
      flash[:alert] = I18n.t("administrator.flash.merge_fail")
    else
      logger.info "#{current_user.uid} successfully merged #{uid_to_merge} into #{@user.uid}"
      flash[:success] = I18n.t("administrator.flash.merge_success")
    end

    redirect_back fallback_location: admins_path
  end

  # GET /admins/merge_list
  def merge_list
    # Returns a list of users that can merged into another user
    initial_list = User.without_role(:super_admin)
                       .where.not(uid: current_user.uid)
                       .merge_list_search(params[:search])

    initial_list = initial_list.where(provider: @user_domain) if Rails.configuration.loadbalanced_configuration

    # Respond with JSON object of users
    respond_to do |format|
      format.json { render body: initial_list.pluck_to_hash(:uid, :name, :email).to_json }
    end
  end

  # SITE SETTINGS

  # POST /admins/update_settings
  def update_settings
    tab = params[:tab] || "settings"
    @settings.update_value(params[:setting], params[:value])

    flash_message = I18n.t("administrator.flash.settings")

    if params[:value] == "Default Recording Visibility"
      flash_message += ". #{I18n.t('administrator.site_settings.recording_visibility.warning')}"
    end

    redirect_to admin_site_settings_path(tab: tab), flash: { success: flash_message }
  end

  # POST /admins/color
  def coloring
    @settings.update_value("Primary Color", params[:value])
    @settings.update_value("Primary Color Lighten", color_lighten(params[:value]))
    @settings.update_value("Primary Color Darken", color_darken(params[:value]))
    redirect_to admin_site_settings_path(tab: "appearance"), flash: { success: I18n.t("administrator.flash.settings") }
  end

  # POST /admins/registration_method/:method
  def registration_method
    new_method = Rails.configuration.registration_methods[params[:value].to_sym]

    # Only allow change to Join by Invitation if user has emails enabled
    if !Rails.configuration.enable_email_verification && new_method == Rails.configuration.registration_methods[:invite]
      redirect_to admin_site_settings_path(tab: "settings"),
        flash: { alert: I18n.t("administrator.flash.invite_email_verification") }
    else
      @settings.update_value("Registration Method", new_method)
      redirect_to admin_site_settings_path(tab: "settings"),
        flash: { success: I18n.t("administrator.flash.registration_method_updated") }
    end
  end

  # POST /admins/clear_auth
  def clear_auth
    User.include_deleted.where(provider: @user_domain).update_all(social_uid: nil)

    redirect_to admin_site_settings_path(tab: "settings"), flash: { success: I18n.t("administrator.flash.settings") }
  end

  # POST /admins/clear_cache
  def clear_cache
    Rails.cache.delete("#{@user_domain}/getUser")
    Rails.cache.delete("#{@user_domain}/getUserGreenlightCredentials")

    redirect_to admin_site_settings_path(tab: "settings"), flash: { success: I18n.t("administrator.flash.settings") }
  end

  # POST /admins/log_level
  def log_level
    Rails.logger.level = params[:value].to_i

    redirect_to admin_site_settings_path(tab: "administration"), flash: { success: I18n.t("administrator.flash.settings") }
  end

  # ROOM CONFIGURATION
  # POST /admins/update_room_configuration
  def update_room_configuration
    @settings.update_value(params[:setting], params[:value])

    flash_message = I18n.t("administrator.flash.room_configuration")

    redirect_to admin_room_configuration_path, flash: { success: flash_message }
  end

  # ROLES

  # GET /admins/roles
  def roles
    @roles = all_roles(params[:selected_role])
  end

  # POST /admins/role
  # This method creates a new role scoped to the users provider
  def new_role
    new_role = create_role(params[:role][:name])

    return redirect_to admin_roles_path, flash: { alert: I18n.t("administrator.roles.invalid_create") } if new_role.nil?

    redirect_to admin_roles_path(selected_role: new_role.id)
  end

  # PATCH /admin/roles/order
  # This updates the priority of a site's roles
  # Note: A lower priority role will always get used before a higher priority one
  def change_role_order
    unless update_priority(params[:role])
      redirect_to admin_roles_path, flash: { alert: I18n.t("administrator.roles.invalid_order") }
    end
  end

  # POST /admin/role/:role_id
  # This method updates the permissions assigned to a role
  def update_role
    role = Role.find(params[:role_id])
    flash[:alert] = I18n.t("administrator.roles.invalid_update") unless update_permissions(role)
    redirect_to admin_roles_path(selected_role: role.id)
  end

  # DELETE admins/role/:role_id
  # This deletes a role
  def delete_role
    role = Role.find(params[:role_id])

    # Make sure no users are assigned to the role and the role isn't a reserved role
    # before deleting
    if role.users.count.positive?
      flash[:alert] = I18n.t("administrator.roles.role_has_users", user_count: role.users.count)
      return redirect_to admin_roles_path(selected_role: role.id)
    elsif Role::RESERVED_ROLE_NAMES.include?(role) || role.provider != @user_domain ||
          role.priority <= current_user.role.priority
      return redirect_to admin_roles_path(selected_role: role.id)
    else
      role.role_permissions.delete_all
      role.delete
    end

    redirect_to admin_roles_path
  end

  private

  def find_user
    @user = User.find_by(uid: params[:user_uid])
  end

  def find_deleted_user
    @user = User.deleted.find_by(uid: params[:user_uid])
  end

  # Verifies that admin is an administrator of the user in the action
  def verify_admin_of_user
    redirect_to admins_path,
      flash: { alert: I18n.t("administrator.flash.unauthorized") } unless current_user.admin_of?(@user, "can_manage_users")
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
