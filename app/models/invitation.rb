# frozen_string_literal: true

class Invitation < ApplicationRecord
  has_secure_token :token

  validates :email, presence: true, uniqueness: { scope: :provider }
  validates :provider, presence: true
  validates :token, uniqueness: true

  def self.search(input)
    return where('email ILIKE ?', "%#{input}%") if input

    all
  end
end
