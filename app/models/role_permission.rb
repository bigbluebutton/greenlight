# frozen_string_literal: true

class RolePermission < ApplicationRecord
  belongs_to :permission
  belongs_to :role

  validates :value, presence: true
  validates :provider, presence: true
end
