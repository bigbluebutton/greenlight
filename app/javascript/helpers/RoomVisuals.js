const ROOM_ICON_OPTIONS = [
  { key: 'books', label: 'Books', emoji: '📚' },
  { key: 'course-1', label: 'Courses 1', emoji: '🎓' },
  { key: 'course-2', label: 'Courses 2', emoji: '📘' },
  { key: 'exam', label: 'Exam', emoji: '📝' },
  { key: 'law', label: 'Law', emoji: '⚖️' },
  { key: 'court', label: 'Court', emoji: '🏛️' },
  { key: 'meeting', label: 'Meeting', emoji: '📅' },
  { key: 'discussion', label: 'Discussion', emoji: '💬' },
  { key: 'entertainment', label: 'Entertainment', emoji: '🎬' },
  { key: 'general', label: 'General', emoji: '🗂️' },
];

const ROOM_ICON_KEYWORDS = [
  ['books', ['book', 'books', 'library']],
  ['course-1', ['course', 'class', 'academy', 'training', 'lesson']],
  ['course-2', ['study', 'learn', 'module', 'curriculum']],
  ['exam', ['exam', 'test', 'quiz', 'assessment']],
  ['law', ['law', 'legal', 'compliance', 'policy']],
  ['court', ['court', 'hearing', 'judge', 'trial']],
  ['meeting', ['meeting', 'calendar', 'session', 'sync', 'standup']],
  ['discussion', ['discussion', 'chat', 'forum', 'talk', 'debate']],
  ['entertainment', ['movie', 'film', 'media', 'fun', 'entertainment']],
];

const STORAGE_KEY = 'akademio-room-visuals';

function canUseStorage() {
  return typeof window !== 'undefined' && !!window.localStorage;
}

function readVisualStore() {
  if (!canUseStorage()) return {};

  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch (_) {
    return {};
  }
}

function writeVisualStore(data) {
  if (!canUseStorage()) return;

  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  } catch (_) {
    // Ignore storage failures in private mode and quota-limited browsers.
  }
}

function getRoomIconKey(room) {
  if (!room) return 'general';

  if (room.icon_key) return room.icon_key;

  const store = readVisualStore();
  if (room.friendly_id && store[room.friendly_id]) return store[room.friendly_id];

  const roomName = `${room.name || ''}`.toLowerCase();
  const matched = ROOM_ICON_KEYWORDS.find(([, keywords]) => keywords.some((keyword) => roomName.includes(keyword)));
  return matched?.[0] || 'general';
}

function getRoomIconOption(roomOrKey) {
  const key = typeof roomOrKey === 'string' ? roomOrKey : getRoomIconKey(roomOrKey);
  return ROOM_ICON_OPTIONS.find((item) => item.key === key) || ROOM_ICON_OPTIONS[ROOM_ICON_OPTIONS.length - 1];
}

function getRoomVisual(roomOrKey) {
  const icon = getRoomIconOption(roomOrKey);

  if (roomOrKey && typeof roomOrKey === 'object' && roomOrKey.room_thumbnail_url) {
    return {
      ...icon,
      imageUrl: roomOrKey.room_thumbnail_url,
    };
  }

  return {
    ...icon,
    imageUrl: null,
  };
}

function storeRoomIconPreference(friendlyId, iconKey) {
  if (!friendlyId || !iconKey) return;

  const current = readVisualStore();
  current[friendlyId] = iconKey;
  writeVisualStore(current);
}

export {
  ROOM_ICON_OPTIONS,
  getRoomIconKey,
  getRoomIconOption,
  getRoomVisual,
  storeRoomIconPreference,
};
