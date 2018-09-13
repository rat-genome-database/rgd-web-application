
<script>
<%

 	String url = "species=" + req.getParameter("species");

 	Iterator uit = req.getParameterValues("o").iterator();
 	while (uit.hasNext()) {
 	url += "&o=" + uit.next();
 	}

 	uit = req.getParameterValues("x").iterator();
 	while (uit.hasNext()) {
 	url += "&x=" + uit.next();
 	}

 	uit = req.getParameterValues("ortholog").iterator();
 	while (uit.hasNext()) {
 	url += "&ortholog=" + uit.next();
 	}

 	url+="&chr=" + req.getParameter("chr");
 	url+="&start=" + req.getParameter("start");
 	url+="&stop=" + req.getParameter("stop");
 	url+="&mapKey=" + req.getParameter("mapKey");

 	%>



    function postIt(path, params) {

        if (!params) {
           params= new Object();
        }

        var form = document.createElement("form");

        form.setAttribute("method", "<%=method%>");
        form.setAttribute("action", path);

        params.species="<%=req.getParameter("species")%>";
       // params.genes="";
        params.chr="<%=req.getParameter("chr")%>";
        params.start="<%=req.getParameter("start")%>";
        params.stop="<%=req.getParameter("stop")%>";
        params.mapKey="<%=req.getParameter("mapKey")%>";

        <%
        Iterator oit = req.getParameterValues("o").iterator();
        while (oit.hasNext()) {
        %>
            hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("name", "o");
            hiddenField.setAttribute("value", "<%=oit.next()%>");
            form.appendChild(hiddenField);
        <% } %>

        <%
        oit = req.getParameterValues("x").iterator();
        while (oit.hasNext()) {
        %>
            hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("name", "x");
            hiddenField.setAttribute("value", "<%=oit.next()%>");
            form.appendChild(hiddenField);
        <% } %>

        <%
        oit = req.getParameterValues("ortholog").iterator();
        while (oit.hasNext()) {
        %>
            hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("name", "ortholog");
            hiddenField.setAttribute("value", "<%=oit.next()%>");
            form.appendChild(hiddenField);
        <% } %>

        for(var key in params) {
             var hiddenField = document.createElement("input");
             hiddenField.setAttribute("type", "hidden");
             hiddenField.setAttribute("name", key);
             hiddenField.setAttribute("value", params[key]);

             form.appendChild(hiddenField);
        }

        document.body.appendChild(form);
        form.submit();
    }


    function cross() {
        postIt("/rgdweb/pa/analysis.html");
    }

    function termCompare(term1,term2, countType, sid) {
        var sidId = sid;

        if (!sid) {
           sidId = "0";
        }

        if (document.getElementById("limit").checked) {
            params = {"term1":term1, "term2": term2, "countType": countType, "sid": sidId, "limit": "true"};
        }else {
            params = {"term1":term1, "term2": term2, "countType": countType, "sid": sidId};
        }

        postIt("/rgdweb/pa/termCompare.html",params);
    }

    function gviewer() {
        params = {"geneColor":"blue", "height": "200", "width": "700"};
        postIt("/rgdweb/gTool/displayViewer.jsp", params);
    }

    function selectGenes() {
        postIt("/rgdweb/pa/start.jsp");
    }

    var rgdIdValue=0;

    function viewReport(rgdId) {

        document.getElementById("content").innerHTML="<br><br>Loading....   Please Wait.<br><br><br><br><br><br><br>"

        if (!rgdId) {
            return;
        }

        rgdIdValue=rgdId;
        $.ajax({
            url: "/rgdweb/pa/report.html?<%=url%>&rgdId=" + rgdId,
            data: {value: 1},
            method: '<%=method%>',
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                alert('status:' + XMLHttpRequest.status + ', status text: ' + XMLHttpRequest.statusText);
            },
            success: function(data) {
                document.getElementById("content").innerHTML = data
            }
        });

    }

     function viewGviewer() {
         params = { "rgdId": rgdIdValue};
         postIt("/rgdweb/pa/genome.html", params);

     }

     </script>
