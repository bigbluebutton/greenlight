# frozen_string_literal: true

class MeetingOption < ApplicationRecord
  has_many :room_meeting_options, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  # Options that are relevent only to GL.
  scope :gl_options, -> { where('name LIKE ?', 'gl%') }
  # Options that will be sent to BBB as parameters.
  scope :bbb_options, -> { where.not('name LIKE ?', 'gl%') }
  # BBB meeting passwords.
  scope :password_options, -> { where('name LIKE ?', '%PW%') }
  # Options that can be configured by end users.
  scope :public_options, -> { where.not('name LIKE ? OR name LIKE ?', '%PW%', 'meta%') }
  # Options that should only be configured by the application.
  scope :private_options, -> { where('name LIKE ? OR name LIKE ?', '%PW%', 'meta%') }

  # Class methods
  class << self
    def public_option_names
      public_options.pluck(:name)
    end

    def public_option_names_ids
      public_options.pluck(:name, :id)
    end

    def bbb_option_names_default_values
      bbb_options.pluck(:name, :default_value)
    end

    def password_option_ids
      password_options.pluck :id
    end
  end
end
