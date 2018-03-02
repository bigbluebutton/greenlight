module LtiHelper

  # LTI VERSIONS
  LTI_10 = "LTI-1p0"
  LTI_20 = "LTI-2p0"

  # LTI2 LAUNCH
  LTI2_REQUIRED_PARAMETERS = ["Context.id", "ResourceLink.title", "User.id", "User.username", "Person.sourcedId", "Person.name.full", "Membership.role", "Person.name.given", "Person.name.family", "Person.email.primary"]

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

  # Generates a unique nickname for the user
  # Given fullname="First Middle-Name Last" => firstmnlast[some_random_hex]
  def generate_nickname(fullname)
    name = ""
    unless fullname.blank?
      fullname.downcase.split(/@|_| /).each do |part|
        part.split("-").each do |subpart|
          name += part.length > 5 ? subpart[0] : subpart
        end
      end
    end
    name += SecureRandom.hex(3)
  end

  def generate_names
    # in the case that not all lis person identifiers are supplied
    # set the session data for the parameters that are given
    lis_params = params.select { |k,_| (LTI1_RECOMMENDED_PARAMETERS.include?(k) || k.include?("lis")) && !params[k].blank? }.keys
    lis_params.each do |p|
       if LTI1_PARAMETER_ALIASES[p]
         unless p == "lis_person_name_full" && isProf?
           session_cache(LTI1_PARAMETER_ALIASES[p], params[p])
         else
           session_cache(LTI1_PARAMETER_ALIASES[p], generate_nickname(params[p]))
         end
       end
    end
  end

  def set_generated_names
    # set the parameters that were not given by the lms using fallbacks defined below
    # NO FULL NAME:  use sourcedid                                      (blank if sourcedid unavailable)
    # NO EMAIL:      generate email using  user_id                      (raise error if no user_id supplied)
    # NO FIRST NAME: use sourcedid before username                      (unless sourcedid unavailable)
    # NO LAST NAME:  defaults to 'User'

    lis_params = lis_params.join(" ")
    raise RailsLti2Provider::LtiLaunch::Unauthorized.new(:insufficient_launch_info) if !params[:user_id] && !lis_params.include?("email_primary")\

    session_cache(:nickname, isProf? ? generate_nickname(params[:lis_person_sourcedid]) :
                                       params[:lis_person_sourcedid]) if !lis_params.include?("name_full")
    session_cache(:email, "#{Digest::SHA1.hexdigest(params[:user_id])}@nomail") if !lis_params.include?("email_primary")
    session_cache(:first_name, !lis_params.include?("person_sourcedid") ? session_cache(:nickname) : params[:lis_person_sourcedid]) if !lis_params.include?("name_given")
    session_cache(:last_name, "User") if !lis_params.include?("name_family")
  end
end
