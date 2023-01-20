function hasManageUsers(user) {
  return user?.permissions?.ManageUsers === 'true';
}
function hasCreateRoom(user) {
  return user?.permissions?.CreateRoom === 'true';
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
  hasManageUsers,
};
