<%@ page import="java.net.http.HttpClient" %>
<%@ page import="java.net.http.HttpResponse" %>
<%@ page import="org.apache.http.client.methods.HttpGet" %>
<%@ page import="java.net.http.HttpRequest" %>
<%@ page import="java.util.Base64" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.core.JsonParser" %>
<%@ page import="com.fasterxml.jackson.databind.JsonNode" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.fasterxml.jackson.core.type.TypeReference" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.BufferedReader" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: 10/20/23
  Time: 11:07 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>

<%
    StringBuilder content = new StringBuilder();

    try (BufferedReader reader = new BufferedReader(new FileReader("/Users/jdepons/jira.key"))) {
        //try (BufferedReader reader = new BufferedReader(new FileReader("/data/conf/jira.key"))) {
        String line;
        while ((line = reader.readLine()) != null) {
            content.append(line);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }

    String apiToken = content.toString();
    String valueToEncode = "jdepons@mcw.edu:" + apiToken;

    HttpRequest restRequest = HttpRequest.newBuilder()
            .GET()
            .uri(java.net.URI.create("https://agr-jira.atlassian.net/rest/agile/1.0/board/66/sprint/?startAt=40"))
            .header("Content-Type", "application/json")
            .header("Authorization", "Basic  " + Base64.getEncoder().encodeToString(valueToEncode.getBytes()))
            .build();

    HttpResponse<String> restResponse = null;
    HttpClient client = HttpClient.newHttpClient();
    restResponse = client.send(restRequest, HttpResponse.BodyHandlers.ofString());

    //JSONObject objects = new JSONObject ();
    JSONObject objects = new JSONObject(restResponse.body());
    JSONArray issues = objects.getJSONArray("values");

%>
<table cellpadding="5" align="center">
    <tr style="background-color:#579DFF;">
        <th>
            Jira ID
        </th>
        <th>Sprint Name</th>
        <th>Start Date</th>
        <th>End Date</th>
        <th>Status</th>
        <th></th>
    </tr>

<%
    for (int i = 0; i < issues.length (); ++i) {
        JSONObject issue = new JSONObject(issues.getString(i));
        String start = issue.getString("startDate").substring(0,10);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date startDate = sdf.parse(start);

        String end = issue.getString("endDate").substring(0,10);
        Date endDate = sdf.parse(end);


        SimpleDateFormat jiraFormat = new SimpleDateFormat("MMMM d, yyyy");

        String startDateString=jiraFormat.format(startDate);
        String endDateString=jiraFormat.format(endDate);
%>
    <tr>
        <td><%=issue.getString("id")%></td>
        <td><a href="detail.jsp?s=<%=issue.getString("self")%>&g=<%=issue.getString("goal")%>&sid=<%=issue.getString("id")%>&n=<%=issue.getString("name")%>&start=<%=startDateString%>&end=<%=endDateString%>"><%=issue.getString("name")%></a></td>
        <td><%=startDateString%></td>
        <td><%=endDateString%></td>
        <td><b><%=issue.getString("state")%></b></td>
        <td><a href='https://agr-jira.atlassian.net/issues/?jql=project = SCRUM AND issuetype in standardIssueTypes() AND status = Done AND Sprint = <%=issue.getString("id")%> AND "Team[Dropdown]" = A-Team ORDER BY created DESC'>tickets</a></td>
        <!--
        <td><a href="https://agr-jira.atlassian.net/jira/software/c/projects/SCRUM/boards/66/reports/burndown-chart?sprint=<%=issue.getString("id")%>">Burndown Chart</a></td>
        <td><a href="https://agr-jira.atlassian.net/jira/software/c/projects/SCRUM/boards/66/reports/burnup-chart?sprint=181">Burnup Chart</a></td>
        <td>Goal: <%=issue.getString("goal")%></td>
        -->
    </tr>

<%
    }
%>
</table>


    <%


    //gson.fromJson(restResponse.body());

%>



</body>
</html>
