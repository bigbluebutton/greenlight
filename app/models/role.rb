# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :provider }

  validates :provider, presence: true

  before_validation :set_role_color, on: :create

  after_create :create_role_permissions

  scope :with_provider, ->(current_provider) { where(provider: current_provider) }

  def self.search(input)
    return where('name ILIKE ?', "%#{input}%") if input

    all
  end

  # Populate the Role Permissions with default values on Role creation.
  # The created Role has the same permissions as the 'User' role
  def create_role_permissions
    return if %w[Administrator User Guest SuperAdmin].include? name # skip creation for default roles

    Permission.find_each do |permission|
      value = case permission.name
              when 'CreateRoom', 'SharedList', 'CanRecord'
                'true'
              when 'RoomLimit'
                '100'
              when 'AccessToVisibilities'
                Recording::VISIBILITIES.values
              else
                'false'
              end
      RolePermission.create(role: self, permission:, value:)
    end
  end

  private

  def set_role_color
    color = case name
            when 'Administrator'
              '#228B22'
            when 'User'
              '#4169E1'
            when 'Guest'
              '#FFA500'
            else
              "##{SecureRandom.hex(3)}"
            end

    raise if Role.exists?(color:, provider:) # Ensure uniqueness

    self.color = color
  rescue StandardError
    retry
  end
end
