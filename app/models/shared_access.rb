# frozen_string_literal: true

class SharedAccess < ApplicationRecord
  belongs_to :shared_user, class_name: 'User', foreign_key: 'user_id', inverse_of: :shared_accesses
  belongs_to :shared_room, class_name: 'Room', foreign_key: 'room_id', inverse_of: :shared_accesses

  validates :shared_user, uniqueness: { scope: :shared_room }
end
