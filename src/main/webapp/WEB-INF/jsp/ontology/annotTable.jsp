<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.dao.impl.QTLDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.QTL" %>
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
        withKids = 1;
    }
%>


<script type="text/javascript">
    function addParam(name, value) {
        var re = new RegExp("[\&]" + name + "=[^\&]*");
        if (re.exec(location.href) != null) {
            location.href = location.href.replace(re, "&" + name + "=" + value);
        } else {
            location.href = location.href + "&" + name + "=" + value;
        }
    }

    function addParamToLocHref(name, value) {
        addParamToLocHref(name, value, null);
    }

    function addParamToLocHref(name, value, anchor) {

        var href1 = location.href, anchor_pos;

        // case1: href1 contains '?name=' param
        var t = '?' + name + '=';
        var p1 = href1.lastIndexOf(t);
        if (p1 >= 0) { // replace the value
            p1 += t.length;
            href1 = href1.substring(0, p1) + value + href1.substring(endOfValuePos(href1, p1));
        } else { // case2: href1 contains '&name=' param
            t = '&' + name + '=';
            p1 = href1.lastIndexOf(t);
            if (p1 >= 0) { // replace the value
                p1 += t.length;
                href1 = href1.substring(0, p1) + value + href1.substring(endOfValuePos(href1, p1));
            } else {

                // case3: href1 does not contain 'name' param -- append the param
                //   cannot simply append to the end of url, because an anchor could be already there
                anchor_pos = href1.lastIndexOf('#');
                var sep = href1.lastIndexOf('?') >= 0 ? '&' : '?';
                if (anchor_pos >= 0) {
                    // append name=value BEFORE the anchor
                    href1 = href1.substring(0, anchor_pos) + sep + name + "=" + value + href1.substring(anchor_pos);
                } else { // no anchor part present -- just append to the end
                    href1 = href1 + sep + name + "=" + value;
                }
            }
        }

        // handle new anchor
        if (anchor) {
            // replace anchor, if there is already anchor in href
            anchor_pos = href1.lastIndexOf('#');
            if (anchor_pos >= 0) // replace anchor
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
        if (endPos1 < 0)
            endPos1 = endPos3;
        if (endPos2 < 0)
            endPos2 = endPos3;

        return Math.min(endPos1, endPos2, endPos3);
    }

    $(function () {
        $(".more").hide();
        $(".moreLink").on("click", function (e) {

            var $this = $(this);
            var parent = $this.parent();
            var $content = parent.find(".more");
            var linkText = $this.text();

            if (linkText === "More...") {
                linkText = "Hide...";
                $content.show();
            } else {
                linkText = "More...";
                $content.hide();
            }
            $this.text(linkText);
            return false;

        });
    });
</script>
<br>
<a name="annot"></a>
<table border="0" style="padding-top:20px;" width="100%">
    <tr>
        <td colspan="1"><input type="checkbox" <%=bean.isWithChildren() ? "checked=\"checked\"" : ""%>
                               onclick="addParamToLocHref('with_children','<%=bean.isWithChildren()?0:1%>','#annot')">
            show annotations for term's descendants
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort
            by:<%=fu.buildSelectList("sort_by\" onChange=\"addParamToLocHref('sort_by',this.options[selectedIndex].text,'#annot')", bean.getSortByChoices(), bean.getSortBy())%>
            <select name="sort_desc"
                    onChange="addParamToLocHref('sort_desc',this.options[selectedIndex].value,'#annot')"
                    title="ascending/descending sort order">
                <option
                        value="0" <%=bean.isSortDesc() == false ? "selected=\"selected\"" : ""%> >&uarr; asc
                </option>
                <option
                        value="1" <%=bean.isSortDesc() == true ? "selected=\"selected\"" : ""%>>&darr; desc
                </option>
            </select>
            <input type="button" value="download annotations" onclick="addParamToLocHref('d','1','#annot')"
                   title="download to file">

        </td>
        <td>
            <%
                OntologyXDAO xdao = new OntologyXDAO();
                TermWithStats tws = xdao.getTermWithStatsCached(bean.getAccId());

                edu.mcw.rgd.datamodel.Map refMap = MapManager.getInstance().getReferenceAssembly(bean.getSpeciesTypeKey());
                int mapKey = refMap != null ? refMap.getKey() : 0;
            %>


            <% if (bean.getObjectKey() == 1 && mapKey != 0) { %>
            <img src="/rgdweb/common/images/tools-white-50.png"
                 style="margin-bottom:10px;cursor:hand; border: 2px solid black;" border="0"
                 ng-click="rgd.showTools('list1',<%=bean.getSpeciesTypeKey()%>,<%=mapKey%>,1 , '')"/>
            <% } %>

        </td>
    </tr>
    <tr>
        <td colspan="2">

            <div id="searchResultHeader">
                <ul style="border-bottom:2px solid #2865A3;">
                    <li <%=bean.getSpeciesTypeKey() == 3 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Rat','#gviewer')">Rat&nbsp;(<%=tws.getStat("annotated_object_count", 3, 0, withKids)%>
                        )</a></li>
                    <li <%=bean.getSpeciesTypeKey() == 2 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Mouse','#gviewer')">Mouse&nbsp;(<%=tws.getStat("annotated_object_count", 2, 0, withKids)%>
                        )</a></li>
                    <li <%=bean.getSpeciesTypeKey() == 1 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Human','#gviewer')">Human&nbsp;(<%=tws.getStat("annotated_object_count", 1, 0, withKids)%>
                        )</a></li>
                    <li <%=bean.getSpeciesTypeKey() == 4 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Chinchilla','#gviewer')">Chinchilla&nbsp;(<%=tws.getStat("annotated_object_count", 4, 0, withKids)%>
                        )</a></li>
                    <li <%=bean.getSpeciesTypeKey() == 5 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Bonobo','#gviewer')">Bonobo&nbsp;(<%=tws.getStat("annotated_object_count", 5, 0, withKids)%>
                        )</a></li>
                    <li <%=bean.getSpeciesTypeKey() == 6 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Dog','#gviewer')">Dog&nbsp;(<%=tws.getStat("annotated_object_count", 6, 0, withKids)%>
                        )</a></li>
                    <li <%=bean.getSpeciesTypeKey() == 7 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Squirrel','#gviewer')">Squirrel&nbsp;(<%=tws.getStat("annotated_object_count", 7, 0, withKids)%>
                        )</a></li>
                    <li <%=bean.getSpeciesTypeKey() == 9 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Pig','#gviewer')">Pig&nbsp;(<%=tws.getStat("annotated_object_count", 9, 0, withKids)%>
                        )</a></li>
                    <li <%=bean.getSpeciesTypeKey() == 13 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Green Monkey','#gviewer')">Green
                        Monkey&nbsp;(<%=tws.getStat("annotated_object_count", 13, 0, withKids)%>)</a></li>
                    <li <%=bean.getSpeciesTypeKey() == 14 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('species','Naked Mole-rat','#gviewer')">Naked Mole-rat&nbsp;(<%=tws.getStat("annotated_object_count", 14, 0, withKids)%>
                        )</a></li>
                    <% if (bean.isShowAnnotsForAllSpecies()) {%>
                    <li <%=bean.getSpeciesTypeKey() == 0 ? "id=\"selected\"" : ""%> ><a
                            href="javascript:addParamToLocHref('species','All','#gviewer')">All</a></li>
                    <%}%>

                </ul>
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <div id="searchResultHeader">
                <ul>
                    <% if (tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 1, withKids) > 0) { %>
                    <li <%=bean.getObjectKey() < 2 ? "id=\"selected\"" : ""%> ><a
                            href="javascript:addParamToLocHref('o','1','#gviewer')">Genes
                        (<%=tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 1, withKids)%>)</a></li>
                    <% } %>

                    <% if (tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 6, withKids) > 0) { %>
                    <li <%=bean.getObjectKey() == 6 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('o','6','#gviewer')">QTL
                        (<%=tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 6, withKids)%>)</a></li>
                    <% } %>

                    <% if (tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 5, withKids) > 0) { %>
                    <li <%=bean.getObjectKey() == 5 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('o','5','#gviewer')">Strains
                        (<%=tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 5, withKids)%>)</a></li>
                    <% } %>

                    <% if (tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 7, withKids) > 0) { %>
                    <li <%=bean.getObjectKey() == 7 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('o','7','#gviewer')">Variants
                        (<%=tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 7, withKids)%>)</a></li>
                    <% } %>

                    <% if (tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 11, withKids) > 0) { %>
                    <li <%=bean.getObjectKey() == 11 ? "id=\"selected\"" : ""%>><a
                            href="javascript:addParamToLocHref('o','11','#gviewer')">Cell Lines
                        (<%=tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), 11, withKids)%>)</a></li>
                    <% } %>
                </ul>
            </div>
        </td>
    </tr>

