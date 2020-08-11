<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
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

    int withKids = 0;
    if (bean.isWithChildren()) {
        withKids=1;
    }
%>



<script type="text/javascript">
    function addParam(name, value) {
        var re = new RegExp("[\&]"+name + "=[^\&]*");
        if( re.exec(location.href) != null ) {
            location.href = location.href.replace(re, "&" + name + "=" + value);
        }
        else {
            location.href = location.href + "&" + name + "=" + value;
        }
    }

    function addParamToLocHref(name, value) {
        addParamToLocHref(name, value, null);
    }

    function addParamToLocHref(name, value, anchor) {

        var href1 = location.href, anchor_pos;

        // case1: href1 contains '?name=' param
        var t = '?'+name+'=';
        var p1 = href1.lastIndexOf(t);
        if( p1>=0 ) { // replace the value
            p1 += t.length;
            href1 = href1.substring(0, p1) + value + href1.substring(endOfValuePos(href1, p1));
        } else { // case2: href1 contains '&name=' param
            t = '&'+name+'=';
            p1 = href1.lastIndexOf(t);
            if( p1>=0 ) { // replace the value
                p1 += t.length;
                href1 = href1.substring(0, p1) + value + href1.substring(endOfValuePos(href1, p1));
            } else {

                // case3: href1 does not contain 'name' param -- append the param
                //   cannot simply append to the end of url, because an anchor could be already there
                anchor_pos = href1.lastIndexOf('#');
                var sep = href1.lastIndexOf('?')>=0 ? '&' : '?';
                if( anchor_pos>=0 ) {
                    // append name=value BEFORE the anchor
                    href1 = href1.substring(0, anchor_pos) + sep + name + "=" + value + href1.substring(anchor_pos);
                }
                else { // no anchor part present -- just append to the end
                    href1 = href1 + sep + name + "=" + value;
                }
            }
        }

        // handle new anchor
        if( anchor ) {
            // replace anchor, if there is already anchor in href
            anchor_pos = href1.lastIndexOf('#');
            if( anchor_pos>=0 ) // replace anchor
                href1 = href1.substring(0, anchor_pos) + anchor;
            else // append anchor
                href1 += anchor;
        }

        // force the browser to redirect to new url
        location.href = href1;
    }

    // url param: get end position of a value
    function endOfValuePos(s, pos) {
        // end of a value can be '&', '#', or end of string
        var endPos1 = s.indexOf('&', pos);
        var endPos2 = s.indexOf('#', pos);
        var endPos3 = s.length;
        if( endPos1<0 )
            endPos1 = endPos3;
        if( endPos2<0 )
            endPos2 = endPos3;

        return Math.min(endPos1, endPos2, endPos3);
    }
</script>
    <a name="annot"></a>
    <table border="0" style="padding-top:20px;" width="100%">
        <tr>
            <td colspan="2"><input type="checkbox" <c:if test="${bean.withChildren}">checked="checked"</c:if> onclick="addParamToLocHref('with_children','<%=bean.isWithChildren()?0:1%>','#annot')">
                show annotations for term's descendants
