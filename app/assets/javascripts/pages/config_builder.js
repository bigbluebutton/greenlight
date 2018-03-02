(function() {

  function updateXMLURL() {
    $("#xml_url").html($("#xml_url").data('url')+"?platform="+$("#platform").val());
    // set placement params
    $.each($("#placements").children(), function(i, e) {
      var input = $(e).find("input");
      var pub_name = $(e).find("#public_name").val().replace(/ /g,"_");
      if (input.is(":checked")) {
        $("#xml_url").append("&placements%5B"+input.attr('name')+"%5D="+pub_name);
        $(e).find("#public_name").removeClass("hide");
      } else {
        $(e).find("#public_name").addClass("hide");
      }
    })

    // set custom params
    $.each($("#custom_params").children(), function(i, e) {
      var key = $(e).find("#key").val();
      var val = $(e).find("#value").val();
      $("#xml_url").append("&custom%5B"+key+"%5d="+val);
    });
  }

  function removeCustomInput(custom) {
    custom.parent().remove();
  }

  function addCustomInput() {
$("#custom_params").append("<div class='row'>Key: <input type='text' class='custom' id='key'></input> Value:<input type='text' class='custom' id='value'></input>&nbsp;&nbsp;<button class='fa fa-trash delete-confirm btn btn-sm btn-danger'></button><br><br></div>");
  }
 
  function updatePlatform() {
    window.location.href = window.location.pathname+"?platform="+$("#platform").val(); 
  } 

  function initBuilder() {
    
    $("#platform").on("change", function() {
      updatePlatform();
    })

    $("button").on("click", function() {
      updateXMLURL();
    })

    $(".checkbox").on("change", function() {
      updateXMLURL();
    })

    $("#add_custom_param").on("click", function() {
      addCustomInput();
    });

    $("body").on("input", ".custom", function() {
      updateXMLURL();
    })

    $("body").on("click", ".delete-confirm", function() {
      removeCustomInput($(this));
      updateXMLURL();
    });
  }

  $(document).on("turbolinks:load", function() {
    if ($("body[data-controller='lti/launch']").get(0)) {
      if ($("body[data-action=config_builder]").get(0)) {
        initBuilder();
      }
    }
  });
}).call(this);
