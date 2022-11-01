# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  validates :name, presence: true, uniqueness: { scope: :provider }
  validates :provider, presence: true

  before_validation :set_random_color, on: :create

  after_create :create_role_permissions

  scope :with_provider, ->(current_provider) { where(provider: current_provider) }

  def self.search(input)
    return where('name ILIKE ?', "%#{input}%") if input

    all
  end

  # Populate the Role Permissions with false as default value on Role creation.
  def create_role_permissions
    Permission.all.find_each do |permission|
      value = permission.name == 'RoomLimit' ? '0' : 'false'
      RolePermission.create(role: self, permission:, value:)
    end
  end

  private

  def set_random_color
    self.color = "##{SecureRandom.hex(3)}"
  end
end
