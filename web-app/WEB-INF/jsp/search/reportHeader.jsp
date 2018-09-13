<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.Chromosome" %>
<%@ page import="java.util.List" %>

<% if (RgdContext.isChinchilla(request)) {%>
<link href="/rgdweb/common/searchNGC.css" rel="stylesheet" type="text/css" />
<% } else { %>
<link href="/rgdweb/common/search.css" rel="stylesheet" type="text/css" />
<% } %>



<script type="text/javascript">

    function addParam(name, value) {
        var re = new RegExp(name + "=[^\&]*");

        if (re.exec(location.href) != null) {
            location.href = location.href.replace(re, name + "=" + value)
        } else {
            location.href = location.href + "&" + name + "=" + value;
        }
    }
</script>

<%    
    FormUtility fu = new FormUtility();
    SearchBean search = (SearchBean) request.getAttribute("searchBean");

    String term = search.getTerm().replaceAll("\"", "&quot;");

    String ratId = "";
    String mouseId = "";
    String humanId = "";
    String chinchillaId = "";
    String bonoboId = "";
    String dogId = "";
    String squirrelId = "";
    String allId = "";

    if (search.getSpeciesType() == 0) {
        allId = "id=selected";
    } else if (search.getSpeciesType() == 1) {
        humanId = "id=selected";
    } else if (search.getSpeciesType() == 2) {
        mouseId = "id=selected";
    } else if (search.getSpeciesType() == 3) {
        ratId = "id=selected";
    } else if (search.getSpeciesType() == 4) {
        chinchillaId = "id=selected";
    } else if (search.getSpeciesType() == 5) {
        bonoboId = "id=selected";
    } else if (search.getSpeciesType() == 6) {
        dogId = "id=selected";
    } else if (search.getSpeciesType() == 7) {
        squirrelId = "id=selected";
    }

    Report report = (Report) request.getAttribute("report");
    String selected = "";

    if (search.getSort() == -1) {
        selected = "selected";
    }

    int total = report.records.size() - 1;

    String displayText = "";
    if (total == 1000) {
        displayText = "<b>More than 1000</b> records found for search term <b>" + term + "</b> (Displaying 1000)" +
                "<br><span style=\"color:blue;\">For a more accurate result, please refine your search term.</span><br><br>";
    }else {
        displayText = "<b>" + (report.records.size() - 1) + "</b> records found ";
        if( !Utils.isStringEmpty(term) )
            displayText += "for search term <b>" + term + "</b>";

        if( !Utils.isStringEmpty(search.getTermAccId1()) ) {
            Term oterm1 = new OntologyXDAO().getTermByAccId(search.getTermAccId1());
            displayText += ", in strain <a href=\""+ Link.ontView(oterm1.getAccId())+"\" class=\"search_res_ont_link\">"+oterm1.getTerm()+"</a>";
        }
        if( !Utils.isStringEmpty(search.getTermAccId2()) ) {
            Term oterm2 = new OntologyXDAO().getTermByAccId(search.getTermAccId2());
            displayText += ", for trait <a href=\""+ Link.ontView(oterm2.getAccId())+"\" class=\"search_res_ont_link\">"+oterm2.getTerm()+"</a>";
        }
    }
%>

<table  width="96%" border="0"><tr>
    <td id="searchResultSummary">
<b><%=title%></b> search result for <i><b><%=SpeciesType.getTaxonomicName(search.getSpeciesType())%></b></i> <a style="font-size:12px;" href="/rgdweb/search/search.html?term=<%=term%>"/><br>(View Results for all Objects and Ontologies)</a><br><br>
        <%=displayText%>
    </td>
    <td align="right">
<table id="searchResultUpdateBox" cellspacing=5   border="0">
<tr>
    <td>Refine Term:</td>
    <td colspan=2>
        <table  cellpadding=0 cellspacing=0>
            <form method="post" action='#' onSubmit="return false;">
                <tr>
                    <td class="atitle" align="right">
                        <input type=text name=keyword
                               size=35
                               value="<%=term%>" class="">

                    </td>
                    <td>
                        <input type="submit" value="Update"
                               onClick="javascript:addParam('term',this.form.keyword.value)" class=""/>
                    </td>
                </tr>
            </form>
        </table>
    </td>
</tr>


<% if (search.getSpeciesType() > 0 && includeMapping) { %>
<tr>
        <td>Assembly:</td>
        <td>
            <table cellpadding=0 cellspacing=0><tr><td>

                <select name="sort" onChange='addParam("map",this.options[this.selectedIndex].value)'>

                <%
                    for (Object o : MapManager.getInstance().getAllMaps(search.getSpeciesType())) {
                        Map m = (Map) o;
                %>
                    <option <%=fu.optionParams(search.getMap(), m.getKey())%> ><%=m.getName()%></option>
                <% } %>
                </select>

                </td><td>

            &nbsp;&nbsp;&nbsp;&nbsp;Chr&nbsp;&nbsp;</td><td><select name="chr" onChange='addParam("chr",this.options[this.selectedIndex].value)'>

            <option <%=fu.optionParams(search.getChr(),"ALL")%> >All</option>



            <%
                List<Chromosome> chromosomes = MapManager.getInstance().getChromosomes(MapManager.getInstance().getReferenceAssembly(search.getSpeciesType()).getKey());
                for (Chromosome ch: chromosomes) {
                //for (int i = 1; i < 23; i++) { %>
                    <option <%=fu.optionParams(search.getChr(),ch.getChromosome() + "")%> ><%=ch.getChromosome()%></option>
            <%  } %>

            </select>
            </td></tr></table>
    </td>
</tr>
<% } %>

