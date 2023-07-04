// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

function hasManageUsers(user) {
  return user?.permissions?.ManageUsers === 'true';
}

function hasCreateRoom(user) {
  return user?.permissions?.CreateRoom === 'true';
}

function hasApiCreateRoom(user) {
  return user?.permissions?.ApiCreateRoom === 'true';
}

function hasManageRooms(user) {
  return user?.permissions?.ManageRooms === 'true';
}

function hasManageRecordings(user) {
  return user?.permissions?.ManageRecordings === 'true';
}

function hasManageSiteSettings(user) {
  return user?.permissions?.ManageSiteSettings === 'true';
}

function hasManageRoles(user) {
  return user?.permissions?.ManageRoles === 'true';
}

function hasSharedList(user) {
  return user?.permissions?.SharedList === 'true';
}

function hasCanRecord(user) {
  return user?.permissions?.CanRecord === 'true';
}

function hasRoomLimit(user) {
  return user?.permissions?.RoomLimit !== '100';
}

function isAdmin(user) {
  return hasManageUsers(user) || hasManageRooms(user) || hasManageRecordings(user) || hasManageSiteSettings(user) || hasManageRoles(user);
}

export default {
  isAdmin,
  hasRoomLimit,
  hasCanRecord,
  hasSharedList,
  hasManageRoles,
  hasManageSiteSettings,
  hasManageRecordings,
  hasManageRooms,
  hasCreateRoom,
  hasApiCreateRoom,
  hasManageUsers,
};
