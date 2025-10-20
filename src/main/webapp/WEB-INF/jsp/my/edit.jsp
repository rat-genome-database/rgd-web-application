<%@ page import="edu.mcw.rgd.dao.impl.MyDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.myrgd.MyList" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.JsonParser" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="com.google.gson.JsonElement" %>
<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.security.UserManager" %>
<%

/*
 BufferedReader br =request.getReader();
 String line="";
 while ((line = br.readLine()) != null) {
  out.println(line);
 }

 if (true) {
  return;
 }
*/

 JsonParser parser = new JsonParser();

 JsonObject obj = (JsonObject) parser.parse(request.getReader());
 String name = obj.get("name").getAsString();
 String action = obj.get("action").getAsString();
 String desc = obj.get("desc").getAsString();
 String link = obj.get("url").getAsString();
 JsonArray genes = obj.get("genes").getAsJsonArray();

    String user = UserManager.getInstance().getMyUser(request).getUsername();

    if (user == null) {
       out.print("Error - user anonymous");
       return;
    }

    MyDAO mdao = new MyDAO();
    MyList mList = new MyList();

    mList.setUsername(user);
    mList.setObjectType(1);
    mList.setName(name);
    mList.setDesc(desc);
    mList.setLink(link);

    mdao.insertList(mList);

    GeneDAO gdao = new GeneDAO();

    ArrayList<String> sym = new ArrayList<String>();

    Iterator it = genes.iterator();

    while (it.hasNext()) {
      JsonObject gene = (JsonObject) it.next();
      sym.add(gene.get("gene").getAsString());
    }

    ObjectMapper om = new ObjectMapper();

    om.mapSymbols(sym,3);

    List<Integer> ids = om.getMappedRgdIds();

    mdao.insertGenes(mList.getId(), ids);

%>
