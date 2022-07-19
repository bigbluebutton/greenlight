# frozen_string_literal: true

class RoleSetter
  def initialize(user_params:, provider:)
    @user_params = user_params
    @provider = provider
    @roles_mappers = SettingGetter.new(setting_name: 'RoleMapping', provider:).call
  end

  def call
    email = @user_params[:email]

    matched_rule = if @roles_mappers
                     roles_mappers_hash = JSON.parse(@roles_mappers)
                                              .pluck('name', 'suffix')
                                              .to_h

                     roles_mappers_hash.find { |_name, suffix| email.ends_with? suffix }
                   end

    role = Role.find_by(name: matched_rule&.first) || Role.find_by(name: 'User')

    User.new({
      provider: @provider,
      role:
    }.merge(@user_params))
  end
end
