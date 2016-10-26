(function() {
  var init = function() {

    $('.meeting-join').click (function (event) {
      var url = $('.meeting-url').val();
      var name = $('.meeting-user-name').val();
      $.ajax({
        url : url + "/join?name=" + name,
        dataType : "json",
        type : 'GET',
        success : function(data) {
          $(location).attr("href", data.response.join_url);
        },
        error : function(xhr, status, error) {
        },
        complete : function(xhr, status) {
        }
      });
    });

    $('.meeting-url-copy').click (function (e) {
      meetingURL = $('.meeting-url');
      meetingURL.select();
      document.execCommand("copy");
      meetingURL.blur();
    });
  };

  var initIndex = function() {

    $('.generate-link').click (function (e) {
      e.preventDefault();
      var link = window.location.protocol +
        '//' +
        window.location.hostname +
        '/meetings/' +
        Math.trunc(Math.random() * 1000000000);

      $('.meeting-url').val(link);
    });

    if (meetingId = $('.meeting-url').data('meetingId')) {
      var link = window.location.protocol +
        '//' +
        window.location.hostname +
        '/meetings/' +
        meetingId;
      $('.meeting-url').val(link)
    } else {
      $('.generate-link').click();
    }
  };

  var initRooms = function() {
    meetingURL = $('.meeting-url');
    var link = window.location.protocol +
      '//' +
      window.location.hostname +
      meetingURL.data('path');
    meetingURL.val(link);
  };

  $(document).on("turbolinks:load", function() {
    init();
    if ($("body[data-controller=landing]").get(0)) {
      if ($("body[data-action=meetings]").get(0)) {
        initIndex();
      } else if ($("body[data-action=rooms]").get(0)) {
        initRooms();
      }
    }
  });
}).call(this);
