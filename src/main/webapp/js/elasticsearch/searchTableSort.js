$(function() {

    $('[data-toggle="tooltip"]').tooltip()

    // $('.tablesorter').tablesorter({
    //     theme: 'blue',
    //     showProcessing: true,
    //     headerTemplate : '',
    //     widgets: [  'zebra',  'scroller' ],
    //     widgetOptions : {
    //         scroller_height : 400,
    //         // scroll tbody to top after sorting
    //         scroller_upAfterSort: true,
    //         // pop table header into view while scrolling up the page
    //         scroller_jumpToHeader: true,
    //         // In tablesorter v2.19.0 the scroll bar width is auto-detected
    //         // add a value here to override the auto-detected setting
    //         scroller_barWidth : null
    //         // scroll_idPrefix was removed in v2.18.0
    //         // scroller_idPrefix : 's_'
    //     }
    // });
    $("#resultsTable").tablesorter({
        // widthFixed : true,
        theme : 'blue',
        headerTemplate : '',
        showProcessing: true,
        widgets: ['zebra','filter'],
        widgetOptions: {
            // jQuery selector or object to attach sticky header to
            // stickyHeaders_attachTo: $('.table-wrapper'),
            scroller_height : 500,
            // scroll tbody to top after sorting
            scroller_upAfterSort: true,
            // pop table header into view while scrolling up the page
            scroller_jumpToHeader: true,

            scroller_fixedColumns : '1',
            // In tablesorter v2.19.0 the scroll bar width is auto-detected
            // add a value here to override the auto-detected setting
            scroller_barWidth : null,
            // scroll_idPrefix was removed in v2.18.0
            // scroller_idPrefix : 's_',

            scroller_addFixedOverlay : false,
            // add hover highlighting to the fixed column (disable if it causes slowing)
            scroller_rowHighlight : 'hover',
            filter_columnFilters: false,
            filter_saveFilters : true,
            filter_reset: '.reset'

        }
    });
    $.tablesorter.filter.bindSearch( '#myTable', $('.search') );
    $("#myTable").trigger("update");
    $(window).trigger('resize');

    const divToShow = document.getElementById('resultsTable');
    divToShow.style.display = 'block';

    //jumps to top of the table once sorting is finished. Alternative to scroller_upAfterSort: true,
    $("#myTable").on("sortEnd", function() {
        $('#resultsTable').animate({ scrollTop: 0 }, 'fast');
    });
    $('#resultsTable').show();
    $('#topScrollWrapper').show();
    // Update top scrollbar width after table is visible - retry until width is set
    function tryUpdateScrollWidth(attempts) {
        if (typeof updateTopScrollWidth === 'function') {
            updateTopScrollWidth();
            var content = document.getElementById('topScrollContent');
            var table = document.getElementById('myTable');
            if (content && table && attempts > 0) {
                var tableWidth = table.scrollWidth || table.offsetWidth;
                if (tableWidth <= 0 || content.style.width === '' || content.style.width === '0px') {
                    setTimeout(function() { tryUpdateScrollWidth(attempts - 1); }, 100);
                }
            }
        }
    }
    tryUpdateScrollWidth(10);
    addDescription()
});


function addDescription(){
    const tableHeaders=document.querySelectorAll(".column-header-description");
    tableHeaders.forEach(element=>{
        element.innerHTML='<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-info-circle" viewBox="0 0 16 16"> <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"/> <path d="m8.93 6.588-2.29.287-.082.38.45.083c.294.07.352.176.288.469l-.738 3.468c-.194.897.105 1.319.808 1.319.545 0 1.178-.252 1.465-.598l.088-.416c-.2.176-.492.246-.686.246-.275 0-.375-.193-.304-.533zM9 4.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0"/></svg>'


    })
}

function signOut() {
    var auth2 = gapi.auth2.getAuthInstance();
    auth2.signOut().then(function () {
        console.log('User signed out.');
    });


    var redirectURL='/scge/home';
    var form = $('<form action="' + redirectURL + '">');
    $('body').append(form);
    form.submit();
}

