<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.edit.GeneMergeBean" />
<% String headContent = "\n" +
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/common/search.css\">\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/css/ontology.css\">\n";

   String pageTitle = "Gene Merge Summary - Object Edit - Rat Genome Database";
   String pageDescription = pageTitle;
%>
<style>
    .gminrgd {
        color: black;
        font-weight: normal;
    }
    .gmnew {
        color: green;
        font-weight: bold;
    }
    .gmignored {
        color: red;
        font-weight: bold;
        text-decoration: line-through;
    }
</style>
<%@ include file="/common/headerarea.jsp"%>
<div style="margin-left:10px;">
<h2>GENE MERGE TOOL - STEP 3 - MERGE SUMMARY </h2>

<form action="/rgdweb/curation/edit/editObject.html" method="GET">

<TABLE BORDER="">
    <TR>
        <TH></TH>
        <TH>Merge From (RGD ID:<%=bean.getRgdIdFrom().getRgdId()%>)</TH>
        <TH>Merge To (RGD ID:<%=bean.getRgdIdTo().getRgdId()%>)</TH>
    </TR>
    <TR>
        <TH colspan="3" style="background-color: #b2d1ff;">GENES</TH>
    </TR>
    <TR>
        <TD>Symbol:</TD>
        <TD><%=bean.getGeneFrom().getSymbol()%> [object status:<%=bean.getRgdIdFrom().getObjectStatus()%>]</TD>
        <TD><%=bean.getGeneTo().getSymbol()%> [object status:<%=bean.getRgdIdTo().getObjectStatus()%>]</TD>
    </TR>
    <TR>
        <TD>Name:</TD>
        <TD><%=bean.getGeneFrom().getName()%></TD>
        <TD><%=bean.getGeneTo().getName()%></TD>
    </TR>

    <TR>
        <TD>Aliases</TD>
        <% if( bean.getAliasesNew().size()>0 ) { %>
        <TD class="gmnew">inserted: <%=bean.getAliasesNew().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
        <% if( bean.getAliasesNewIgnored().size()>0 ) { %>
        <TD class="gmignored">ignored: <%=bean.getAliasesNewIgnored().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
    </TR>

    <TR>
        <TD>Notes</TD>
        <% if( bean.getNotesNew().size()>0 ) { %>
        <TD class="gmnew">inserted: <%=bean.getNotesNew().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
        <% if( bean.getNotesNewIgnored().size()>0 ) { %>
        <TD class="gmignored">ignored: <%=bean.getNotesNewIgnored().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
    </TR>

    <TR>
        <TD>Curated References</TD>
        <% if( bean.getCuratedRefNew().size()>0 ) { %>
        <TD class="gmnew">inserted: <%=bean.getCuratedRefNew().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
        <% if( bean.getCuratedRefIgnored().size()>0 ) { %>
        <TD class="gmignored">ignored: <%=bean.getCuratedRefIgnored().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
    </TR>

    <TR>
        <TD>Map Data</TD>
        <% if( bean.getMapDataNew().size()>0 ) { %>
        <TD class="gmnew">inserted: <%=bean.getMapDataNew().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
        <% if( bean.getMapDataIgnored().size()>0 ) { %>
        <TD class="gmignored">ignored: <%=bean.getMapDataIgnored().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
    </TR>

    <TR>
        <TD>Annotations</TD>
        <% if( bean.getAnnotsNew().size()>0 ) { %>
        <TD class="gmnew">inserted: <%=bean.getAnnotsNew().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
        <% if( bean.getAnnotsIgnored().size()>0 ) { %>
        <TD class="gmignored">ignored: <%=bean.getAnnotsIgnored().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
    </TR>

    <TR>
        <TD>Database Links</TD>
        <% if( bean.getXdbidsNew().size()>0 ) { %>
        <TD class="gmnew">inserted: <%=bean.getXdbidsNew().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
        <% if( bean.getXdbidsIgnored().size()>0 ) { %>
        <TD class="gmignored">ignored: <%=bean.getXdbidsIgnored().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
    </TR>

    <TR>
        <TD>Nomenclature events</TD>
        <% if( bean.getNomenNew().size()>0 ) { %>
        <TD class="gmnew">inserted: <%=bean.getNomenNew().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
        <% if( bean.getNomenIgnored().size()>0 ) { %>
        <TD class="gmignored">ignored: <%=bean.getNomenIgnored().size()%></TD>
        <% } else { %>
        <TD>&nbsp;</TD>
        <% } %>
    </TR>

    <TR>
        <TH colspan="4" align="center"><input type="submit" name="Submit" value="New gene pair"></TH>
    </TR>
</TABLE>
</form>
</div>
<%@ include file="/common/footerarea.jsp"%>
