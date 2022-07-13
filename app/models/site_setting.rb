# frozen_string_literal: true

class SiteSetting < ApplicationRecord
  belongs_to :setting

  REGISTRATION_METHODS = {
    open: 'open',
    invite: 'invite',
    approval: 'approval'
  }.freeze
end
