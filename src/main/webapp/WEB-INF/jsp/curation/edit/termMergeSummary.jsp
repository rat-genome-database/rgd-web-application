<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermSynonym" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.edit.TermMergeBean" />
<% String headContent = "\n" +
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/common/search.css\">\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/css/ontology.css\">\n";

   String pageTitle = "Term Merge - Object Edit - Rat Genome Database";
   String pageDescription = pageTitle;

   String accIdFrom = bean.getTermFrom().getAccId();
   String accIdTo = bean.getTermTo().getAccId();
%>
<%@ include file="/common/headerarea.jsp"%>
<div style="margin-left:10px;">
<h2>TERM MERGE TOOL - SUMMARY</h2>

<TABLE BORDER="">
    <TR>
        <TH style="background-color: #b2d1ff;">MERGE FROM &nbsp; <a href="<%=Link.ontView(accIdFrom)%>"><%=accIdFrom%></a></TH>
        <TH style="background-color: #b2d1ff;">MERGE TO &nbsp; <a href="<%=Link.ontView(accIdTo)%>"><%=accIdTo%></a></TH>
    </TR>
    <TR>
        <TD><b><%=bean.getTermFrom().getTerm()%></b></TD>
        <TD><b><%=bean.getTermTo().getTerm()%></b></TD>
    </TR>
    <TR>
        <TD> &nbsp; is-obsolete: <%=bean.getTermFrom().isObsolete()?"true":"false"%></TD>
        <TD> &nbsp; is-obsolete: <%=bean.getTermTo().isObsolete()?"true":"false"%></TD>
    </TR>

    <TR>
        <TD VALIGN="top">synonyms:<br>
    <% for(TermSynonym ts1: bean.getExistingSynonyms() ) {
         if( !ts1.getTermAcc().equals(accIdFrom) ) continue;
    %>
        [<%=ts1.getType()%>] <%=ts1.getName()%> {<%=ts1.getSource()%>}<br>
    <% } %>
        </TD>
        <TD VALIGN="top">synonyms:<br>
    <% for(TermSynonym ts2: bean.getExistingSynonyms() ) {
         if( !ts2.getTermAcc().equals(accIdTo) ) continue;
    %>
        [<%=ts2.getType()%>] <%=ts2.getName()%> {<%=ts2.getSource()%>}<br>
    <% } %>
        </TD>
    </TR>

    <TR>
        <TD VALIGN="top">parent terms:<br>
        <% for(Term t1: bean.getTermFromParents() ) { %>
            <%=t1.getAccId()%> [<%=t1.getTerm()%>]<br>
        <% } %>
        </TD>
        <TD VALIGN="top">parent terms:<br>
        <% for(Term t2: bean.getTermToParents() ) { %>
            <%=t2.getAccId()%> [<%=t2.getTerm()%>]<br>
        <% } %>
        </TD>
    </TR>

    <TR>
        <TD VALIGN="top">child terms:<br>
            <% for(Term t1: bean.getTermFromChildren() ) { %>
            <%=t1.getAccId()%> [<%=t1.getTerm()%>]<br>
            <% } %>
        </TD>
        <TD VALIGN="top">child terms:<br>
            <% for(Term t2: bean.getTermToChildren() ) { %>
            <%=t2.getAccId()%> [<%=t2.getTerm()%>]<br>
            <% } %>
        </TD>
    </TR>

    <TR>
        <TD colspan="2" align="center"  style="background-color: #b2d1ff;">
            Merge complete! Reload RDO ontology and recompute stats.
        </TD>
    </TR>
</TABLE>
</div>
<%@ include file="/common/footerarea.jsp"%>
