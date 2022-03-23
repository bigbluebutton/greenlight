# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :rooms, dependent: :destroy
  validates :name, presence: true # TODO: amir - Change into full_name or seperate first and last name.
  # TODO: amir - Validate email format.
  validates :email, presence: true, uniqueness: { case_sensitive: false, scope: :provider }
  validates :provider, presence: true
  validates :password_confirmation, presence: true
end
