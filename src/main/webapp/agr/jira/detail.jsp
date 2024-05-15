<%@ page import="java.net.http.HttpClient" %>
<%@ page import="java.net.http.HttpResponse" %>
<%@ page import="org.apache.http.client.methods.HttpGet" %>
<%@ page import="java.net.http.HttpRequest" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.core.JsonParser" %>
<%@ page import="com.fasterxml.jackson.databind.JsonNode" %>
<%@ page import="com.fasterxml.jackson.core.type.TypeReference" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="edu.mcw.rgd.agr.JiraTicket" %>
<%@ page import="java.util.*" %>
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

<style>
    html * {
        font-size: 15px;
        line-height: 1.225;
        font-color:#B8BDC8;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;
    }
</style>

<body style="">


<%

    String apiToken="ATATT3xFfGF0dgMX0s4lPJN89OV-FAvAcJs4u_VbA5BZM4foM_5Xz579hWad31R_xjQVLsQClweAtdJWMa5Ve538-3uU0FNnFi62F7UGnbZa2nzcj1hdqq_HTnmsGZq5sMwDXxtnjL8O6vzcto00LSdZiBpVaG7mbpA2RU-e1lrKDV5OIpKPr5U=070133F3";
    String valueToEncode = "jdepons@mcw.edu:" + apiToken;

    HttpRequest restRequest = HttpRequest.newBuilder()
            .GET()
            .uri(java.net.URI.create(request.getParameter("s") +"/issue"))
            .header("Content-Type", "application/json")
            .header("Authorization", "Basic  " + Base64.getEncoder().encodeToString(valueToEncode.getBytes()))
            .build();

    HttpResponse<String> restResponse = null;
        HttpClient client = HttpClient.newHttpClient();
         restResponse = client.send(restRequest, HttpResponse.BodyHandlers.ofString());

    //JSONObject objects = new JSONObject ();
    JSONObject objects = new JSONObject(restResponse.body());
    JSONArray issues = objects.getJSONArray("issues");

%>
<table>

