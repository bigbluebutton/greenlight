# frozen_string_literal: true

class InvitationSerializer < ApplicationSerializer
  attributes :email, :updated_at, :valid

  def valid
    object.updated_at.in(Invitation::INVITATION_VALIDITY_PERIOD)
  end
end
