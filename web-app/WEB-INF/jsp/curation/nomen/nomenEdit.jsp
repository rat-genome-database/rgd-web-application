<%@ page import="edu.mcw.rgd.nomenclatureinterface.*" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>

<%
    String pageTitle = "Nomenclature Edit";
    String headContent = "";
    String pageDescription = "";
    
%>

<%@ include file="/common/headerarea.jsp"%>

<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: Jan 15, 2008
  Time: 2:39:07 PM
  To change this template use File | Settings | File Templates.
--%>

<style type="text/css">
    .selectedPage a{
        color: red;
    }
    .unselectedPage a{
        color: blue;
    }
</style>

  <script type="text/javascript" src="../../js/calendarDateInput.js">

  /***********************************************
  * Jason's Date Input Calendar- By Jason Moon http://calendar.moonscript.com/dateinput.cfm
  * Script featured on and available at http://www.dynamicdrive.com
  * Keep this notice intact for use.
  ***********************************************/

  </script>

<script type="text/javascript">
    function showDate(id) {
        document.getElementById(id).style.visibility="visible";
    }

    function hideDate(id) {
        document.getElementById(id).style.visibility="hidden";
    }

    function acceptAllChanges() {
        i = 0;
        while (document.getElementById("c" + i) != null) {
            document.getElementById("c" + i).checked = true;
            i++;
        }
    }
    function rejectAllChanges() {
        i = 0;
        while (document.getElementById("d" + i) != null) {
            document.getElementById("d" + i).checked = true;
            i++;
        }
    }
