// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Initialize selectpicker
$(document).on('turbolinks:load', function(){
    // Initialize selectpicker
    $('.selectpicker').selectpicker({
    liveSearchPlaceholder: getLocalizedString('javascript.search.start')
    });
})