<tr>
    <td>Sort By:</td>
   <td>          
            <select name="sort" onChange='addParam("sort",this.options[this.selectedIndex].value)'>

            <% Record rec = (Record) report.records.get(0);

                Iterator it = rec.iterator();
                int fieldCount = 0;
                while (it.hasNext()) {
                    selected = "";
                    if (search.getSort() == fieldCount) {
                        selected = "selected";
                    }

            %>
            <option value='<%=fieldCount%>' <%=selected%>><%=(String) it.next()%></option>

            <%
                    fieldCount++;
                }
            %>


        </select>
        <%
            String descending = "";
            if (search.getOrder() == 1) {
                descending = "selected";
            }

        %>


        <select name="order" onChange='addParam("order",this.options[this.selectedIndex].value)'>
            <option value="0" >Ascending</option>
            <option value="1" <%=descending%>>Descending</option>

        </select>

    </td>


</tr>


</table>
</td></tr></table>

<div id="searchResultHeader">

    <ul>
        <% if (!title.equals("References")) { %>
            <% if (!RgdContext.isChinchilla(request) ) { %>
            <li <%=ratId%>><a href="javascript:addParam('speciesType',3)">Rat</a></li>
            <!-- these comments between li's solve a problem in IE that prevents spaces appearing between list items that appear on different lines in the source
            -->
            <% } %>
        <% if (!title.equals("Strains")) { %>
            <% if (!RgdContext.isChinchilla(request) ) { %>
            <li <%=mouseId%>><a href="javascript:addParam('speciesType',2)">Mouse</a></li>
            <!--
            -->
            <% } %>
            <li <%=humanId%>><a href="javascript:addParam('speciesType',1)">Human</a></li>
            <!--
            -->
        <% } %>

        <% } %>

        <% if (title.equals("Genes")  ) { %>
        <li <%=chinchillaId%>><a href="javascript:addParam('speciesType',4)">Chinchilla</a></li>
        <li <%=bonoboId%>><a href="javascript:addParam('speciesType',5)">Bonobo</a></li>
        <li <%=dogId%>><a href="javascript:addParam('speciesType',6)">Dog</a></li>
        <li <%=squirrelId%>><a href="javascript:addParam('speciesType',7)">Squirrel</a></li>
        <!--
        -->
        <% } %>

        <% if (!title.equals("Strains")) { %>
        <li <%=allId%>><a href="javascript:addParam('speciesType',0)">All</a></li>
        <% } %>

    </ul>

</div>


<div id="searchResultExportList">
    <table cellpadding=0 cellspacing=0 border="0" >
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td  valign="center"><span   style="padding-right:10px;" >Export </span></td>
            <td><a href="javascript:addParam('fmt',2)"  style="padding-right:10px;" >CSV</a></td>
            <td><a href="javascript:addParam('fmt',3)"  style="padding-right:10px;" >TAB</a></td>
            <td><a href="javascript:addParam('fmt',4)"  style="padding-right:10px;" >Print</a></td>

            <% if (search.getSpeciesType()>0 && search.getSpeciesType()<=3 && (title.equals("Genes") || title.equals("QTLs") || title.equals("Markers"))) { %>
                   <td><a href="javascript:addParam('fmt',5)"  style="padding-right:10px;" >GViewer</a></td>
            <% } %>

            <% if (search.getSpeciesType() > 0 && title.equals("Genes")) {
            %>
                    <td valign="bottom"><img src="/rgdweb/common/images/tools-white-20.png" style=" cursor:hand; border: 1px solid black;" border="0" ng-click="rgd.showTools('geneList',<%=search.getSpeciesType()%>,<%=MapManager.getInstance().getReferenceAssembly(search.getSpeciesType()).getKey()%>,1)"/></td>
                    <td><a href="javascript:void(0)"   style="padding-left:3px;" ng-click="rgd.showTools('geneList',<%=search.getSpeciesType()%>,<%=MapManager.getInstance().getReferenceAssembly(search.getSpeciesType()).getKey()%>,1)">Analysis Tools</a></td>

            <% } %>


    </tr>
</table>
</div>
<%
String userAgent = Utils.defaultString(request.getHeader("user-agent")); // ensure userAgent is non-null

if (!userAgent.contains("MSIE")) {
%>
    <br>
<% } %>
<table id="searchResultWrapperTable" width="98%" border=0 cellpading=0 cellspacing=0><tr><td>
<div id="searchResult">
