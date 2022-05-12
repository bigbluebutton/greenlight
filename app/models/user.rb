# frozen_string_literal: true

class User < ApplicationRecord
  MAX_AVATAR_SIZE = 3_000_000

  has_secure_password
  has_many :rooms, dependent: :destroy

  has_many :shared_accesses, dependent: :destroy
  has_many :shared_rooms, through: :shared_accesses, class_name: 'Room'

  has_many :recordings, through: :rooms

  has_one_attached :avatar

  validates :name, presence: true # TODO: amir - Change into full_name or seperate first and last name.
  # TODO: amir - Validate email format.
  validates :email, presence: true, uniqueness: { case_sensitive: false, scope: :provider }
  validates :provider, presence: true
  validates :password_confirmation, presence: true, on: :create

  # TODO: samuel - ActiveStorage validations needs to be discussed and implemented.
  validate :avatar_validation

  def room_owner?(room)
    id == room.user_id
  end

  def room_shared?(room)
    shared_rooms.pluck(:friendly_id).include?(room.friendly_id)
  end

  # If User is not the room owner, or the room is not being shared already, then the room is shareable to the user.
  def room_shareable?(room)
    return false if room_owner?(room) || room_shared?(room)

    true
  end

  private

  def avatar_validation
    return unless avatar.attached?

    if !avatar.attachment.blob.content_type.in?(%w[image/png image/jpeg])
      errors.add(:avatar, 'must be an image file')
    elsif avatar.attachment.blob.byte_size > MAX_AVATAR_SIZE
      errors.add(:avatar, 'is too large')
    end
  end
end
