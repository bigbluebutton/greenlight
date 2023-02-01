# frozen_string_literal: true

class SharedAccess < ApplicationRecord
  belongs_to :room
  belongs_to :user
end
