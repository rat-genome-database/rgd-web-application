<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.overgo.OligoSpawnRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.overgo.OligoSpawnWrapper" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.overgo.OligoSpawnResponse" %>

<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: Apr 25, 2011
  Time: 3:33:19 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>


<%
    String pageTitle = "Overgo Probe Designer";
    String headContent = "";
    String pageDescription = "Overgo Probe Designer - fasta files";

%>

<%@ include file="/common/headerarea.jsp"%>

<%
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req, new ArrayList());

    String cSize = "25";
    String topO = "1";
    String minGC = "45";
    String maxGC = "55";
    String lowTemp = "0";
    String highTemp="100";
    String filename="";

    if (request.getAttribute("contigSize") != null) {
        cSize=(String) request.getAttribute("contigSize");
    }
    if (request.getAttribute("-t") != null) {
        topO=(String) request.getAttribute("-t");
    }
    if (request.getAttribute("-g") != null) {
        minGC=(String) request.getAttribute("-g");
    }
    if (request.getAttribute("-G") != null) {
        maxGC=(String) request.getAttribute("-G");
    }
    if (request.getAttribute("-m") != null) {
        lowTemp=(String) request.getAttribute("-m");
    }
    if (request.getAttribute("-M") != null) {
        highTemp=(String) request.getAttribute("-M");
    }

%>


<h2>Overgo Probe Designer</h2>

  <form action="find.html" METHOD="POST" enctype="multipart/form-data">

  <table>
    <tr>
        <td>Region Size (kb)</td>
        <td><input type="text" value="<%=cSize%>" name="contigSize"></td>
        <td>&nbsp;</td>
         <td>Number of top oligos for each region</td>
         <td><input name="-t" type="text" value="<%=topO%>"></td>
      </tr>
      <tr>
          <td>Minimum GC content (%)</td>
          <td><input name="-g" type="text" value="<%=minGC%>"></td>
          <td>&nbsp;</td>
          <td>Maximum GC content (%)</td>
          <td><input name="-G" type="text" value="<%=maxGC%>"></td>
      </tr>
      <tr>
          <td>Lowest melting temperature (celsius)</td>
          <td><input name="-m" type="text" value="<%=lowTemp%>"></td>
          <td>&nbsp;</td>
          <td>Highest melting temperature (celsius)</td>
          <td><input name="-M" type="text" value="<%=highTemp%>"></td>
      </tr>
      <tr>
          <td>Fasta File:</td>
          <td colspan="5"><input type="file" name="filename" size="50" value="<%=filename%>"/></td>
      </tr>


      <tr>
          <td><input TYPE="submit" value="Submit"/> </td>
      </tr>

  </table>
  </form>

  <table border="0" >

 <%
 try {
     if (request.getAttribute("oligoSpawnRequests") != null) {
         List<OligoSpawnRequest> requests = (List)request.getAttribute("oligoSpawnRequests");

         if (requests.size() > 0 ) {
 %>

          <HR><span style="color: #2865a3; font-weight: 700; padding:4px;">Finding the top <%=req.getParameter("-t")%> unique oligos for each <%=request.getAttribute("contigSize")%> (kb) region in file...</span>
          <br>

          <%
          }

          int regionCount=1;
          for (OligoSpawnRequest osr: requests) {
            OligoSpawnWrapper osw = new OligoSpawnWrapper();
            OligoSpawnResponse overgo = osw.execute(osr);

            long start = osr.getContigSize() * osr.getContigIndex();
            long end = osr.getContigSize() * (osr.getContigIndex() + 1);

          if (overgo.getError().startsWith("Invalid option")) {
              %>
                <tr>
                    <td colspan="2" style="color:red;">Oligo Spawn ERROR: <%=overgo.getError()%></td>
                </tr>
            <%
              break;
          }
      %>

          <tr>
              <td colspan="2" style="background-color: #2865a3; color: white;"><b>Region <%=regionCount%>:&nbsp;&nbsp;</b> <%=start + 1 %>(bp) - <%=end %>(bp)</td>
          </tr>



      <%
            int count=0;
            for(String forward: overgo.getForward()) {
            %>

                <% if (forward != null) {  %>
                 <tr>
                    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                    <td>>Forward_<%=regionCount%>_<%=(count + 1)%></td>
                 </tr>
                 <tr>
                     <td></td>
                     <td><%=forward.substring(0,14)%><span style="font-weight:800;"><%=forward.substring(14,22)%></span></td>
                 </tr>
                 <tr><td></td></tr>
                 <tr>
                     <td>&nbsp;&nbsp;</td>
                     <td>>Reverse_<%=regionCount%>_<%=(count + 1)%></td>
                 </tr>
                 <tr>
                     <td></td>
                     <td><%=overgo.getReverse().get(count).substring(0,14)%><span style="font-weight:800;"><%=overgo.getReverse().get(count).substring(14,22)%></span></td>
                 </tr>
                <tr>
                    <td colspan="3">&nbsp;</td>
                </tr>
            <%
                count++;
                }
             }
             out.flush();
             regionCount++;
        }
    }else {
            out.print("resutl null");
    }
}catch(Exception e) {
    e.printStackTrace();                 
}
%>

  </table>

<%@ include file="/common/footerarea.jsp"%>