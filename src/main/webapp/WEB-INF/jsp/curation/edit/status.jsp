<%@ page import="java.util.ArrayList" %>
<%
    ArrayList error = (ArrayList) request.getAttribute("error");
    boolean noError = error==null || error.isEmpty();
    boolean redirectToCurationTool = false;

    // if no error and 'update_and_curate' parameter is available, automatically redirect to curation tool
    if( noError ) {
        String param = request.getParameter("update_and_curate");

        if( param!=null && !param.isEmpty() ) {
            redirectToCurationTool = true;
        } else if(request.getParameter("clone_and_curate") != null)
            redirectToCurationTool = true;
    }
    System.out.print(redirectToCurationTool);
    if( redirectToCurationTool ) {
%><head><META http-equiv="refresh" content="0;URL=/rgdCuration/?module=curation&func=linkAnnotation#title"></head><%
    }

    if (error != null) {
        for (Object err : error) {
            out.println("<span style=\"color:red;\">" + err + "</span><br>");
        }
    }

    ArrayList status = (ArrayList) request.getAttribute("status");
    if (status !=null) {
        for (Object stat: status) {
            out.println("<span style=\"color:blue;\">" + stat + "</span><br><a href=/rgdCuration/?module=curation&func=linkAnnotation#title>Curation Tool</a>");
        }
    }

    if( redirectToCurationTool ) {
%><p><span style="color:red;">Redirecting to curation tool ...</span><br><%
    }
%>