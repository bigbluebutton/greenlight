# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require "rails_helper"

def random_valid_room_params
  {
    room: {
      name: Faker::Name.first_name,
      auto_join: false,
    },
  }
end

describe RoomsController, type: :controller do
  describe "GET #show" do
    before do
      @user = create(:user)
      @owner = create(:user)
    end

    it "should fetch recordings and room state if user is owner" do
      @request.session[:user_id] = @owner.id

      get :show, params: { room_uid: @owner.main_room }

      expect(assigns(:recordings)).to eql(@owner.main_room.recordings)
      expect(assigns(:is_running)).to eql(@owner.main_room.running?)
    end

    it "should be able to search recordings if user is owner" do
      @request.session[:user_id] = @owner.id

      get :show, params: { room_uid: @owner.main_room, search: :none }

      expect(assigns(:recordings)).to eql([])
    end

    it "should render join if user is not owner" do
      @request.session[:user_id] = @user.id

      get :show, params: { room_uid: @owner.main_room }

      expect(response).to render_template(:join)
    end

    it "should be able to search public recordings if user is not owner" do
      @request.session[:user_id] = @user.id

      get :show, params: { room_uid: @owner.main_room, search: :none }

      expect(assigns(:recordings)).to eql(nil)
    end

    it "should raise if room is not valid" do
      expect do
        get :show, params: { room_uid: "non_existent" }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "POST #create" do
    before do
      @owner = create(:user)
    end

    it "should create room with name" do
      @request.session[:user_id] = @owner.id
      name = Faker::Pokemon.name
      post :create, params: { room: { name: name } }

      r = @owner.secondary_rooms.last
      expect(r.name).to eql(name)
      expect(r.owner).to eql(@owner)
      expect(response).to redirect_to(r)
    end

    it "it should redirect to root if not logged in" do
      expect do
        name = Faker::Pokemon.name
        post :create, params: { room: { name: name } }
      end.to change { Room.count }.by(0)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST #join" do
    before do
      @user = create(:user)
      @owner = create(:user)
      @room = @owner.main_room

      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_meeting_info).and_return(
        moderatorPW: "modpass",
        attendeePW: "attpass",
      )
    end

    it "should use account name if user is logged in and meeting running" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:is_meeting_running?).and_return(true)

      @request.session[:user_id] = @user.id
      post :join, params: { room_uid: @room, join_name: @user.name }

      expect(response).to redirect_to(@user.main_room.join_path(@user.name, {}, @user.uid))
    end

    it "should use join name if user is not logged in and meeting running" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:is_meeting_running?).and_return(true)

      post :join, params: { room_uid: @room, join_name: "Join Name" }

      expect(response).to redirect_to(@user.main_room.join_path("Join Name", {}))
    end

    it "should render wait if meeting isn't running" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:is_meeting_running?).and_return(false)

      @request.session[:user_id] = @user.id
      post :join, params: { room_uid: @room, join_name: @user.name }

      expect(response).to render_template(:wait)
    end

    it "should join owner as moderator if meeting running" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:is_meeting_running?).and_return(true)

      @request.session[:user_id] = @owner.id
      post :join, params: { room_uid: @room, join_name: @owner.name }

      expect(response).to redirect_to(@user.main_room.join_path(@owner.name, { user_is_moderator: true }, @owner.uid))
    end
  end

  describe "DELETE #destroy" do
    before do
      @user = create(:user)
      @secondary_room = create(:room, owner: @user)
    end

    it "should delete room and redirect to main room" do
      @request.session[:user_id] = @user.id

      expect do
        delete :destroy, params: { room_uid: @secondary_room }
      end.to change { Room.count }.by(-1)

      expect(response).to redirect_to(@user.main_room)
    end

    it "should not delete room if not owner" do
      random_user = create(:user)
      @request.session[:user_id] = random_user.id

      expect do
        delete :destroy, params: { room_uid: @user.main_room }
      end.to change { Room.count }.by(0)
    end

    it "should not delete room not logged in" do
      expect do
        delete :destroy, params: { room_uid: @user.main_room }
      end.to change { Room.count }.by(0)
    end
  end

  describe "POST #start" do
    before do
      @user = create(:user)
      @other_room = create(:room)

      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_meeting_info).and_return(
        moderatorPW: "modpass",
        attendeePW: "attpass",
      )
    end

    it "should redirect to join path if owner" do
      @request.session[:user_id] = @user.id
      post :start, params: { room_uid: @user.main_room }

      expect(response).to redirect_to(@user.main_room.join_path(@user.name, { user_is_moderator: true }, @user.uid))
    end

    it "should bring to room if not owner" do
      @request.session[:user_id] = @user.id
      post :start, params: { room_uid: @other_room }

      expect(response).to redirect_to(@user.main_room)
    end

    it "should bring to root if not authenticated" do
      post :start, params: { room_uid: @other_room }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH #update" do
    before do
      @user = create(:user)
      @secondary_room = create(:room, owner: @user)
      @editable_room = create(:room, owner: @user)
    end

    it "properly updates room name through room block and redirects to current page" do
      @request.session[:user_id] = @user.id

      patch :update, params: { room_uid: @secondary_room, room_block_uid: @editable_room,
                               setting: :rename_block, room_name: :name }

      expect(response).to redirect_to(@secondary_room)
    end

    it "properly updates room name through room header and redirects to current page" do
      @request.session[:user_id] = @user.id

      patch :update, params: { room_uid: @secondary_room, setting: :rename_header, room_name: :name }

      expect(response).to redirect_to(@secondary_room)
    end

    it "properly updates recording name and redirects to current page" do
      @request.session[:user_id] = @user.id

      patch :update, params: { room_uid: @secondary_room, recordid: :recordid,
                               setting: :rename_recording, record_name: :name }

      expect(response).to redirect_to(@secondary_room)
    end
  end
end
