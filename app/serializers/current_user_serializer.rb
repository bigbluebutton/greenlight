# frozen_string_literal: true

class CurrentUserSerializer < UserSerializer
  attributes :signed_in, :permissions, :status, :external_account

  def signed_in
    true
  end

  def external_account
    object.external_id?
  end

  def permissions
    RolePermission.joins(:permission)
                  .where(role_id: object.role_id)
                  .pluck(:name, :value)
                  .to_h
  end
end
