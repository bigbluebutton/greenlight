module LtiHelper
  # LTI VERSIONS
  LTI_10 = "LTI-1p0"
  LTI_20 = "LTI-2p0"

  # LTI2 LAUNCH
  LTI2_REQUIRED_PARAMETERS = ["Context.id", "Context.title", "ResourceLink.id", "ResourceLink.title", "ResourceLink.description", "User.id", "User.username", "Person.sourcedId", "Person.name.full", "Membership.role", "Person.name.given", "Person.name.family", "Person.email.primary"]


  OPTIONAL_PARAMETERS = []


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
end
