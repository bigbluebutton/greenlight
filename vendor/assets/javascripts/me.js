$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})
console.log("Sheila My Precious, How I Miss!");

function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    var expires = "expires=" + d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

var cookieName = 'Tour';
$(function() {
    checkCookie();
});

function checkCookie() {
    if (document.cookie.length > 0 && document.cookie.indexOf(cookieName + '=') != -1) {
        // do nothing, cookie already sent
    } else if ('showRoom' == $('guide').attr('data-tour')) {
        $(function() {
            console.log('Ninsiima');
            const tourSteps = [{
                element: ".container",
                popover: {
                    className: "int",// className to wrap driver.js popover
                    overlayClickNext: true,// Should it move to next step on overlay click
                    closeBtnText: 'Hide',
                    nextBtnText: "Start Guide",// Next button text for this step
                    title: "Welcome To WebShule",
                    description: "Where School Comes To You.",
                    position: "center",
                    
                },
                onHighlightStarted: ()=>{
                    if ('Hide'== $('.driver-close-btn').text());{
                    console.log('Editor')
                    $(".driver-prev-btn,.driver-close-btn").css("display","none");
                    $(".driver-popover-footer").css("padding","0 32%");
                    console.log("Sheila & Oasis Add Mido & Go");
                    }
                }
            }, {
                element: "#user-text",
                popover: {
                    title: "General Class",
                    description: "This is a General Class which you can use for one on one discussions (Teacher & Student) or private group discussion (Students)"
                }
            }, {
                element: "#create-room-block",
                popover: {
                    title: "Create New Class",
                    description: "Click Here to create a new Class or click on an existing Class to join it"
                }
            }, {
                element: ".stat",
                popover: {
                    title: "Class Statistics",
                    description: "Your current Class Statistics will show up here."
                },
                onHighlightStarted: ()=>{
                    $(".stat").addClass("stats");
                }
            },  {
                element: "#copy",
                popover: {
                    title: "Invite Link",
                    description: "Click here to copy the Invite Link.<br>Share it to invite others to your Class."
                }
            }, {
                element: "#schedule",
                popover: {
                    title: "Class Schedule",
                    description: "Create a Schedule for your next Class from here (Teachers).<br><sub>This only works with Google Calender</sub>"
                },
                onHighlightStarted: ()=>{
                    $("#driver-highlighted-element-stage").removeClass("sCircle");
                }
            }, {
                element: ".circle",
                popover: {
                    padding: 20,
                    title: "Start Class",
                    description: "Start the currently selected Class"
                },
                onHighlightStarted: ()=>{
                    $("#driver-highlighted-element-stage").addClass("sCircle");
                }
            }];

            const Tour = new Driver({
                className: 'tour',
                // className to wrap driver.js popover
                // animate: true,  // Animate while changing highlighted element
                opacity: 0.75,// Background opacity (0 means only popovers and without overlay)
                // padding: 10,    // Distance of element from around the edges
                allowClose: false,// Whether clicking on overlay should close or not
                overlayClickNext: false,// Should it move to next step on overlay click
                doneBtnText: 'Done',// Text on the final button
                closeBtnText: 'End Tour',// Text on the close button for this step
                nextBtnText: 'Next',// Next button text for this step
                // prevBtnText: 'Previous', // Previous button text for this step
                // showButtons: false, // Do not show control buttons in footer
                // keyboardControl: true, // Allow controlling through keyboard (escape to close, arrow keys to move)
                // scrollIntoViewOptions: {}, // We use `scrollIntoView()` when possible, pass here the options for it if you want any
                // onHighlightStarted: (Element) {}, // Called when element is about to be highlighted
                // onHighlighted: (Element) {}, // Called when element is fully highlighted
                // onDeselected: (Element) {}, // Called when element has been deselected
                // onReset: (Element) {},        // Called when overlay is about to be cleared
                // onNext: (Element) => {},      // Called when moving to next step on any step
                // onPrevious: (Element) => {},  // Called when moving to next step on any step
            });

            Tour.defineSteps(tourSteps);
            $(function() {
                Tour.start();
            });
        });
        // set the cookie to show user has already visited
        setCookie('Tour', '1', 365);   
    }
}