</table>

<%
    //edu.mcw.rgd.datamodel.Map refMap = MapManager.getInstance().getReferenceAssembly(bean.getSpeciesTypeKey());
    //int mapKey = refMap!=null ? refMap.getKey() : 0;

    if (tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), bean.getObjectKey(), withKids) > 2000) { %>

<br><br>
<div style="padding:30px; border: 3px solid #FFCF3E; font-size:20px;">

    Your selection
    has <%=tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), bean.getObjectKey(), withKids)%> annotated
    objects.

    The maximum number of objects that can be shown is 2000.
    The list is too large to display. <br><br>

    <li><a style="font-size:18px;" href="/rgdweb/ontology/view.html?acc_id=<%=bean.getAccId()%>">Select a more specific
        term using the term browser</a>

    <li><a style="font-size:18px;" href="javascript:addParamToLocHref('d','1','#annot')"/>Download the entire list for
        this term</a>


            <% if (bean.isWithChildren()) {%>
    <li><a style="font-size:18px;" href="javascript:addParamToLocHref('with_children','0','#annot')"/>Display
        annotations for this term only (exclude descendants)</a>
            <% } %>

</div>

<br><br>

<%} else if (tws.getStat("annotated_object_count", bean.getSpeciesTypeKey(), bean.getObjectKey(), withKids) < 1) { %>

<div style="padding:30px; border: 3px solid #FFCF3E; font-size:20px;">

    0 Annotations Found<br><br>

    <li><a style="font-size:18px;" href="/rgdweb/ontology/view.html?acc_id=<%=bean.getAccId()%>">Select a less specific
        term using the term browser</a>

</div>


<% } else {%>

<div id="searchResultWrapperTable" style="margin-right:25px;">
    <div id="searchResult">
        <table border='0' cellpadding='2' cellspacing='2' width="100%">
            <% int sectionCount = 0;
                for (Map.Entry<Term, List<OntAnnotation>> entry : bean.getAnnots().entrySet()) {
                    sectionCount++;
                    Term term = entry.getKey();
            %>
            <tr class='srH1' align="left">
                <th colspan="14">
                    <table width="95%" style="background-color:#B0C4DE;">
                        <tr>
                            <td><a style="font-size:16px;"
                                   href="<%=Link.ontAnnot(term.getAccId())%>&species=<%=bean.getSpecies()%>"><%=term.getTerm()%>
                            </a>
                                <a href="<%=Link.ontView(term.getAccId())%>"><img src="/rgdweb/common/images/tree.png"
                                                                                  title="click to browse the term"
                                                                                  alt="term browser" border="0"></a>
                            </td>
                        </tr>

                    </table>
            </tr>
            <tr class='headerRow'>
                <%--                 <colgroup>--%>
                <%--                     <col span="1" style="width: 1%;"> &lt;%&ndash; gene, qtl, ect &ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 6%;"> &lt;%&ndash; Symbol &ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 14%;"> &lt;%&ndash; Obj name &ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 7%;"> &lt;%&ndash; Qualifiers &ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 4%;"> &lt;%&ndash; Evidence &ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 22%;">&lt;%&ndash; notes &ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 5%;">&lt;%&ndash; source &ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 13%;">&lt;%&ndash; original references/ xref / PubMed reference&ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 13%;">&lt;%&ndash; RGD Reference &ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 11%;">&lt;%&ndash; Position &ndash;%&gt;--%>
                <%--                     <col span="1" style="width: 6%;">&lt;%&ndash; Jbrowse link &ndash;%&gt;--%>
                <%--                 </colgroup>--%>
                <% if (bean.getObjectKey() == 6) { %>
                <colgroup>
                    <col span="1" style="width: 1%;"> <%-- gene, qtl, etc --%>
                    <col span="1" style="width: 6%;"> <%-- Symbol --%>
                    <col span="1" style="width: 14%;"> <%-- Obj name --%>
                    <col span="1" style="width: 7%;"> <%-- Qualifiers --%>
                    <col span="1" style="width: 4%;"> <%-- Evidence --%>
                    <col span="1" style="width: 4%;"> <%-- rsID--%>
                    <col span="1" style="width: 5%;"> <%-- P Value --%>
                    <col span="1" style="width: 4%;"> <%-- LOD Value --%>
                    <col span="1" style="width: 10%;"><%-- notes --%>
                    <col span="1" style="width: 5%;"><%-- source --%>
                    <col span="1" style="width: 13%;"><%-- original references/ xref / PubMed reference--%>
                    <col span="1" style="width: 12%;"><%-- RGD Reference --%>
                    <col span="1" style="width: 9%;"><%-- Position --%>
                    <col span="1" style="width: 6%;"><%-- Jbrowse link --%>
                </colgroup>
                <% } else { %>
                <colgroup>
                    <col span="1" style="width: 1%;">
                    <%-- gene, qtl, etc --%>
                    <col span="1" style="width: 6%;">
                    <%-- Symbol --%>
                    <col span="1" style="width: 14%;">
                    <%-- Obj name --%>
                    <col span="1" style="width: 7%;">
                    <%-- Qualifiers --%>
                    <col span="1" style="width: 4%;">
                    <%-- Evidence --%>
                    <col span="1" style="width: 22%;">
                    <%-- notes --%>
                    <col span="1" style="width: 5%;">
                    <%-- source --%>
                    <col span="1" style="width: 13%;">
                    <%-- original references/ xref / PubMed reference--%>
                    <col span="1" style="width: 13%;">
                    <%-- RGD Reference --%>
                    <col span="1" style="width: 11%;">
                    <%-- Position --%>
                    <col span="1" style="width: 6%;">
                    <%-- Jbrowse link --%>
                </colgroup>
                <% } %>
                <td 10%></td>
                <%=bean.getSpeciesTypeKey() == 0 ? "<td></td>" : ""%>
                <td><b>Symbol</b></td>
                <td><b>Object Name</b></td>
                <td><%=bean.getHasQualifiers() ? "<b>Qualifiers</b>" : ""%>
                </td>
                <td><b>Evidence</b></td>
                <% if (bean.getObjectKey() == 6) { %>
                    <td><b>rsID</b></td>
                <td><b>P&nbsp;Value</b></td>
                <td><b>LOD&nbsp;Score</b></td>
                <% } %>
                <td><b>Notes</b></td>
                <td><b>Source</b></td>
                <td><b>PubMed Reference(s)</b></td>
                <td><b>RGD Reference(s)</b></td>
                <td align="right"><b>Position</b></td>
                <td></td>
            </tr>
            <% int row = 0;
                for (OntAnnotation annot : entry.getValue()) {
                    String speciesName = SpeciesType.getCommonName(annot.getSpeciesTypeKey());
                    if (row++ % 2 == 1)
                        out.print("<tr class='oddRow'>");
                    else
                        out.print("<tr class='evenRow'>"); %>

            <td class="objtag_<%=annot.getRgdObjectName()%>"
                title=" <%=annot.getRgdObjectName()%> "><%=annot.getObjectTypeInitial()%>
            </td>
            <%=bean.getSpeciesTypeKey() == 0 ? "<td title=\"" + speciesName + "\">" + speciesName.substring(0, 1) + "</td>" : ""%>

            <% //check to see if symbol should be used by tool submit logic
                String toolSubmitClass = " ";
                if (annot.getRgdObjectName().equals("gene")) {
                    //toolSubmitClass=" class='list" + sectionCount + "' ";
                    toolSubmitClass = " class='list1'";
                }
            %>
            <td><a <%=toolSubmitClass%>
                    href="/rgdweb/report/<%=annot.getRgdObjectName()%>/main.html?id=<%=annot.getRgdId()%>"><%=annot.getSymbol()%>
            </a></td>
            <td><%=annot.getName()%>
            </td>
            <td><%=annot.getQualifier()%>
            </td>
            <td><%=annot.getEvidence()%>
            </td>
            <% if (bean.getObjectKey() == 6) {
                try {
                    QTL qtl = new QTLDAO().getQTL(annot.getRgdId());
            %>
            <td><%=qtl.getPeakRsId() != null ? qtl.getPeakRsId(): ""%>
            <% if ((qtl.getPValue() == null || qtl.getPValue() == 0) && qtl.getpValueMlog()!=null) {
                double w = qtl.getpValueMlog();
                int x = (int) Math.ceil(w);
                double y = x-w;
                int z = (int) Math.round(Math.pow(10,y));
                String convertedPVal = z+"E-"+x;
            %>
            <td><%=convertedPVal%></td>
            <%} else {%>
            <td><%=qtl.getPValue() != null ? qtl.getPValue() : ""%></td>
            <% } %>
            <td><%=qtl.getLod() != null ? qtl.getLod() : ""%>
            </td>
            <%
            } catch (Exception e) {
            %>
            <td></td>
            <td></td>
            <%
                    }
                } %>

            <%--                <td><a href="/rgdweb/report/annotation/<%--%>
            <%--                    if( term.getAccId().startsWith("CHEBI") ) { out.print("table"); } else { out.print("main"); }--%>
            <%--                   %>.html?term=<%=term.getAccId()%>&id=<%=annot.getRgdId()%>" title="view annotation report"><%=annot.getEvidence()%></a></td>--%>

            <td><%=annot.getNotes()%>
            </td>
            <td><% if (annot.getReference().isEmpty())
                out.print(annot.getDataSource());
            else {
                out.print(annot.getReference());
                if (annot.getDataSource().contains("RGD") && !annot.getReference().contains("RGD")) {
                    out.print("<BR>RGD");
                }
            }%></td>

            <td><% if (!annot.getXrefSource().isEmpty() && annot.getHiddenPmId().isEmpty()) {
                String[] pmids = annot.getXrefSource().split("> ");
                if (pmids.length > 5) {
                    String lessPms = "";
                    String morePms = "";
                    int i = 0;
                    for (String pmid : pmids) {
                        if (i > 4) {
                            if (i == pmids.length - 1)
                                morePms += pmid + " ";
                            else
                                morePms += pmid + "> ";
                            //System.out.println(morePms);
                        } else {
                            lessPms += pmid + "> ";
                            //System.out.println(lessPms);
                        }
                        i++;
                    }

            %>
                <%=lessPms%> <span class="more" style="display: none;"><%=morePms%> </span><a href="#" class="moreLink"
                                                                                              title="Click to see more">More...</a>
                <%
                    } else {
                        out.print(annot.getXrefSource());
                    }
                } else if (!annot.getHiddenPmId().isEmpty() && annot.getXrefSource().isEmpty()) {
                    String[] pmids = annot.getHiddenPmId().split("> ");
                    if (pmids.length > 5) {
                        String lessPms = "";
                        String morePms = "";
                        int i = 0;
                        for (String pmid : pmids) {
                            if (i > 4) {
                                if (i == pmids.length - 1)
                                    morePms += pmid + " ";
                                else
                                    morePms += pmid + "> ";
                            } else {
                                lessPms += pmid + "> ";
                            }
                            i++;
                        }
                %>
                <%=lessPms%> <span class="more" style="display: none;"><%=morePms%> </span><a href="#" class="moreLink"
                                                                                              title="Click to see more">More...</a>
                <%
                    } else {

                        out.print(annot.getHiddenPmId());
                    }
                } else if (!annot.getHiddenPmId().isEmpty() && !annot.getXrefSource().isEmpty()) {
                    String[] pmids = annot.getXrefSource().split("</A>");
                    String[] pmids2 = annot.getHiddenPmId().split("</A>");
                    pmids2[0] = " " + pmids2[0];
                    ArrayList<String> pmidsTot = new ArrayList<>(Arrays.asList(pmids));
                    pmidsTot.addAll(Arrays.asList(pmids2));
                    if (pmidsTot.size() > 5) {
                        String lessPms = "";
                        String morePms = "";
                        int i = 0;
                        for (String pmid : pmidsTot) {
                            if (i > 4) {
                                if (i == pmidsTot.size() - 1)
                                    morePms += pmid + "</A>";
                                else
                                    morePms += pmid + "</A>";
                            } else {
                                lessPms += pmid + "</A>";
                            }
                            i++;
                        }
                        //System.out.println(lessPms + "\n" + morePms);

                %>
                <%=lessPms%> <span class="more" style="display: none;"><%=morePms%> </span><a href="#" class="moreLink"
                                                                                              title="Click to see more">More...</a>
                <%
                        } else {
                            out.print(annot.getXrefSource() + " " + annot.getHiddenPmId());
                        }
                    }
                %></td>

            <td><%
                if (annot.getRgdRefSource().isEmpty() && !annot.getReferenceTurnedRGDRef().isEmpty()) // added references exist while rgdRef DNE
                    out.print(annot.getReferenceTurnedRGDRef());
                else if (!annot.getRgdRefSource().isEmpty() && annot.getReferenceTurnedRGDRef().isEmpty()) { // added references DNE while rgdRef exists
                    String newSource = annot.getRgdRefSource().replace("REF_RGD_ID", "RGD");
                    out.print(newSource);
                } else if (!annot.getRgdRefSource().isEmpty() && !annot.getReferenceTurnedRGDRef().isEmpty()) { // both exist
                    String newSource = annot.getRgdRefSource().replace("REF_RGD_ID", "RGD");
                    out.print(newSource + ", " + annot.getReferenceTurnedRGDRef());
                }
            %></td>


            <td align="right">
                <%
                    if (!annot.getChr().trim().isEmpty()) {
                        out.print(annot.getFullNcbiPos());
                        if (annot.getChrEns() != null) {
                %>
                <%=annot.getFullEnsPos()%>
                <% }
                } // end if NCBI is not whitespace
                else if (annot.getChrEns() != null) {
                    out.print(annot.getFullEnsPos().substring(4));
                }%>
            </td>
            <td><% String jbrowseLink = annot.getJBrowseLink();
                if (jbrowseLink != null) {%>
                <a href="<%=jbrowseLink%>"><img alt="JBrowse link" border="0" title="JBrowse link" height="19"
                                                width="30" src="/rgdweb/common/images/jbrowse2.png"/></a>
                <%}%></td>
            </tr>
            <% }
            } %>

            </tr>
        </table>
    </div>
</div>
<% } %>
<% if (bean.isPhenoData()) { %>
<%@ include file="phenoTable.jsp" %>
<% } %>
