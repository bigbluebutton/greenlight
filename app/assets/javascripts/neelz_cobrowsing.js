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

// Handle client request to join when meeting starts.
$(document).on("turbolinks:load", function(){
    let body = $("body"),
        controller = body.data('controller'),
        action = body.data('action');

    let bg = $('.background'),
        is_moderator = bg.attr('is_moderator') === 'yes';

    if(controller === "neelz" && action === "p_inside" && !is_moderator){

        let coBrowsingState = {
            blocked: false,
            refreshRequired: false,
            activeIFrame: 0,
            active: false,
            url: '',
            scrollTop: 0
        };

        let startCoBrowsing = function(url,readonly){

            if (!readonly && url === coBrowsingState.url && coBrowsingState.active){
                return;
            }

            if (!url || url.trim() === ''){
                return;
            }

            coBrowsingState.url = url;
            coBrowsingState.active = true;

            set_screen_split_layout(7);

            let show_vp = function () {
                $('#curtain_layer').animate(
                    {
                        opacity: 0.0
                    },500,
                    function () {
                    }
                ).css('pointer-events','none');
            };
            let set_url_vp = function () {
                $('#external_viewport_1').attr('src',url);
                setTimeout(show_vp,500);
            };

            $('#curtain_layer').animate(
                {
                    opacity: 1.0
                }, 500,
                function () { //complete
                    $('#external_viewport_1').attr('src','');
                    setTimeout(set_url_vp, 100);
                }
            ).css('pointer-events','all');
        };

        let stopCoBrowsing = function(){
            coBrowsingState.active = false;
            coBrowsingState.url = '';
            $('#curtain_layer').animate(
                {
                    opacity: 1.0
                }, 500,
                function () { //complete
                    set_screen_split_layout(1);
                }
            ).css('pointer-events','all');

        };

        let refreshCoBrowsing = function () {
            if (coBrowsingState.active) {
                startCoBrowsing(coBrowsingState.url,true);
            }
        };

        let processRefreshOffer = function () {
            if (coBrowsingState.active) {
                refreshCoBrowsing();
            }
        };

        App.waiting = App.cable.subscriptions.create({
            channel: "CoBrowsingChannel",
            roomuid: bg.attr("room"),
            useruid: bg.attr("user")
        }, {
            connected: function() {
                console.log("connected");
            },

            disconnected: function(data) {
                console.log("disconnected");
                console.log(data);
            },

            rejected: function() {
                console.log("rejected");
            },

            received: function(data){
                console.log(data);
                if(data.action === "share"){
                    startCoBrowsing(data.url,data.readonly==='1');
                }else{
                    if (data.action === "unshare"){
                        stopCoBrowsing();
                    }else{
                        if (data.action === "refresh"){
                            processRefreshOffer();
                        }
                    }
                }
            }
        });
    }
});

