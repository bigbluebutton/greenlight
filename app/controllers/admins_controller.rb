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

    @role = params[:role] ? Role.find_by(name: params[:role], provider: @user_domain) : nil

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

  # ROLES

  # GET /admins/roles
  def roles
    @roles = Role.editable_roles(@user_domain)

    if @roles.count.zero?
      Role.create_default_roles(@user_domain)
      @roles = Role.editable_roles(@user_domain)
    end

    @selected_role = if params[:selected_role].nil?
                        @roles.find_by(name: 'user')
                      else
                        @roles.find(params[:selected_role])
                     end
  end

  # POST /admin/role
  # This method creates a new role scope to the users provider
  def new_role
    new_role_name = params[:role][:name]

    # Make sure that the role name isn't a duplicate or a reserved name like super_admin
    if Role.duplicate_name(new_role_name, @user_domain)
      flash[:alert] = I18n.t("administrator.roles.duplicate_name")

      return redirect_to admin_roles_path
    end

    # Make sure the role name isn't empty
    if new_role_name.strip.empty?
      flash[:alert] = I18n.t("administrator.roles.empty_name")

      return redirect_to admin_roles_path
    end

    new_role = Role.create_new_role(new_role_name, @user_domain)

    redirect_to admin_roles_path(selected_role: new_role.id)
  end

  # PATCH /admin/roles/order
  # This updates the priority of a site's roles
  # Note: A lower priority role will always get used before a higher priority one
  def change_role_order
    user_role = Role.find_by(name: "user", provider: @user_domain)
    admin_role = Role.find_by(name: "admin", provider: @user_domain)

    current_user_role = current_user.highest_priority_role

    # Users aren't allowed to update the priority of the admin or user roles
    if params[:role].include?(user_role.id.to_s) || params[:role].include?(admin_role.id.to_s)
      flash[:alert] = I18n.t("administrator.roles.invalid_order")

      return redirect_to admin_roles_path
    end

    # Restrict users to only updating the priority for roles in their domain with a higher
    # priority
    params[:role].each do |id|
      role = Role.find(id)
      if role.priority <= current_user_role.priority || role.provider != @user_domain
        flash[:alert] = I18n.t("administrator.roles.invalid_update")
        return redirect_to admin_roles_path
      end
    end

    # Update the roles priority including the user role
    top_priority = 0

    params[:role].each_with_index do |id, index|
      new_priority = index + [current_user_role.priority, 0].max + 1
      top_priority = new_priority
      Role.where(id: id).update_all(priority: new_priority)
    end

    user_role.priority = top_priority + 1
    user_role.save!
  end

  # POST /admin/role/:role_id
  # This method updates the permissions assigned to a role
  def update_role
    role = Role.find(params[:role_id])
    current_user_role = current_user.highest_priority_role

    # Checks that it is valid for the provider to update the role
    if role.priority <= current_user_role.priority || role.provider != @user_domain
      flash[:alert] = I18n.t("administrator.roles.invalid_update")
      return redirect_to admin_roles_path(selected_role: role.id)
    end

    role_params = params.require(:role).permit(:name)
    permission_params = params.require(:role)
                              .permit(
                                :can_create_rooms,
                                :send_promoted_email,
                                :send_demoted_email,
                                :can_edit_site_settings,
                                :can_edit_roles,
                                :can_manage_users,
                                :colour
                              )

    # Role is a default role so users can't change the name
    role_params[:name] = role.name if Role::RESERVED_ROLE_NAMES.include?(role.name)

    # Make sure if the user is updating the role name that the role name is valid
    if role.name != role_params[:name] && !Role.duplicate_name(role_params[:name], @user_domain) &&
       !role_params[:name].strip.empty?
      role.name = role_params[:name]
    elsif role.name != role_params[:name]
      flash[:alert] = I18n.t("administrator.roles.duplicate_name")

      return redirect_to admin_roles_path(selected_role: role.id)
    end

    role.update(permission_params)

    role.save!

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
          role.priority <= current_user.highest_priority_role.priority
      return redirect_to admin_roles_path(selected_role: role.id)
    else
      role.delete
    end

    redirect_to admin_roles_path
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
    initial_list = if current_user.has_role? :super_admin
      User.where.not(id: current_user.id)
    else
      User.without_role(:super_admin).where.not(id: current_user.id)
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
