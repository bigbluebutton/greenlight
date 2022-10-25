# frozen_string_literal: true

class InvitationSerializer < ApplicationSerializer
  attributes :email, :updated_at, :valid

  def valid
    Time.zone.now.between?(object.updated_at, object.updated_at + 48.hours)
  end
end
