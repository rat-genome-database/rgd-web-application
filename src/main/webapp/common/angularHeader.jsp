<%@ page import="org.apache.http.HttpRequest" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.dao.impl.MyDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.myrgd.MyList" %>
<%@ page import="edu.mcw.rgd.security.UserManager" %>

<meta name="viewport" content="width=device-width, initial-scale=1">

<link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
<%--<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>--%>
<script src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
<script src="/rgdweb/common/bootstrap/js/bootstrap.js"></script>
<script type="text/javascript" src="/rgdweb/common/angular.min.js"></script>

<%
    String name = UserManager.getInstance().getMyUser(request).getUsername();

    HttpRequestFacade req = new HttpRequestFacade(request);

    String lid=req.getParameter("lid");

    MyDAO myDAO = new MyDAO();

    String listName = "";
    String listDescription = "";
    MyList mlist = null;

    try {
        mlist = myDAO.getUserObjectList(Integer.parseInt(lid));
    }catch (Exception e) {
    }

    if (mlist != null) {
        listName = mlist.getName();
        listDescription = mlist.getDesc();
    }

%>





<div class="container">
    <!-- Modal -->
    <div class="modal fade" id="myModal" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content" id="rgd-model">
            </div>
        </div>
    </div>
</div>
