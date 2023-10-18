function regHeader(title) {
    document.getElementById(title).onclick = getTermDetail;
    document.getElementById(title + "_i").onclick = getTermDetail;
    document.getElementById(title + "_content").style.display = "none";
}

function getTermDetail(e) {


    if (!e) e = window.event;
    var obj = document.all ? e.srcElement : e.currentTarget;

    if (document.all) {
        if (obj.id.indexOf("_i") != -1) {
            var name = obj.id.substring(0,obj.id.indexOf("_i"));
            obj=document.getElementById(name);
        }
        window.event.cancelBubble = true;
    }else {

    }

    //$("#new-nav").html("Loading......  (may take up to 60 seconds for large gene sets)");

        $.ajax({
            url: "/rgdweb/ga/termDetail.html",
            data: {species:'<%=req.getParameter("species")%>', genes: "<%=om.getMappedAsString()%>", acc:"<%=acc%>"  },
            type: "POST",
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                document.getElementById("new-nav").innerHTML = msg + xhr.status + " " + xhr.statusText + "<br>" + url;
            },
            success: function(data) {
                alert(data);
                document.getElementById("new-nav").innerHTML = data;
                //regHeader("cross1");

            }
    });


        var content =  document.getElementById(obj.id + "_content");
        if (content) {
            if (content.style.display == "block") {
                content.style.display="none";
                document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/add.png";
            }else {
                content.style.display="block";
                document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/remove.png";
            }
        }

}


function showSection(e) {

    if (!e) e = window.event;
    var obj = document.all ? e.srcElement : e.currentTarget;

    if (document.all) {
        if (obj.id.indexOf("_i") != -1) {
            var name = obj.id.substring(0,obj.id.indexOf("_i"));
            obj=document.getElementById(name);
        }
        window.event.cancelBubble = true;
    }else {

    }

        var content =  document.getElementById(obj.id + "_content");
        if (content) {
            if (content.style.display == "block") {
                content.style.display="none";
                document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/add.png";
            }else {
                content.style.display="block";
                document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/remove.png";
            }
        }

}
