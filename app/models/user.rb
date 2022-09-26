# frozen_string_literal: true

class User < ApplicationRecord
  MAX_AVATAR_SIZE = 3_000_000
  # Reset token max validity period.
  # It's advised to not increase this to more than 1 hour.
  RESET_TOKEN_VALIDITY_PERIOD = 1.hour
  # Account activation token max validity period.
  # It's advised to not increase this to more than 1 hour.
  ACTIVATION_TOKEN_VALIDITY_PERIOD = 1.hour

  has_secure_password validations: false

  belongs_to :role

  has_many :rooms, dependent: :destroy
  has_many :shared_accesses, dependent: :destroy
  has_many :shared_rooms, through: :shared_accesses, class_name: 'Room'
  has_many :recordings, through: :rooms

  has_one_attached :avatar

  validates :name, presence: true # TODO: amir - Change into full_name or seperate first and last name.
  validates :email,
            format: /\A[\w\-.]+@[\w\-.]+\.[a-z]+\z/i,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :provider }

  validates :provider, presence: true

  validates :password,
            presence: true,
            on: :create, unless: :external_id?

  validates :password,
            format: %r{\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[`@%~!#£$\\^&*()\]\[+={}/|:;"'<>\-,.?_ ]).{8,}\z},
            on: %i[create update], if: :password_digest_changed?, unless: :external_id?

  # TODO: samuel - ActiveStorage validations needs to be discussed and implemented.
  validate :avatar_validation
  validates :reset_digest, uniqueness: true, if: :reset_digest?
  validates :activation_digest, uniqueness: true, if: :activation_digest?

  scope :with_provider, ->(current_provider) { where(provider: current_provider) }

  def self.search(input)
    return where('name ILIKE ?', "%#{input}%") if input

    all
  end

  # Verifies the token existence, fetches its user and validates its expiration
  # and invalidates the user token if expired.

  def self.verify_reset_token(token)
    digest = generate_digest(token)

    user = find_by reset_digest: digest
    return false unless user

    return false unless user.reset_sent_at

    expired = reset_token_expired?(user.reset_sent_at)

    if expired
      user.invalidate_reset_token
      return false
    end

    user
  end

  # Generates a token digest.
  def self.generate_digest(token)
    Digest::SHA2.hexdigest(token)
  end

  # Checkes the expiration of a token.
  def self.reset_token_expired?(sent_at)
    Time.current > (sent_at.in(RESET_TOKEN_VALIDITY_PERIOD))
  end

  # Create a unique random reset token
  def generate_reset_token!
    token = SecureRandom.alphanumeric(40)
    digest = User.generate_digest(token)

    update! reset_digest: digest, reset_sent_at: Time.current

    token
  rescue ActiveRecord::RecordInvalid
    raise unless errors.attribute_names.include? :reset_digest

    retry
  end

  # Create a unique random activation token
  # TODO: reduce duplication.
  def generate_activation_token!
    token = SecureRandom.alphanumeric(40)
    digest = User.generate_digest(token)

    update! activation_digest: digest, activation_sent_at: Time.current

    token
  rescue ActiveRecord::RecordInvalid
    raise unless errors.attribute_names.include? :activation_digest

    retry
  end

  def invalidate_reset_token
    update reset_sent_at: nil, reset_digest: nil # Remove expired/valid tokens.
  end

  # Verifies the token existence, fetches its user and validates its expiration
  # and invalidates the user activationtoken if expired.

  def self.verify_activation_token(token)
    digest = generate_digest(token)

    user = find_by activation_digest: digest
    return false unless user

    return false unless user.activation_sent_at

    expired = activation_token_expired?(user.activation_sent_at)

    if expired
      user.invalidate_activation_token
      return false
    end

    user
  end

  # Checkes the expiration of a token.
  def self.activation_token_expired?(sent_at)
    Time.current > (sent_at.in(ACTIVATION_TOKEN_VALIDITY_PERIOD))
  end

  def invalidate_activation_token
    update activation_sent_at: nil, activation_digest: nil # Remove expired/valid tokens.
  end

  def activate!
    update! active: true
  end

  def deactivate!
    update! active: false
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
