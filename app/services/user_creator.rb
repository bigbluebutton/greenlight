# frozen_string_literal: true

class UserCreator
  def initialize(user_params:, provider:)
    @user_params = user_params
    @provider = provider
    @roles_mappers = SettingGetter.new(setting_name: 'RoleMapping', provider:).call
  end

  def call
    default_role_name = SettingGetter.new(setting_name: 'DefaultRole', provider: @provider).call
    # TODO - could we save this query by storing the activerecord directly in the db? SiteSetting: value -> <Role>
    default_role = Role.find_by(name: default_role_name)
    role = infer_role_from_email(@user_params[:email])

    User.new({
      provider: @provider,
      role: role || default_role
    }.merge(@user_params))
  end

  private

  def infer_role_from_email(email)
    matched_rule = if @roles_mappers
                     rules = @roles_mappers.split(',').map { |rule| rule.split('=') }

                     rules.find { |rule| email.ends_with? rule.second if rule.second }
                   end

    Role.find_by(name: matched_rule&.first)
  end
end