<%
/*
Public Website
VEP
Loader
Ribbons
Neo4J
File Mgmt System
Ferret
AllianceMine
Curation
PersistentStore
A-Team Deployments
A-Team Data Loading
A-Team LinkML
A-Team work for Blue Team
ID Minting
MaTI Deployments
*/


    HashMap<String, JiraTicket> publicTickets = new HashMap<String, JiraTicket>();
    HashMap<String, JiraTicket> curationTickets = new HashMap<String, JiraTicket>();
    HashMap<String, JiraTicket> otherTickets = new HashMap<String, JiraTicket>();
    HashMap<String, ArrayList<JiraTicket>> publicSubTickets = new HashMap<String, ArrayList<JiraTicket>>();
    HashMap<String, ArrayList<JiraTicket>> curationSubTickets = new HashMap<String, ArrayList<JiraTicket>>();
    //HashMap<String, Integer> points = new HashMap<String, Integer>();
    //points.put("total",0);

    int totalPoints=0;
    int publicPoints=0;
    int curationPoints=0;
    int otherPoints=0;

    for (int i = 0; i < issues.length (); ++i) {
        boolean isPublic = false;
        boolean isCuration = false;

        JiraTicket ticket = new JiraTicket();

        JSONObject issue = new JSONObject(issues.getString(i));
        ticket.setKey(issue.getString("key"));

        System.out.println(issue.getString("key"));

        JSONObject fields = new JSONObject(issue.getString("fields"));
        JSONArray components = fields.getJSONArray("components");

        ArrayList<String> comp = new ArrayList<String>();
                for (int k=0; k< components.length();k++) {
           JSONObject c =  components.getJSONObject(k);
           String compString = c.getString("name");
           comp.add(c.getString("name"));
           //out.print("-" + compString+"-");
            if (compString.equals("Public Website")
            || compString.equals("VEP")
             || compString.equals("Loader")
              || compString.equals("Ribbons")
               || compString.equals("Neo4J")
                || compString.equals("File Mgmt System")
                 || compString.equals("Ferret")
            || compString.equals("AllianceMine")) {
                isPublic=true;
            }else if (compString.equals("Curation")
            || compString.equals("PersistentStore")
             || compString.equals("A-Team Deployments")
              || compString.equals("A-Team Data Loading")
               || compString.equals("A-Team LinkML")
                || compString.equals("A-Team work for Blue Team")) {
                isCuration=true;
            }
        }
        // Define the predefined order
        String[] predefinedOrder = {
            "Public Website","Curation","ID Minting","UI","Indexer","Search","DevOps","API",  "VEP", "Loader",
            "Ribbons", "Neo4J", "File Mgmt System","Architecture","Basic Gene Info (BGI)",
            "Ferret", "AllianceMine",  "PersistentStore", "A-Team Deployments",
             "A-Team Data Loading", "A-Team LinkML", "A-Team work for Blue Team",
             "MaTI Deployments","BioSchemas","Disease","DQM",
            "Expression","Expression - LTP","Interactions"
        };

        // Create a map to store the predefined order with their indices
        Map<String, Integer> orderMap = new HashMap<>();
        for (int j = 0; j < predefinedOrder.length; j++) {
            orderMap.put(predefinedOrder[j], j);
        }

        // Sort the ArrayList using the custom comparator
        Collections.sort(comp, new Comparator<String>() {
            @Override
            public int compare(String o1, String o2) {
                System.out.println("checking " + o1 + " - " + o2);
                int compare = 0;
                try {
                    compare = Integer.compare(orderMap.get(o1), orderMap.get(o2));
                }catch (Exception e) {

                }
                System.out.println("returning " + compare);
                return compare;
            }
        });



        if (comp.size() > 1) {
            if (comp.get(0).equals("Curation") || comp.get(0).equals("Public Website")) {
                if (comp.size() > 2) {
                    ArrayList<String> comp2 = new ArrayList<String>();
                    comp2.add(comp.get(0));
                    comp2.add(comp.get(1));
                    comp = comp2;
                }
            }else {
                    ArrayList<String> comp2 = new ArrayList<String>();
                    comp2.add(comp.get(0));
                    comp = comp2;
            }
        }

        // Print the sorted ArrayList
        for (String project : comp) {
            System.out.println(project);
        }

        ticket.setComponents(comp);
        //out.println("<br>tag: " + components.getString("name"));

        //JSONObject resolution = null;

        //JSONObject resolution = fields.getJSONObject("resolution");
        //ticket.setResolution(resolution.getString("name"));
        ticket.setSummery(fields.getString("summary"));
        ticket.setDescription(fields.getString("description"));

        try {
            ticket.setStoryPoints(Integer.parseInt(fields.getString("customfield_10012")));
            totalPoints+=ticket.getStoryPoints();
            if (isPublic) {
                publicPoints +=ticket.getStoryPoints();
            }else if (isCuration) {
                curationPoints+=ticket.getStoryPoints();
            }else {
                otherPoints += ticket.getStoryPoints();
            }
        }catch (Exception ignored) {

        }

        if (isPublic) {
            if (ticket.getComponents().size() > 1) {
                //we have sub tickets
                for (String comp2: ticket.getComponents()) {
                    if (!comp2.equals("Public Website")) {
                        ArrayList<JiraTicket> pjt = new ArrayList<JiraTicket>();
                        if (publicSubTickets.get(comp2) != null) {
                            pjt = publicSubTickets.get(comp2);
                        }
                        pjt.add(ticket);
                        publicSubTickets.put(comp2,pjt);
                    }
                }
            }else {
                publicTickets.put(ticket.getKey(),ticket);
            }

        }else if (isCuration) {
            if (ticket.getComponents().size() > 1) {
                for (String comp2: ticket.getComponents()) {
                    if (!comp2.equals("Curation")) {

                        ArrayList<JiraTicket> pjt = new ArrayList<JiraTicket>();
                        if (curationSubTickets.get(comp2) != null) {
                            pjt = curationSubTickets.get(comp2);
                        }
                        pjt.add(ticket);
                        curationSubTickets.put(comp2,pjt);
                    }
                }
            }else {
                curationTickets.put(ticket.getKey(),ticket);
            }
        }else {
            otherTickets.put(ticket.getKey(),ticket);
        }
    }

    String sid = request.getParameter("sid");

%>