<%--            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" <c:if test="${bean.extendedView}">checked="checked"</c:if> onclick="addParamToLocHref('x','<%=bean.isExtendedView()?0:1%>','#annot')" title="show more details"> view all columns</li>--%>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort by:<%=fu.buildSelectList("sort_by\" onChange=\"addParamToLocHref('sort_by',this.options[selectedIndex].text,'#annot')", bean.getSortByChoices(), bean.getSortBy())%>
                <select name="sort_desc" onChange="addParamToLocHref('sort_desc',this.options[selectedIndex].value,'#annot')" title="ascending/descending sort order"><option
                        value="0" <c:if test="${bean.sortDesc==false}">selected="selected"</c:if>>&uarr; asc</option><option
                        value="1" <c:if test="${bean.sortDesc==true}">selected="selected"</c:if>>&darr; desc</option></select>
                        <input type="button" value="download" onclick="addParamToLocHref('d','1','#annot')" title="download to file">

            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td>
                <%
                    OntologyXDAO xdao = new OntologyXDAO();
                    TermWithStats tws = xdao.getTermWithStatsCached(bean.getAccId());
                %>

    <div id="searchResultHeader">
        <ul style="border-bottom:2px solid #2865A3;">
            <li<c:if test="${bean.speciesTypeKey==3}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Rat','#annot')">Rat&nbsp;(<%=tws.getStat("annotated_object_count",3,0,withKids)%>)</a></li>
            <li<c:if test="${bean.speciesTypeKey==2}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Mouse','#annot')">Mouse&nbsp;(<%=tws.getStat("annotated_object_count",2,0,withKids)%>)</a></li>
            <li<c:if test="${bean.speciesTypeKey==1}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Human','#annot')">Human&nbsp;(<%=tws.getStat("annotated_object_count",1,0,withKids)%>)</a></li>
            <li<c:if test="${bean.speciesTypeKey==4}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Chinchilla','#annot')">Chinchilla&nbsp;(<%=tws.getStat("annotated_object_count",4,0,withKids)%>)</a></li>
            <li<c:if test="${bean.speciesTypeKey==5}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Bonobo','#annot')">Bonobo&nbsp;(<%=tws.getStat("annotated_object_count",5,0,withKids)%>)</a></li>
            <li<c:if test="${bean.speciesTypeKey==6}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Dog','#annot')">Dog&nbsp;(<%=tws.getStat("annotated_object_count",6,0,withKids)%>)</a></li>
            <li<c:if test="${bean.speciesTypeKey==7}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Squirrel','#annot')">Squirrel&nbsp;(<%=tws.getStat("annotated_object_count",7,0,withKids)%>)</a></li>
            <li<c:if test="${bean.speciesTypeKey==9}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','Pig','#annot')">Pig&nbsp;(<%=tws.getStat("annotated_object_count",9,0,withKids)%>)</a></li>
            <c:if test="${bean.showAnnotsForAllSpecies}">
            <li<c:if test="${bean.speciesTypeKey==0}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('species','All','#annot')">All</a></li>
            </c:if>

        </ul>
    </div>
    </td>
        </tr>
        <tr>
            <td>
                <div id="searchResultHeader">
                    <ul>
                        <% if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),1,withKids) > 0) { %>
                        <li <c:if test="${bean.objectKey<2}"> id="selected"</c:if> ><a href="javascript:addParamToLocHref('o','1','#annot')">Genes (<%=tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),1,withKids)%>)</a></li>
                        <% } %>

                        <% if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),6,withKids) > 0) { %>
                        <li <c:if test="${bean.objectKey==6}"> id="selected"</c:if>><a href="javascript:addParamToLocHref('o','6','#annot')">QTL (<%=tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),6,withKids)%>)</a></li>
                        <% } %>

                        <% if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),5,withKids) > 0) { %>
                        <li <c:if test="${bean.objectKey==5}"> id="selected"</c:if>><a href="javascript:addParamToLocHref('o','5','#annot')">Strains (<%=tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),5,withKids)%>)</a></li>
                        <% } %>

                        <% if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),7,withKids) > 0) { %>
                        <li <c:if test="${bean.objectKey==7}"> id="selected"</c:if>><a href="javascript:addParamToLocHref('o','7','#annot')">Variants (<%=tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),7,withKids)%>)</a></li>
                        <% } %>

                        <% if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),11,withKids) > 0) { %>
                        <li <c:if test="${bean.objectKey==11}"> id="selected"</c:if>><a href="javascript:addParamToLocHref('o','11','#annot')">Cell Lines (<%=tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),11,withKids)%>)</a></li>
                        <% } %>
                    </ul>
                </div>
            </td></tr>

    </table>

    <%  edu.mcw.rgd.datamodel.Map refMap = MapManager.getInstance().getReferenceAssembly(bean.getSpeciesTypeKey());
        int mapKey = refMap!=null ? refMap.getKey() : 0;

        if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),bean.getObjectKey(),withKids) > 2000) { %>

<br><br>
<div style="padding:30px; border: 3px solid #FFCF3E; font-size:20px;">

    This term has <%=tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),bean.getObjectKey(),withKids)%> annotated objects.

    The list is too large to display.  <br><br>

    <li><a style="font-size:18px;" href="/rgdweb/ontology/view.html?acc_id=<%=bean.getAccId()%>">Select a more specific term using the term browser</a>

    <li><a style="font-size:18px;" href="javascript:addParamToLocHref('d','1','#annot')"/>Download the entire list for this term</a>


    <% if (bean.isWithChildren()) {%>
    <li><a style="font-size:18px;" href="javascript:addParamToLocHref('with_children','0','#annot')"/>Display annotations for this term only (exclude descendants)</a>


    <% } %>

</div>

<br><br>

