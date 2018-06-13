// Handle changing of settings tabs.

$(document).on('turbolinks:load', function(){
  var controller = $("body").data('controller');
  var action = $("body").data('action');

  // Only run on the settings page.
  if (controller == "users" && action == "edit"){
    settingsButtons = $('.setting-btn');
    settingsViews = $('.setting-view');

    settingsButtons.each(function(i, btn) {
      if(i != 0){ $(settingsViews[i]).hide(); }
      $(btn).click(function(){
        $(btn).addClass("active");
        settingsViews.each(function(i, view){
          if($(view).attr("id") == $(btn).attr("id")){
            $(view).show();
          } else {
            $(settingsButtons[i]).removeClass("active");
            $(view).hide();
          }
        });
      });
    });
  }
});
