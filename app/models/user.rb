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

  enum status: { active: 0, pending: 1, banned: 2 }

  validates :name, presence: true # TODO: amir - Change into full_name or seperate first and last name.
  validates :email,
            format: /\A[\w\-.]+@[\w\-.]+\.[a-z]+\z/i,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :provider }

  validates :provider, presence: true
  validates :status, presence: true
  validates :password,
            presence: true,
            on: :create, unless: :external_id?

  validates :password,
            format: %r{\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[`@%~!#£$\\^&*()\]\[+={}/|:;"'<>\-,.?_ ]).{8,}\z},
            on: %i[create update], if: :password_digest_changed?, unless: :external_id?

  validates :avatar,
            dimension: { width: 300, height: 300 },
            content_type: %i[png jpg jpeg svg],
            size: { less_than: 3.megabytes }

  validates :reset_digest, uniqueness: true, if: :reset_digest?
  validates :verification_digest, uniqueness: true, if: :verification_digest?
  validates :session_token, presence: true, uniqueness: true
  validates :session_expiry, presence: true
  validates :language, presence: true

  validates :name, length: { minimum: 2, maximum: 255 }
  validates :email, length: { minimum: 5, maximum: 255 }
  validates :password, length: { maximum: 255 }

  validate :check_user_role_provider, if: :role_changed?

  before_validation :set_session_token, on: :create

  scope :with_provider, ->(current_provider) { where(provider: current_provider) }

  def self.search(input)
    return joins(:role).where('users.name ILIKE :input OR users.email ILIKE :input OR roles.name ILIKE :input', input: "%#{input}%") if input

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

  # Gives the session token and expiry a default value before saving
  def set_session_token
    self.session_token = User.generate_digest(SecureRandom.alphanumeric(40))
    self.session_expiry = 6.hours.from_now
  end

  def generate_session_token!(extended_session: false)
    digest = User.generate_digest(SecureRandom.alphanumeric(40))
    expiry = extended_session ? 7.days.from_now : 6.hours.from_now

    update! session_token: digest, session_expiry: expiry
  rescue ActiveRecord::RecordInvalid
    raise unless errors.attribute_names.include? :session_token

    retry
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

    update! verification_digest: digest, verification_sent_at: Time.current

    token
  rescue ActiveRecord::RecordInvalid
    raise unless errors.attribute_names.include? :verification_digest

    retry
  end

  def invalidate_reset_token
    update reset_sent_at: nil, reset_digest: nil # Remove expired/valid tokens.
  end

  # Verifies the token existence, fetches its user and validates its expiration
  # and invalidates the user activationtoken if expired.

  def self.verify_activation_token(token)
    digest = generate_digest(token)

    user = find_by verification_digest: digest
    return false unless user

    return false unless user.verification_sent_at

    expired = activation_token_expired?(user.verification_sent_at)

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
    update verification_sent_at: nil, verification_digest: nil # Remove expired/valid tokens.
  end

  def verify!
    update! verified: true
  end

  def deverify!
    update! verified: false
  end

  def check_user_role_provider
    return unless role

    errors.add(:user_provider, 'has to be the same as the Role provider') if provider != role.provider
  end
end
