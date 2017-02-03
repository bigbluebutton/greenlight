// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
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

(function() {

  var enableRecordingUpdates = function() {
    App.recording_update = App.cable.subscriptions.create({
      channel: 'RecordingUpdatesChannel',
      admin_id: $(".page-wrapper.rooms").data('admin-id'),
      meeting_id: $(".page-wrapper.rooms").data('id')
    },
    {
      received: function(data) {

        var recordings = Recordings.getInstance();
        var table = recordings.table.api();
        var row = table.row("#"+data.id);

        if (data.action === 'update') {
          var rowData = row.data();

          rowData.published = data.published;
          rowData.listed = data.listed;
          table.row("#"+data.id).data(rowData);
          recordings.draw();

          var status = data.published ? (data.listed ? 'published' : 'unlisted') : 'unpublished';
          showAlert(I18n['recording_'+status], 4000);

        } else if (data.action === 'delete') {
          row.remove();
          recordings.draw();
          showAlert(I18n.recording_deleted, 4000);

        } else if (data.action === 'create') {
          if (row.length == 0) {
            data.duration = data.length;
            table.rows.add([data]);
            recordings.draw();
            showAlert(I18n.recording_created, 4000);
          }

        }
      }
    });
  };

  var disableRecordingUpdates = function() {
    App.recording_update.unsubscribe();
    delete App.recording_update
  };

  $(document).on("turbolinks:load", function() {
    // disable recording updates if enabled from a previous page
    if (App.recording_update) {
      disableRecordingUpdates();
    }
    if ($("body[data-controller=landing]").get(0)) {
      if ($("body[data-action=rooms]").get(0)) {
        enableRecordingUpdates();
      }
    }
  });
}).call(this);
