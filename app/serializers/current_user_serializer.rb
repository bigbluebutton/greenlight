# frozen_string_literal: true

class CurrentUserSerializer < UserSerializer
  attributes :signed_in

  def signed_in
    true
  end
end
