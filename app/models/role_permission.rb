# frozen_string_literal: true

class RolePermission < ApplicationRecord
  belongs_to :permission
  belongs_to :role

  validates :value, presence: true

  def self.room_limit_reached(user_id)
    return render_error status: :not_found unless User.find(user_id)

    user = User.find(user_id)
    if RolePermission.joins(:permission).find_by(role_id: user.role_id, permission: { name: 'RoomLimit' }).value.to_i <= user.rooms.count.to_i
      return true
    end

    false
  end
end
