# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :rooms, dependent: :destroy
  has_many :recordings, through: :rooms

  has_one_attached :avatar

  validates :name, presence: true # TODO: amir - Change into full_name or seperate first and last name.
  # TODO: amir - Validate email format.
  validates :email, presence: true, uniqueness: { case_sensitive: false, scope: :provider }
  validates :provider, presence: true
  validates :password_confirmation, presence: true, on: :create

  # TODO: samuel - ActiveStorage validations needs to be discussed and implemented.
  validate :avatar_validation

  private

  def avatar_validation
    return unless avatar.attached?

    if !avatar.attachment.blob.content_type.in?(%w[image/png image/jpeg])
      errors.add(:avatar, 'must be an image file')
    elsif avatar.attachment.blob.byte_size > 3_000_000
      errors.add(:avatar, 'is too large')
    end
  end
end
