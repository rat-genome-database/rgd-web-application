<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="org.elasticsearch.search.SearchHit" %>
<%--<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>--%>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>


<script src="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.js"></script>
<link href="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.css"/>

<link href="/rgdweb/common/tablesorter-2.18.4/css/filter.formatter.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>
<script>
    $(function () {
        $("#findModelsTable").tablesorter({
            theme: 'blue',
            widthFixed: false,
            widgets: ['zebra',"filter",'resizable', 'stickyHeaders'],

        })
    })


</script>
<style>
    .tablesorter thead .disabled {display: none}
</style>
<%
        String term1 = (String) request.getAttribute("term");
        String aspect2 = (String) request.getAttribute("aspect");
        String qualifier = (String) request.getAttribute("qualifier");
        List<SearchHit[]> searchHits = (List) request.getAttribute("searchHits");
        String strainType = (String) request.getAttribute("strainType");
        String condition1 = (String) request.getAttribute("condition");
        int hitsCount1 = (Integer) request.getAttribute("hitsCount");
%>
<h3><%=hitsCount1%> results for term "<%=term1%>
    <% if (aspect2.equals("D")){%>
    &nbsp;&&nbsp;Disease&nbsp;<%=qualifier%>
    <% }
    if (aspect2.equals("N")) {%>
    &nbsp;&&nbsp;Phenotype&nbsp;<%=qualifier%>
    <% }
    if (strainType!=null && !strainType.isEmpty()){%>
    &nbsp;&&nbsp;<%=strainType%>
    <% }
    if (condition1!=null && !condition1.isEmpty()){%>
    &nbsp;&&nbsp;<%=condition1%>
    <% } %>
    "
</h3>

<table id="findModelsTable" class="tablesorter">
    <thead>
    <tr>
        <th class="tablesorter-header"data-placeholder="Search for strain..." >Strain</th>
        <!--th>Model RGD ID</th>
        <th>Species</th-->
        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Considered as type ...</th>
        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Disease/Phenotype</th>

        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">With conditions</th>

        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Evidence Code</th>
        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Reference</th>

    </tr>
    </thead>
    <tbody>
    <% for (SearchHit[] hitArray : searchHits) {
        for (int i = 0; i < hitArray.length; i++) {
            SearchHit hit = hitArray[i];
            List<Object> refRgdIds;
            String qualifiers = (String) hit.getSourceAsMap().get("qualifiers");
            List infoTerms = (List) hit.getSourceAsMap().get("infoTerms");
            List evidences = (List) hit.getSourceAsMap().get("evidences");
            refRgdIds = (List<Object>) hit.getSourceAsMap().get("refRgdIds");%>
            <tr>
                <td><a href="/rgdweb/report/strain/main.html?id=<%=hit.getSourceAsMap().get("annotatedObjectRgdId")%>"><%=hit.getSourceAsMap().get("annotatedObjectSymbol")%></a></td>
                <td>
                    <%=Utils.NVL(qualifiers,"")%>
                </td>
<%--                    <% for (Object q : qualifiers){%>--%>
<%--                    <%=q.toString()%>--%>
<%--                    <% } %>--%>

<%--                    <c:forEach items="${hit.getSourceAsMap().qualifiers}" var="q">--%>
<%--                        <c:out value="${q}"/>&nbsp;--%>
<%--                    </c:forEach>--%>

                <td><a href="/rgdweb/report/annotation/main.html?term=<%=hit.getSourceAsMap().get("termAcc")%>&id=<%=hit.getSourceAsMap().get("annotatedObjectRgdId")%>"><%=hit.getSourceAsMap().get("term")%></a> &nbsp;&nbsp;<a href="/rgdweb/ontology/view.html?acc_id=<%=hit.getSourceAsMap().get("termAcc")%>"><img border="0" src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser"></a>
                </td>
                <td>
                    <%boolean first = true;
                    if (infoTerms != null){
                    for (Object obj : infoTerms) {
                        HashMap map = (HashMap) obj;
                    if (first){%>
                    <a href="/rgdweb/ontology/annot.html?acc_id=<%=map.get("accId")%>"><%=map.get("term")%></a>
                    <%first=false;}
                    else {%>
                    |&nbsp;<a href="/rgdweb/ontology/annot.html?acc_id=<%=map.get("accId")%>"><%=map.get("term")%></a>
                    <% }
                    }// end infoTerms for
                    }%>
                </td>

                <td>
                    <%for (Object obj : evidences){
                        HashMap e = (HashMap) obj;%>
                    <span title="<%=e.get("name")%>" ><%=e.get("evidence")%></span>
                    <% } %>
                </td>
                <td>
                    <% if(refRgdIds!=null){
                        for (Object ref : refRgdIds) {%>
                    <a href="/rgdweb/report/reference/main.html?id=<%=ref%>"><%=ref%></a>&nbsp;
                    <% } }%>
                </td>

            </tr>
    <%
        } }
    %>
    </tbody>
</table>
