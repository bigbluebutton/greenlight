# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::RoomsController, type: :controller do
  before do
    room = Room.create(name: 'Room 1', user_id: 1)
  end
  # TODO: Write test for rooms index
  describe 'index' do
    it 'returns the rooms that belong to current_user' do

    end
  end
end