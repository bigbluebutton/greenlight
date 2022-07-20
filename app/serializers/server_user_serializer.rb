# frozen_string_literal: true

class ServerUserSerializer < UserSerializer
  attribute :role

  def role
    object.role.name
  end
end
