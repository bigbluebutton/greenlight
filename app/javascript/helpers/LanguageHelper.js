const LANGUAGE_STORAGE_KEY = 'akademioPreferredLanguage';

export function normalizeLanguageCode(value) {
  const normalized = `${value || ''}`.trim().toLowerCase();
  if (normalized.startsWith('tr')) return 'tr';
  return 'en';
}

export function getCurrentLanguage(i18n, fallback = 'en') {
  return normalizeLanguageCode(i18n?.resolvedLanguage || i18n?.language || fallback);
}

export function getStoredLanguage() {
  try {
    const storedLanguage = window?.localStorage?.getItem(LANGUAGE_STORAGE_KEY);
    if (!storedLanguage) return '';
    return normalizeLanguageCode(storedLanguage);
  } catch (_) {
    return '';
  }
}

export function persistLanguage(language) {
  try {
    window?.localStorage?.setItem(LANGUAGE_STORAGE_KEY, normalizeLanguageCode(language));
  } catch (_) {
    // Ignore storage errors (private mode / blocked storage).
  }
}
