<%@ taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core' %>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="edu.mcw.rgd.dao.impl.MyDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.myrgd.MyList" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.Gson" %>
<%
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    String name = auth.getName();

    Gson gson = new Gson();

    MyDAO mydao = new MyDAO();
    List<MyList> myLists = mydao.getUserObjectLists(name);

    out.print(gson.toJson(myLists));

%>