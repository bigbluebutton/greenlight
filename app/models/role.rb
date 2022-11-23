# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  validates :name, presence: true, uniqueness: { scope: :provider }
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
    return if %w[Administrator User Guest].include? name # skip creation for default roles

    Permission.all.find_each do |permission|
      value = case permission.name
              when 'CreateRoom', 'SharedList', 'CanRecord'
                'true'
              when 'RoomLimit'
                '100'
              else
                'false'
              end
      RolePermission.create(role: self, permission:, value:)
    end
  end

  private

  def set_role_color
    self.color = case name
                 when 'Administrator'
                   '#228B22'
                 when 'User'
                   '#4169E1'
                 when 'Guest'
                   '#FFA500'
                 else
                   "##{SecureRandom.hex(3)}"
                 end
  end
end
