export default function getLanguage() {
  return window.navigator.userLanguage || window.navigator.language;
}