<%} else if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),bean.getObjectKey(),withKids) < 1) { %>

<div style="padding:30px; border: 3px solid #FFCF3E; font-size:20px;">

    0 Annotations Found<br><br>

    <li><a style="font-size:18px;" href="/rgdweb/ontology/view.html?acc_id=<%=bean.getAccId()%>">Select a less specific term using the term browser</a>

</div>


<% } else {%>

    <div id="searchResultWrapperTable" style="margin-right:25px;">
        <div id="searchResult">
        <table border='0' cellpadding='2' cellspacing='2' width="100%">
          <%  int sectionCount=0;
              for( Map.Entry<Term, List<OntAnnotation>> entry: bean.getAnnots().entrySet() ) {
                  sectionCount++;
                 Term term = entry.getKey();
          %>
             <tr class='srH1' align="left"><th colspan="14">
                 <table width="95%" style="background-color:#B0C4DE;">
                     <tr>
                         <td><a style="font-size:16px;" href="<%=Link.ontAnnot(term.getAccId())%>&species=<%=bean.getSpecies()%>"><%=term.getTerm()%></a>
                             <a href="<%=Link.ontView(term.getAccId())%>"><img src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser" border="0"></a>
                         </td>
                         <td align="right">

                             <% if( bean.getObjectKey()==1 && mapKey!=0 ) { %>
                                <img src="/rgdweb/common/images/tools-white-50.png" style="cursor:hand; border: 2px solid black;" border="0" ng-click="rgd.showTools('list<%=sectionCount%>',<%=bean.getSpeciesTypeKey()%>,<%=mapKey%>,1 , '')"/>
                            <% } %>
                         </td>
                     </tr>
                 </table>
             </tr>
             <tr class='headerRow'>
                 <td></td>
                 <c:if test="${bean.speciesTypeKey==0}"><td></td></c:if>
                 <td><b>Symbol</b></td>
                 <td><b>Object Name</b></td>
                 <td><b>JBrowse</b></td>

                 <td><c:if test="${bean.hasQualifiers}"><b>Qualifiers</b></c:if></td>
                 <td><b>Evidence</b></td>

                 <td><b>Chr</b></td>
                 <td><b>Start</b></td>
                 <td><b>Stop</b></td>
                 <td><b>Reference</b></td>
                 <td><b>Source</b></td>
                 <td><b>Original Reference(s)</b></td>
                 <td><b>Notes</b></td>
             </tr>
            <% int row=0;
                  for( OntAnnotation annot: entry.getValue() ) {
                      String speciesName = SpeciesType.getCommonName(annot.getSpeciesTypeKey());
                  if( row++ % 2 == 1 )
                    out.print("<tr class='oddRow'>");
                  else
                    out.print("<tr class='evenRow'>"); %>

                <td class="objtag_<%=annot.getRgdObjectName()%>" title=" <%=annot.getRgdObjectName()%> "><%=annot.getObjectTypeInitial()%></td>
                <c:if test="${bean.speciesTypeKey==0}"><td title="<%=speciesName%>"><%=speciesName.substring(0, 1)%></td></c:if>

                <% //check to see if symbol should be used by tool submit logic
                    String toolSubmitClass=" ";
                    if (annot.getRgdObjectName().equals("gene")) {
                        toolSubmitClass=" class='list" + sectionCount + "' ";
                    }
                %>
                <td><a <%=toolSubmitClass%> href="/rgdweb/report/<%=annot.getRgdObjectName()%>/main.html?id=<%=annot.getRgdId()%>"><%=annot.getSymbol()%></a></td>
                <td><%=annot.getName()%></td>
                <td><% String jbrowseLink = annot.getJBrowseLink();
                    if( jbrowseLink!=null ) {%>
                      <a href="<%=jbrowseLink%>"><img alt="JBrowse link" border="0" title="JBrowse link" height="19" width="80" src="/rgdweb/common/images/jbrowse.png"/></a>
                <%}%></td>

                    <td><%=annot.getQualifier()%></td>
                <td><a href="/rgdweb/report/annotation/<%
                    if( term.getAccId().startsWith("CHEBI") ) { out.print("table"); } else { out.print("main"); }
                   %>.html?term=<%=term.getAccId()%>&id=<%=annot.getRgdId()%>" title="view annotation report"><%=annot.getEvidence()%></a></td>

                <td class="mid"><%=annot.getChr()%>
                    <% if(annot.getChrEns()!=null){%>
                        <br><%=annot.getChrEns()%></br>
                    <%}%>
                </td>
                <td class="num"><%=annot.getStartPos()%>
                        <% if(annot.getChrEns()!=null){%>
                    <br><%=annot.getStartPosEns()%></br>
                        <%}%>
                <td class="num"><%=annot.getStopPos()%>
                <% if(annot.getChrEns()!=null){%>
            <br><%=annot.getStopPosEns()%></br>
                <%}%>
                <td><%=annot.getReference()%></td>
                <td><%=annot.getDataSource()%></td>
                <td><%=annot.getXrefSource()%></td>
                <td><%=annot.getNotes()%></td>
              </tr>
            <% }    } %>

            </tr>
        </table>
        </div>
    </div>
<% } %>
<% if( bean.isPhenoData() ) { %>
<%@ include file="phenoTable.jsp" %>
<% } %>
