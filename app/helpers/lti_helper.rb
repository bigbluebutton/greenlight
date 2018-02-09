module LtiHelper

  # LTI VERSIONS
  LTI_10 = "LTI-1p0"
  LTI_20 = "LTI-2p0"

  # LTI2 LAUNCH
  LTI2_REQUIRED_PARAMETERS = ["Context.id", "ResourceLink.id", "ResourceLink.title", "ResourceLink.description", "User.id", "User.username", "Person.sourcedId", "Person.name.full", "Membership.role", "Person.name.given", "Person.name.family", "Person.email.primary"]

  OPTIONAL_PARAMETERS = []

  # the name should match the code for the resource_handlers in config/resource_handlers/*.yml
  AVAILABLE_RESOURCES =  {"Room" => { :opt => OPTIONAL_PARAMETERS },
                          "Assignment" => { :opt => OPTIONAL_PARAMETERS }}

  # LTI1 PARAMETER PROFILES
  LTI1_RECOMMENDED_PARAMETERS = ["lis_person_name_full", "lis_person_name_given", "lis_person_name_family"]

  LTI1_PARAMETER_ALIASES = {"lis_person_name_full" => "nickname",
                            "lis_person_name_given" => "first_name",
                            "lis_person_name_family" => "last_name",
                            "lis_person_contact_email_primary" => "email"}


  def lti_versions_as_options_for_select
    [["1.0", LTI_10],["2.0", LTI_20]]
  end

  def session_cache(key, val = nil)
    if @launch_id
      launch_id = @launch_id
    else
      launch_id = params[:launch_id]
    end

    if from_lti? && launch_id
      # link the session id with this data
      Rails.cache.write(launch_id+"/session", session.id) if Rails.cache.read(launch_id+"/session").nil?

      if val
        Rails.cache.write(launch_id+"/#{key}", val)
      else
        Rails.cache.read(launch_id+"/#{key}")
      end
    end
  end

  def resolve_lti_layout
    if request.referrer.nil? && request.original_fullpath.include?('lti') && !session[:from_launch] && current_user && !params[:launch_id]
      redirect_to request.original_fullpath.gsub('/lti/', '/admin/') and return
    elsif !request.original_fullpath.include?('lti') && current_user
      session[:from_launch] = nil
      "application"
    else
      "lti"
    end
  end
  def lti_view_check
    disable_xframe_header if request.original_fullpath.include?('lti')
  end

  # lti_ability() custom ability loading for authorization with LTI resources
  # Ex.
  #  Call using delegate on can?, cannot?, authorize! to: lti_ability
  #    or use as lti_ability.can? etc.

  def lti_ability
    # for check_authorization to pass
    @_authorized = true
    if from_lti?
      attr = session_cache(:launch_user) unless session_cache(:launch_user).blank?
      user = User.new(attr)
      @ability = Ability.new(user)
    else
      current_ability
    end
  end

  # user_role?(sym) retrieves the role of the LTI resource user depending on
  #   whether the launch is from the LTI or console context
  # sym is one of :sadmin, :admin, :manager, :member

  def user_role?(role)
    if user_signed_in? && !from_lti?
      # only signed in users can be sadmin
      if role == :sadmin
        current_user.is_a?(Sadmin)
      else
        current_user.send("is_#{role}?")
      end
    elsif from_lti?
      attr = session_cache(:launch_user) unless session_cache(:launch_user).blank?
      User.new(attr).send("is_#{role}?")
    else
      false
    end
  end
  def verify_launch_session
    if !params[:launch_id].blank? && Rails.cache.read(params[:launch_id]+"/session") != session.id
      @error = { key: :session_expired, message: I18n.t('errors.general.launch_expired')}
      disable_xframe_header if defined? disable_xframe_header
      render('lti/launch/_error', layout: 'empty') and return
    end
  end
end
