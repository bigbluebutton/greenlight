# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RoomsController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)
  end

  let(:user) { create(:user) }
  let(:user_with_manage_rooms_permission) { create(:user, :with_manage_rooms_permission) }
  let(:user_with_manage_users_permission) { create(:user, :with_manage_users_permission) }

  describe '#index' do
    it 'ids of rooms in response are matching room ids that belong to current_user' do
      shared_rooms = create_list(:room, 2)
      user.shared_rooms << shared_rooms
      rooms = create_list(:room, 3, user:) + shared_rooms
      get :index
      expect(response).to have_http_status(:ok)
      response_room_ids = JSON.parse(response.body)['data'].pluck('id')
      expect(response_room_ids).to match_array(rooms.pluck(:id))
    end

    it 'no rooms for current_user should return empty list' do
      get :index
      expect(response).to have_http_status(:ok)
      response_room_ids = JSON.parse(response.body)['data'].pluck('id')
      expect(response_room_ids).to be_empty
    end

    context 'search' do
      it 'filters the list of rooms based on the query' do
        shared_room = create(:room, name: 'ROOM 1')
        user.shared_rooms << shared_room
        searched_rooms = [create(:room, user:, name: 'Room 1'), create(:room, user:, name: 'ROoM 2'), shared_room]
        create_list(:room, 2, user:)

        get :index, params: { search: 'room' }
        expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(searched_rooms.pluck(:id))
      end

      it 'returns all rooms when no search query was given' do
        create_list(:room, 5, user:)

        get :index, params: { search: '' }
        expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(user.rooms.pluck(:id))
      end
    end
  end

  describe '#show' do
    it 'returns a room if the friendly id is valid' do
      room = create(:room, user:)
      get :show, params: { friendly_id: room.friendly_id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq(room.id)
    end

    it 'returns :not_found if the room doesnt exist' do
      get :show, params: { friendly_id: 'invalid_friendly_id' }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['data']).to be_nil
    end

    it 'user cannot see another users room without ManageRooms permission' do
      room = create(:room)
      get :show, params: { friendly_id: room.friendly_id }
      expect(response).to have_http_status(:forbidden)
    end

    context 'SharedRoom' do
      let(:user2) { create(:user) }
      let(:room) { create(:room, user:) }

      before do
        # TODO: - ahmad: Clean up these specs
        user2.shared_rooms << room
        sign_in_user(user2)
      end

      it 'allows a user who the room is shared with to view the room' do
        get :show, params: { friendly_id: room.friendly_id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['id']).to eq(room.id)
      end
    end
  end

  describe '#public_show' do
    let(:fake_room_settings_getter) { instance_double(RoomSettingsGetter) }

    before do
      session[:session_token] = nil

      allow(RoomSettingsGetter).to receive(:new).and_return(fake_room_settings_getter)
      allow(fake_room_settings_getter).to receive(:call).and_return(
        { 'glRequireAuthentication' => true, 'glViewerAccessCode' => true, 'glModeratorAccessCode' => false, 'glAnyoneJoinAsModerator' => true }
      )
    end

    it 'returns a room if the friendly id is valid' do
      room = create(:room, user:)

      expect(RoomSettingsGetter).to receive(:new).with(room_id: room.id, provider: 'greenlight', current_user: nil, show_codes: false,
                                                       settings: %w[glRequireAuthentication
                                                                    glViewerAccessCode
                                                                    glModeratorAccessCode
                                                                    record
                                                                    glAnyoneJoinAsModerator])
      expect(fake_room_settings_getter).to receive(:call)

      get :public_show, params: { friendly_id: room.friendly_id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['name']).to eq(room.name)
      expect(JSON.parse(response.body)['data']['require_authentication']).to be(true)
      expect(JSON.parse(response.body)['data']['viewer_access_code']).to be(true)
      expect(JSON.parse(response.body)['data']['moderator_access_code']).to be(false)
      expect(JSON.parse(response.body)['data']['anyone_join_as_moderator']).to be(true)
      expect(JSON.parse(response.body)['data']['owner_name']).to eq(user.name)
      expect(JSON.parse(response.body)['data']['owner_avatar']).to be_present
    end

    it 'returns :not_found if the room doesnt exist' do
      get :public_show, params: { friendly_id: 'invalid_friendly_id' }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['data']).to be_nil
    end
  end

  describe '#destroy' do
    it 'deletes room from the database' do
      room = create(:room, user:)
      expect { delete :destroy, params: { friendly_id: room.friendly_id } }.to change(Room, :count).by(-1)
    end

    it 'deletes the recordings associated with the room' do
      room = create(:room, user:)
      create_list(:recording, 10, room:)
      expect { delete :destroy, params: { friendly_id: room.friendly_id } }.to change(Recording, :count).by(-10)
    end

    it 'cannot delete the room of another user' do
      new_user = create(:user)
      room = create(:room, user: new_user)
      expect { delete :destroy, params: { friendly_id: room.friendly_id } }.not_to change(Room, :count)
      expect(response).to have_http_status(:forbidden)
    end

    context 'user with ManageRooms permission' do
      before do
        sign_in_user(user_with_manage_rooms_permission)
      end

      it 'deletes the room of another user' do
        new_user = create(:user)
        room = create(:room, user: new_user)
        expect { delete :destroy, params: { friendly_id: room.friendly_id } }.to change(Room, :count).from(1).to(0)
        expect(response).to have_http_status(:ok)
      end

      it 'returns :not_found if the room does not exists' do
        delete :destroy, params: { friendly_id: 'NOT_FRIENDLY_ANYMORE' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    let(:room_params) do
      {
        user_id: user.id,
        room: {
          name: Faker::Name.name,
          user_id: user.id
        }
      }
    end
    let(:user) { create(:user) }
    let(:new_user) { create(:user) }

    it 'creates a room for a user' do
      expect { post :create, params: room_params }.to change { user.rooms.count }.from(0).to(1)
      expect(response).to have_http_status(:created)
    end

    it 'cannot create a room for another user' do
      room_params[:room][:user_id] = new_user.id
      expect { post :create, params: room_params }.not_to(change { new_user.rooms.count })
      expect(response).to have_http_status(:forbidden)
    end

    it 'calls create_meeting_options on room' do
      expect_any_instance_of(Room).to receive(:create_meeting_options)
      post :create, params: room_params
    end

    context 'user with ManageUser permission' do
      before do
        sign_in_user(user_with_manage_users_permission)
      end

      it 'creates a room for another user' do
        room_params[:room][:user_id] = new_user.id
        expect { post :create, params: room_params }.to(change { new_user.rooms.count })
        expect(response).to have_http_status(:created)
      end

      it 'returns :bad_request if user does not exists' do
        room_params[:room][:user_id] = 'invalid-user'
        expect { post :create, params: room_params }.not_to(change(Room, :count))
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'user has reached the room limit set for their role' do
      it 'room is not created since room limit has been reached' do
        permission_id = user.role.permissions.find_by(name: 'RoomLimit').id
        user.role.role_permissions.find_by(permission_id:).update(value: '3')

        sign_in_user(user)
        create_list(:room, 3, user:)
        room_params = {
          room: {
            name: Faker::Name.name,
            user_id: user.id
          }
        }

        expect { post :create, params: room_params }.not_to(change(Room, :count))
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe '#update' do
    it 'updates the presentation' do
      room = create(:room, presentation: fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
      patch :update,
            params: { friendly_id: room.friendly_id,
                      presentation: { presentation: fixture_file_upload(file_fixture('default-avatar.png'), 'image/png') } }
      expect(room.reload.presentation).to be_attached
    end

    it 'allows a shared user to update the room' do
      room = create(:room, presentation: fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
      shared_user = create(:user)
      create(:shared_access, user_id: shared_user.id, room_id: room.id)
      sign_in_user(shared_user)

      patch :update,
            params: { friendly_id: room.friendly_id,
                      presentation: { presentation: fixture_file_upload(file_fixture('default-avatar.png'), 'image/png') } }
      expect(room.reload.presentation).to be_attached
    end
  end

  describe '#purge_presentation' do
    it 'deletes the presentation' do
      room = create(:room, user:, presentation: fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
      expect(room.reload.presentation).to be_attached
      delete :purge_presentation, params: { friendly_id: room.friendly_id }
      expect(room.reload.presentation).not_to be_attached
    end

    it 'allows a shared user to update the room' do
      room = create(:room, user:, presentation: fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
      shared_user = create(:user)
      create(:shared_access, user_id: shared_user.id, room_id: room.id)
      sign_in_user(shared_user)

      expect(room.reload.presentation).to be_attached
      delete :purge_presentation, params: { friendly_id: room.friendly_id }
      expect(room.reload.presentation).not_to be_attached
    end
  end

  describe '#recordings' do
    it 'returns recordings belonging to the room' do
      room1 = create(:room, user:, friendly_id: 'friendly_id_1')
      room2 = create(:room, user:, friendly_id: 'friendly_id_2')
      recordings = create_list(:recording, 5, room: room1)
      create_list(:recording, 5, room: room2)
      get :recordings, params: { friendly_id: room1.friendly_id }
      recording_ids = JSON.parse(response.body)['data'].pluck('id')
      expect(response).to have_http_status(:ok)
      expect(recording_ids).to match_array(recordings.pluck(:id))
    end

    it 'returns an empty array if the room has no recordings' do
      room1 = create(:room, user:, friendly_id: 'friendly_id_1')
      get :recordings, params: { friendly_id: room1.friendly_id }
      recording_ids = JSON.parse(response.body)['data'].pluck('id')
      expect(response).to have_http_status(:ok)
      expect(recording_ids).to be_empty
    end

    it 'allows a shared user to view the recordings' do
      room = create(:room, user:, friendly_id: 'friendly_id_1')
      shared_user = create(:user)
      create(:shared_access, user_id: shared_user.id, room_id: room.id)
      sign_in_user(shared_user)

      recordings = create_list(:recording, 5, room:)

      get :recordings, params: { friendly_id: room.friendly_id }

      recording_ids = JSON.parse(response.body)['data'].pluck('id')
      expect(response).to have_http_status(:ok)
      expect(recording_ids).to match_array(recordings.pluck(:id))
    end
  end
end
