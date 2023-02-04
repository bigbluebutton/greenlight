// create a helper that takes in either a user or a room or a recording and returns the correct date format using the user's language
export function localizeDateTimeString(currentUser, room, recording) {
  const options = {
    year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric',
  };
  if (room && currentUser) {
    const event = new Date(room?.last_session);
    return event.toLocaleDateString(currentUser?.language, options);
  }
  if (recording && currentUser) {
    const event = new Date(recording?.created_at);
    return event.toLocaleDateString(currentUser?.language, options);
  }
  if (currentUser) {
    const event = new Date(currentUser?.created_at);
    return event.toLocaleDateString(currentUser?.language, options);
  }
  return 'No date provided';
}

export function localizeDayDateTimeString(currentUser, room, recording) {
  const options = {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric',
  };
  if (room && currentUser) {
    const event = new Date(room?.last_session);
    return event.toLocaleDateString(currentUser?.language, options);
  }
  if (recording && currentUser) {
    const event = new Date(recording?.created_at);
    return event.toLocaleDateString(currentUser?.language, options);
  }
  if (currentUser) {
    const event = new Date(currentUser?.created_at);
    return event.toLocaleDateString(currentUser?.language, options);
  }
  return 'No date provided';
}