</script>
<br>

  <%
      SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy");

      HttpRequestFacade req = new HttpRequestFacade(request);
      String from = req.getParameter("from");
      String to = req.getParameter("to");
      String dateSearch=req.getParameter("dateSearch");
      String keywordSearch=req.getParameter("keywordSearch");
      String keyword = req.getParameter("keyword").toLowerCase();

      SearchResult result = (SearchResult) request.getAttribute("SearchResult");
      List list = result.getNomenclatureResultBeans();
      Iterator it = list.iterator();

      if (result.getTotalCount() != 0) {
  %>
  <form action="nomenEdit.html" method="get" name="nomen">
      <input type="hidden" name="keyword" value ="<%=keyword%>" />
      <input type="hidden" name="from" value ="<%=from%>" />
      <input type="hidden" name="to" value ="<%=to%>" />
      <input type="hidden" name="dateSearch" value ="<%=dateSearch%>" />
      <input type="hidden" name="keywordSearch" value ="<%=keywordSearch%>" />
      
      <table border=0>
          <tr>
              <td width="150">Results:<%=result.getStartIndex()%> to <%=result.getEndIndex()%> of <%=result.getTotalCount()%></td>
              <td width="100" align="right"><a href="nomenEdit.html?pageNo=<%=result.getPreviousePage()%>&keyword=<%=keyword%>&from=<%=from%>&to=<%=to%>&dateSearch=<%=dateSearch%>&keywordSearch=<%=keywordSearch%>"><< Previous</a><td>&nbsp;</td>
              <td width="100"><a href="nomenEdit.html?pageNo=<%=result.getNextPage()%>&keyword=<%=keyword%>&from=<%=from%>&to=<%=to%>&dateSearch=<%=dateSearch%>&keywordSearch=<%=keywordSearch%>">Next >></a></td>
              <td width="300" align="right"><input onClick="acceptAllChanges();" type="button" name="acceptAll" value="Accept All"/>&nbsp;&nbsp;&nbsp;<input onClick="rejectAllChanges();" type="button" name="rejectAll" value="Reject All"/>&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Submit Changes"/></td>
          </tr>
      </table>

      <table border="0">
        <tr style="background-color: #2865a3;">
            <td></td>
            <td style="color: #ffffff; font-weight:700;">RGD ID</td>
            <td style="color: #ffffff; font-weight:700;">Symbol</td>
            <td style="color: #ffffff; font-weight:700;">Name</td>
        </tr>

      <%      

      int count=0;
      while (it.hasNext()) {
        NomenclatureResultBean bean = (NomenclatureResultBean) it.next();
        %>
            <input type="hidden" name="rgdId<%=count%>" value="<%=bean.getGene().getRgdId()%>" />
        <tr>
            <td><b><%=SpeciesType.getTaxonomicName(3)%></b></td>
            <td><%=bean.getGene().getRgdId()%></td>
            <td><%=bean.getGene().getSymbol()%></td>
            <td><%=bean.getGene().getName()%></td>
        </tr>

        <%
            Iterator oit = bean.getOrthologList().iterator();
            while (oit.hasNext()) {
                Gene ortholog = (Gene) oit.next();
        %>
            <tr>
                <td><b><%=SpeciesType.getTaxonomicName(ortholog.getSpeciesTypeKey())%>:</b></td>
                <td><%=ortholog.getRgdId()%></td>
                <td><%=ortholog.getSymbol()%></td>
                <td><%=ortholog.getName()%></td>
            </tr>
        <%
            }
            String proposedSymbol = "";
            String proposedName = "";            
            if (bean.getProposedGene() != null) {
                proposedSymbol = bean.getProposedGene().getSymbol();
                proposedName = bean.getProposedGene().getName();

                if (bean.getProposedGene().getSpeciesTypeKey() == SpeciesType.HUMAN) {
                    //if it's a human ortholog, lowercase the part of the symbol
                    proposedSymbol = proposedSymbol.substring(0,1).toUpperCase() +proposedSymbol.substring(1).toLowerCase();                                                            
                }
            }
        %>

        <tr>
            <td colspan=1><b>Proposed Change</b></td>
            <td colspan=1></td>
            <td><input type="text" name="symbol<%=count%>" size="25" value="<%=proposedSymbol%>"/></td>
            <td><input type="text" name="name<%=count%>" size="75" value="<%=proposedName%>"/></td>
        </tr>
        <tr>
            <%
                GregorianCalendar gc = new GregorianCalendar();
                gc.setTime(new Date());
                gc.add(Calendar.YEAR, 1);
            %>

            <td colspan=3 style="background-color: #b6baba;"><input type="radio" onClick="hideDate('dateInput<%=count%>')" name="c<%=count%>" value="skip" CHECKED>Skip  <input type="radio"  onClick="hideDate('dateInput<%=count%>')" id="c<%=count%>" name="c<%=count%>" value="accept">Accept:  <input type="radio" name="c<%=count%>"  onClick="showDate('dateInput<%=count%>')" value="reject" id="d<%=count%>">Reject:  <input type="radio" name="c<%=count%>"  onClick="showDate('dateInput<%=count%>')" value="update">Update:</td><td style="background-color: #b6baba;"><div id="dateInput<%=count%>" style="visibility: hidden;"><table><tr><td>Next Nomenclature Review: </td><td><script>DateInput('reviewDate<%=count%>', true, 'MM/DD/YYYY','<%=format.format(gc.getTime())%>')</script></div> </td></tr></table></td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <%
        count++;
      }
  %>
            <input type="hidden" name="pageNo" value="<%=result.getPage()%>" />
        </table>

<table border=0>
    <tr>
        <td width="150">Results:<%=result.getStartIndex()%> to <%=result.getEndIndex()%> of <%=result.getTotalCount()%></td>
        <td width="100" align="right"><a href="nomenEdit.html?pageNo=<%=result.getPreviousePage()%>&keyword=<%=keyword%>&from=<%=from%>&to=<%=to%>&dateSearch=<%=dateSearch%>&keywordSearch=<%=keywordSearch%>"><< Previous</a><td>&nbsp;</td>
        <td width="100"><a href="nomenEdit.html?pageNo=<%=result.getNextPage()%>&keyword=<%=keyword%>&from=<%=from%>&to=<%=to%>&dateSearch=<%=dateSearch%>&keywordSearch=<%=keywordSearch%>">Next >></a></td>
        <td width="300" align="right"><input onClick="acceptAllChanges();" type="button" name="acceptAll" value="Accept All"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Submit Changes"/></td>
    </tr>
</table>                             

        <%
        String style = "";

        if (result.getTotalPages() > 1) {
            out.println("<br>Jump to page...<table border=0><tr>");
        }

        for (int i =1; i<= result.getTotalPages(); i++) {
            if (i == result.getPage()) {
                style = "selectedPage";
            }else {
                style="unselectedPage";
            }
            if ((i-1) % 25 == 0) {
                out.print("</tr><tr>");
            }
        %>
            <td class="<%=style%>" ><a href="nomenEdit.html?pageNo=<%=i%>&keyword=<%=keyword%>&from=<%=from%>&to=<%=to%>&dateSearch=<%=dateSearch%>&keywordSearch=<%=keywordSearch%>"><%=i%></a></td>
        <%
        }
        %>
    </tr>

    </table>

<% } else {
        out.println("<br><br>0 results returned");
    }//end if totalcount = 0 %>

     </form>
<%@ include file="/common/footerarea.jsp"%>