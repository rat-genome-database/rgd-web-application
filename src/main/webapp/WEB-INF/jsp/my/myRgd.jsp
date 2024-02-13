<%@ taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core' %>
<%@ page import="edu.mcw.rgd.dao.impl.MyDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.myrgd.MyList" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="edu.mcw.rgd.security.UserManager" %>
<%
    String name = UserManager.getInstance().getMyUser(request).getUsername();


    Gson gson = new Gson();

    MyDAO mydao = new MyDAO();
    List<MyList> myLists = mydao.getUserObjectLists(name);

    out.print(gson.toJson(myLists));

%>