export function localizeDateTimeString(time, language) {
  const options = {
    year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric',
  };
  const event = new Date(time);
  return event.toLocaleDateString(language, options);
}

export function localizeDayDateTimeString(time, language) {
  const options = {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric',
  };
  const event = new Date(time);
  return event.toLocaleDateString(language, options);
}
