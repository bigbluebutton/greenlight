class LtiController < ApplicationController
  layout 'application'

  include ApplicationHelper
  #include AccountsHelper
  include LtiHelper

  skip_authorization_check only: :generate_hex

  before_action :custom_authentication
  before_action :custom_authorization, except: :generate_hex
  before_action :find_keypair, only: [:show, :edit, :update, :destroy]
  before_action(except: :generate_hex) { verify_lti_enabled nil }
  before_action(except: :generate_hex) { verify_module_action :LTI, Account::LTI, nil }

  before_action(only: [:create, :update]) { sanitize_account_id(RailsLti2Provider::Tool.new(tool_params)) }

  def index
    selected_ver = params[:ver].nil? ? LTI_10 : params[:ver]
    @keypairs = RailsLti2Provider::Tool.accessible_by(current_ability).where(lti_version: selected_ver)
  end

  def show
    if @keypair.resource_type && @keypair.resource_link_id
      # the user has set the resource type and has used the keypair atleast once since resource link is set
      # try to find a resource
      @lti_resource = []
      resource_types = @keypair.resource_type.split(",")

      resource_types.each do |r|
        @lti_resource << r.constantize.where("resource_link_id IN (?) AND account_id =?", @keypair.resource_link_id.split(","), @keypair.account_id)
      end
    else
      @lti_resource = []
    end
  end

  def new
    @keypair = RailsLti2Provider::Tool.new
    @resources = AVAILABLE_RESOURCES
  end

  def create
    resource_types = params['resources'] ? params['resources'].select { |_, v| v['enabled'] } : {}

    @keypair = RailsLti2Provider::Tool.new(tool_params) do |k|
      k.lti_version = LTI_10
      k.tool_settings = 'none'
      # this should be set by the user
      k.resource_type = resource_types.keys.join(",")
    end

    respond_to do |format|
      if @keypair.save
        format.html { redirect_to lti_path(@keypair), notice: "Keypair created for '#{@keypair.account.name}'" }
        format.json { render :action => 'show', :status => 'created', :location => lti_path(@keypair) }
      else
        @resources = AVAILABLE_RESOURCES
        format.html { render :action => 'new' }
        format.json { render :json => @keypair.errors, :status => 'unprocessable_entity' }
      end
    end
  end

  def edit
    @resources = AVAILABLE_RESOURCES
  end

  def update
    resource_types = params['resources'] ? params['resources'].select { |_, v| v['enabled'] } : {}
    @keypair.resource_type = resource_types.keys.join(',');
    # determine what can be updated based on the user

    if @keypair.update(tool_params)
      redirect_to lti_path(@keypair)
    else
      render 'edit'
    end
  end

  def destroy
    @keypair.destroy
    redirect_back(fallback_location: lti_index_path)
  end

  def generate_hex
    # used to generate secrets and labels
    respond_to do |format|
      format.js { render :json => {hex: SecureRandom.hex(10)} }
    end
  end

  private
  def find_keypair
    @keypair = RailsLti2Provider::Tool.find(params[:id])
  end

  def custom_authorization
    authorize! :process, RailsLti2Provider::Tool
  end

  def tool_params
    params.require(:tool).permit(:uuid, :shared_secret, :account_id, :resource_type)
  end
end
