(function() {
  var initIndex = function() {
    $('#join_form_button').click (function (event) {
      $.ajax({
        url : $(this).data ('url') + "?name=" + $('#join_form_name').val(),
        dataType : "json",
        async : true,
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
  };

  $(document).on("turbolinks:load", function() {
    if ($("body[data-controller=landing]").get(0)) {
      if ($("body[data-action=index]").get(0)) {
        initIndex();
      }
    }
  });
}).call(this);