<table border="0" align="center">
    <tr>
        <td align="center" colspan="2" ><div style="padding-top:20px; padding-bottom:20px; width:100%;background-color:#579DFF;font-weight:700;">Sprint Accomplishments</div></td>
    </tr>
    <tr>
        <td style="background-color:#E9F2FF;" valign="top">
            <div style="ackground-color:#E9F2FF;padding-left:10px;padding-right:5px;height:100%;width:100%;padding-top:20px;"><%=request.getParameter("n")%></div>
        </td>
        <td>
            <table border="1" cellpadding=4 cellspacing=0 width="750" align="center" bordercolor="lightGrey" >
                <tr>
                    <td>Sprint Goal</td>
                    <td><%=request.getParameter("g")%></td>
                </tr>
                <tr>
                    <td>Dates</td>
                    <td><%=request.getParameter("start")%> - <%=request.getParameter("end")%></td>
                </tr>
                <tr>
                    <td>Jira Tickets</td>
                    <td><a href='https://agr-jira.atlassian.net/issues/?jql=project = SCRUM AND issuetype in standardIssueTypes() AND status = Done AND Sprint = <%=sid%> AND "Team[Dropdown]" = A-Team ORDER BY created DESC'>Completed Tickets</a></td>
                </tr>
                <tr>
                    <td>Burndown Chart</td>
                    <td><a href="https://agr-jira.atlassian.net/jira/software/c/projects/SCRUM/boards/66/reports/burndown-chart?sprint=<%=sid%>">Burndown Chart</a></td>
                </tr>
                <tr>
                    <td>Burnup Chart</td>
                    <td><a href="https://agr-jira.atlassian.net/jira/software/c/projects/SCRUM/boards/66/reports/burnup-chart?sprint=<%=sid%>">Burnup Chart</a></td>
                </tr>
                <tr>
                    <td valign="top">Accomplishments</td>
                    <td>
                        <ol type="1" style="padding-left:20px;">
                            <!--<li>Total points: <b><%=totalPoints%> points</b></li>-->
                            <li>Public Website <!--<b>(<%=publicPoints%> points)</b>--></li>
                                <ol type="a">
                            <%
                                int cnt=97;
                                for (String tixid: publicTickets.keySet()) {
                                    JiraTicket pt = publicTickets.get(tixid);
                            %>
                                     <li><%=pt.getSummery()%> (<a href="https://agr-jira.atlassian.net/browse/<%=pt.getKey()%>"><%=pt.getKey()%></a>;&nbsp;<b><%=pt.getStoryPoints()%> points</b>)</li>
                            <%
                                }
                            %>
                                    <%  for (String subTixid: publicSubTickets.keySet()) {%>
                                    <!--<li><%=subTixid%></li>-->
                                    <!--<ol type="i">-->
                                        <%
                                            ArrayList<JiraTicket> ptList = publicSubTickets.get(subTixid);
                                            for (JiraTicket jt: ptList) {

                                        %>
                                        <li><%=jt.getSummery()%> (<a href="https://agr-jira.atlassian.net/browse/<%=jt.getKey()%>"><%=jt.getKey()%></a>;&nbsp;<b><%=jt.getStoryPoints()%> points</b>)</li>
                                        <%
                                            }
                                        %>
                                    <!--</ol>-->
                                    <% }%>


                                </ol>
                                    <li>Curation Software and Persistent Store <!--<b>(<%=curationPoints%> points)</b>--></li>
                                        <ol type="a">
                                        <%
                                cnt =97;
                                for (String tixid: curationTickets.keySet()) {
                                    JiraTicket pt = curationTickets.get(tixid);
                            %>
                                            <li><%=pt.getSummery()%> (<a href="https://agr-jira.atlassian.net/browse/<%=pt.getKey()%>"><%=pt.getKey()%></a>;&nbsp;<b><%=pt.getStoryPoints()%> points</b>)</li>
                            <%
                                }
                            %>
                                           <%  for (String subTixid: curationSubTickets.keySet()) {%>
                                              <!--<li><%=subTixid%></li>-->
                                           <!--<ol type="i">-->
                                            <%
                                            ArrayList<JiraTicket> ptList = curationSubTickets.get(subTixid);
                                            for (JiraTicket jt: ptList) {

                                           %>
                                               <li><%=jt.getSummery()%> (<a href="https://agr-jira.atlassian.net/browse/<%=jt.getKey()%>"><%=jt.getKey()%></a>;&nbsp;<b><%=jt.getStoryPoints()%> points</b>)</li>
                                            <%
                                                    }
                                            %>
                                           <!--</ol>-->
                                               <% }%>



                            </ol>
                                            <li>Other Tickets <b>(<%=otherPoints%> points)</b></li>
                                            <ol type="a">
                            <%
                                cnt =97;
                                for (String tixid: otherTickets.keySet()) {
                                JiraTicket pt = otherTickets.get(tixid);
                            %>
                                <li><%=pt.getSummery()%> (<a href="https://agr-jira.atlassian.net/browse/<%=pt.getKey()%>"><%=pt.getKey()%></a>;&nbsp;<b><%=pt.getStoryPoints()%> points</b>)</li>

                                <!--
                                                <ul>
                                    <% for (String comp1: pt.components) { %>
                                    <li><%=comp1%></li>
                                    <%
                                        }
                                    %>
                                </ul>
                                -->
                            <%
                                }
                            %>

                                            </ol>
                                    </ol>
        </td>
    </tr>
</table>



</body>
</html>
