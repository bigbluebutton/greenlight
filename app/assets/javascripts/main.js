// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

$(document).on('turbolinks:load', function(){
  $.rails.refreshCSRFTokens();
})

document.addEventListener("turbolinks:before-cache", function() {
  $(".alert").remove()
})

// Gets the localized string
function getLocalizedString(key) {
  var keyArr = key.split(".")
  var translated = I18n

  // Search current language for the key
  try {
    keyArr.forEach(function(k) {
      translated = translated[k]
    })
  } catch (e) {
    // Key is missing in selected language so default to english
    translated = undefined;
  }


  // If key is not found, search the fallback language for the key
  if (translated === null || translated === undefined) { 
    translated = I18nFallback

    keyArr.forEach(function(k) {
      translated = translated[k]
    })
  }

  return translated
}