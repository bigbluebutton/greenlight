# frozen_string_literal: true

class User < ApplicationRecord
  MAX_AVATAR_SIZE = 3_000_000

  has_secure_password validations: false

  belongs_to :role

  has_many :rooms, dependent: :destroy
  has_many :shared_accesses, dependent: :destroy
  has_many :shared_rooms, through: :shared_accesses, class_name: 'Room'
  has_many :recordings, through: :rooms

  has_one_attached :avatar

  validates :name, presence: true # TODO: amir - Change into full_name or seperate first and last name.
  # TODO: amir - Validate email format.
  validates :email, presence: true, uniqueness: { case_sensitive: false, scope: :provider }
  validates :provider, presence: true

  validates :password, presence: true, confirmation: true, on: :create, unless: :external_id?

  # TODO: samuel - ActiveStorage validations needs to be discussed and implemented.
  validate :avatar_validation
  validates :reset_digest, uniqueness: true, on: :update

  def self.search(input)
    return where('name ILIKE ?', "%#{input}%") if input

    all
  end

  # Generates a token digest.
  def self.generate_digest(token)
    Digest::SHA2.hexdigest(token)
  end

  # Create a unique random token
  def generate_unique_token
    token = SecureRandom.alphanumeric(40)
    digest = User.generate_digest(token)

    update! reset_digest: digest, reset_sent_at: Time.current

    token
  rescue ActiveRecord::RecordInvalid
    raise unless errors.attribute_names.include? :reset_digest

    retry
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
