# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :rooms, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false, scope: :provider }
  validates :provider, presence: true

  after_create :create_room

  private

  def create_room
    rooms.create(name: 'My Room') # TODO: ahmad - Localize
  end
end
