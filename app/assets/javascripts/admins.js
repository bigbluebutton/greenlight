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
  var controller = $("body").data('controller');
  var action = $("body").data('action');

  // Only run on the admins page.
  if (controller == "admins" && action == "index") {
    // show the modal with the correct form action url
    $(".delete-user").click(function(data){
      var uid = $(data.target).closest("tr").data("user-uid")
      var url = $("body").data("relative-root")
      if (!url.endsWith("/")) {
        url += "/"
      }
      url += "u/" + uid
      $("#delete-confirm").parent().attr("action", url)
    })

    //clear the role filter if user clicks on the x
    $(".clear-role").click(function() {
      var search = new URL(location.href).searchParams.get('search')

      var url = window.location.pathname + "?page=1"
    
      if (search) {
        url += "&search=" + search
      }  
    
      window.location.replace(url);
    })
    
    /* COLOR SELECTORS */

    loadColourSelectors()
  }

  // Only run on the admins edit user page.
  if (controller == "admins" && action == "edit_user") {
    $(".setting-btn").click(function(data){
      var url = $("body").data("relative-root")
      if (!url.endsWith("/")) {
        url += "/"
      }
      url += "admins?setting=" + data.target.id

      window.location.href = url
    })
  }
});

// Change the branding image to the image provided
function changeBrandingImage(path) {
  var url = $("#branding-url").val()
  $.post(path, {url: url})
}

// Filters by role
function filterRole(role) {
  var search = new URL(location.href).searchParams.get('search')

  var url = window.location.pathname + "?page=1" + "&role=" + role

  if (search) {
    url += "&search=" + search
  }  

  window.location.replace(url);
}

function loadColourSelectors() {
  const pickrRegular = new Pickr({
    el: '#colorinput-regular',
    theme: 'monolith',
    useAsButton: true,
    lockOpacity: true,
    defaultRepresentation: 'HEX',
    closeWithKey: 'Enter',
    default: $("#colorinput-regular").css("background-color"),

    components: {
        palette: true,
        preview: true,
        hue: true,
        interaction: {
            input: true,
            save: true,
        },
    },
  });

  const pickrLighten = new Pickr({
    el: '#colorinput-lighten',
    theme: 'monolith',
    useAsButton: true,
    lockOpacity: true,
    defaultRepresentation: 'HEX',
    closeWithKey: 'Enter',
    default: $("#colorinput-lighten").css("background-color"),

    components: {
        palette: true,
        preview: true,
        hue: true,
        interaction: {
            input: true,
            save: true,
        },
    },
  });

  const pickrDarken = new Pickr({
    el: '#colorinput-darken',
    theme: 'monolith',
    useAsButton: true,
    lockOpacity: true,
    defaultRepresentation: 'HEX',
    closeWithKey: 'Enter',
    default: $("#colorinput-darken").css("background-color"),

    components: {
        palette: true,
        preview: true,
        hue: true,
        interaction: {
            input: true,
            save: true,
        },
    },
  });

  pickrRegular.on("save", (color, instance) => {
    $.post($("#coloring-path-regular").val(), {color: color.toHEXA().toString()}).done(function() {
      location.reload()
    });
  })

  pickrLighten.on("save", (color, instance) => {
    $.post($("#coloring-path-lighten").val(), {color: color.toHEXA().toString()}).done(function() {
      location.reload()
    });
  })

  pickrDarken.on("save", (color, instance) => {
    $.post($("#coloring-path-darken").val(), {color: color.toHEXA().toString()}).done(function() {
      location.reload()
    });
  })
}