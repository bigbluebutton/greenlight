# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :rooms, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false, scope: :provider }
  validates :provider, presence: true
end
