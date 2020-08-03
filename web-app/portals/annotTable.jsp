<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotation" %>
<%-- requires the following declarations in the master file:

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotation" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermSynonym" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="java.util.List" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntAnnotBean" />
--%>
<%
    FormUtility fu = new FormUtility();
%>

<script type="text/javascript">
    function addParam(name, value) {
        var re = new RegExp(name + "=[^\&]*");
        if( re.exec(location.href) != null ) {
            location.href = location.href.replace(re, name + "=" + value);
        }
        else {
            location.href = location.href + "&" + name + "=" + value;
        }
    }

    function addParamToLocHref(name, value) {
        addParamToLocHref(name, value, null);
    }

    function addParamToLocHref(name, value, anchor) {
        var re = new RegExp(name + "=[^\&]*");
        var href = location.href, anchor_pos;

        if( re.exec(href) != null ) { // simply replace value for parameter 'name'
            href = href.replace(re, name + "=" + value);
        }
        else { // parameter not found in href
            // cannot simply append to the end of url, because an anchor could be already there
            anchor_pos = href.lastIndexOf('#');
            if( anchor_pos>=0 ) {
                // append name=value BEFORE the anchor
                href = href.substring(0, anchor_pos) + "&" + name + "=" + value + href.substring(anchor_pos);
            }
            else { // no anchor part present -- just append to the end
                href = href + "&" + name + "=" + value;
            }
        }

        // handle new anchor
        if( anchor ) {
            // replace anchor, if there is already an chor in href
            anchor_pos = href.lastIndexOf('#');
            if( anchor_pos>=0 ) // replace anchor
                href = href.substring(0, anchor_pos) + anchor;
            else // append anchor
                href += anchor;
        }

        // force the browser to redirect to new url
        location.href = href;
    }
</script>
    <a name="annot"></a>
    <table border="0" style="padding-top:20px;" width="100%"><tr><td>
    <div id="searchResultHeader">
        <ul>
            <li<c:if test="${bean.speciesTypeKey==3}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Rat','#annot')">Rat</a></li>
            <li<c:if test="${bean.speciesTypeKey==2}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Mouse','#annot')">Mouse</a></li>
            <li<c:if test="${bean.speciesTypeKey==1}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Human','#annot')">Human</a></li>
            <c:if test="${bean.showAnnotsForAllSpecies}">
            <li<c:if test="${bean.speciesTypeKey==0}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','All','#annot')">All</a></li>
            </c:if>
            <li><input type="checkbox" <c:if test="${bean.withChildren}">checked="checked"</c:if> onchange="addParamToLocHref('with_children','<%=bean.isWithChildren()?0:1%>','#annot')">
            show annotations for term's descendants</li>
            <li> &nbsp; &nbsp; Sort by:<%=fu.buildSelectList("sort_by\" onChange=\"addParamToLocHref('sort_by',this.options[selectedIndex].text,'#annot')", bean.getSortByChoices(), bean.getSortBy())%></li>
            <li><select name="sort_desc" onChange="addParamToLocHref('sort_desc',this.options[selectedIndex].value,'#annot')" title="ascending/descending sort order">
                <option value="0" <c:if test="${bean.sortDesc==false}">selected="selected"</c:if>>&uarr; asc</option>
                <option value="1" <c:if test="${bean.sortDesc==true}">selected="selected"</c:if>>&darr; desc</option>
            </select></li>
        </ul>
    </div>
    </td></tr></table>

    <div id="searchResultWrapperTable" style="margin-right:25px;">
        <div id="searchResult">
        <table border='0' cellpadding='2' cellspacing='2' width="100%">
          <%  for( Map.Entry<Term, List<OntAnnotation>> entry: bean.getAnnots().entrySet() ) {
                 Term term = entry.getKey();
          %>
             <tr class='srH1' align="left"><th colspan="12">
                    <a href="/rgdweb/ontology/annot.html?acc_id=<%=term.getAccId()%>&species=<%=bean.getSpecies()%>"><%=term.getTerm()%></a>
                    <a href="/rgdweb/ontology/view.html?acc_id=<%=term.getAccId()%>"><img src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser" border="0"></a>
             </th></tr>
             <tr class='headerRow'>
                 <c:if test="${!bean.pheno}">
                 <td><b>Symbol</b></td>
                 <td><b>Object Name</b></td>
                 <!--<td><c:if test="${bean.hasQualifiers}"><b>Qualifiers</b></c:if></td>-->
                 <td><b>Evidence</b></td>
                 <td><b>Chr</b></td>
                 <td><b>Start</b></td>
                 <td><b>Stop</b></td>
                 <td>&nbsp;</td>
                 </c:if>
                 <c:if test="${bean.pheno}">
                 <td><b>Strain</b></td>
                 <td><b>Study</b></td>
                 <td><b>Experiment</b></td>
                 <td><b>Record</b></td>
                 <td><b>Chr</b></td>
                 <td><b>Start</b></td>
                 <td><b>Stop</b></td>
                 <td><b>Reference</b></td>
                  </c:if>
             </tr>
              <% int row=0;
                  for( OntAnnotation annot: entry.getValue() ) {
                  if( row++ % 2 == 1 )
                    out.print("<tr class='oddRow'>");
                  else
                    out.print("<tr class='evenRow'>"); %>

                <td><a href="/rgdweb/report/<%=annot.getRgdObjectName()%>/main.html?id=<%=annot.getRgdId()%>"><%=annot.getSymbol()%></a></td>
                <td><%=annot.getName()%></td>
                <!--<td><%=annot.getQualifier()%></td>-->
                <td><a href="/rgdweb/report/annotation/main.html?term=<%=term.getAccId()%>&id=<%=annot.getRgdId()%>"><%=annot.getEvidence()%></a></td>
                <td class="mid"><%=annot.getChr()%></td>
                <td class="num"><%=annot.getStartPos()%></td>
                <td class="num"><%=annot.getStopPos()%></td>
                <!--<td><%=annot.getReference()%></td>-->
                <td align="center"><% String jbrowseLink = annot.getJBrowseLink();
                    if( jbrowseLink!=null ) {%>
                      <a href="<%=jbrowseLink%>"><img alt="JBrowse link" border="0" title="JBrowse link" height="19" width="80" src="/rgdweb/common/images/jbrowse.png"/></a>
                <%}%></td>
              </tr>
            <% }} %>

            </tr>
        </table>
        </div>
    </div>
