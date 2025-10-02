 <%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 5, 2008
  Time: 9:18:22 AM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "QTL (quantitative trait loci) Search - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "QTL reports provide phenotype and disease descriptions, mapping, and strain information as well as links to markers and candidate genes.";
    
%>

<%@ include file="/common/headerarea.jsp"%>

 <script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

 <script type="text/javascript">
    function addParam(name, value) {
        var re = new RegExp(name + "=[^\&]*");
        if( re.exec(location.href) != null ) {
            location.href = location.href.replace(re, name + "=" + value);
        }
        else {
            if( location.href.indexOf("?")>=0 )
                location.href = location.href + "&" + name + "=" + value;
            else
                location.href = location.href + "?" + name + "=" + value;
        }
    }
</script>

<div class="searchBox">
<h2>QTL Search</h2>
QTL reports provide phenotype and disease descriptions, mapping, and strain information as well as links to markers and candidate genes. <a href="/wg/searchHelp">(Search Help)</a><br>

<% String title="QTLs"; %>


<form name="adSearch" action="qtls.html">
    <div class="searchExamples">
        <b>Example searches:</b>
        <a href="javascript:document.adSearch.term.value='Mcs';document.adSearch.submit();" >Mcs</a>,
        <a href="javascript:document.adSearch.term.value='&quot;blood pressure&quot;';document.adSearch.submit();" >&quot;blood pressure&quot;</a>,
        <a href="javascript:document.adSearch.term.value='renal function';document.adSearch.submit();" >renal function</a>,
        <a href="javascript:document.adSearch.term.value='blood -pressure';document.adSearch.submit();" >blood -pressure</a>,
        <a href="javascript:document.adSearch.term.value='Johnson';document.adSearch.submit();" >Johnson</a>
    </div>
    <br>
<%
    int selSpecies = RgdContext.isChinchilla(request) ? SpeciesType.CHINCHILLA : SpeciesType.RAT;
    String speciesTypeParam = request.getParameter("speciesType");
    if( speciesTypeParam!=null && SpeciesType.isValidSpeciesTypeKey(Integer.parseInt(speciesTypeParam)) ) {
        selSpecies = Integer.parseInt(speciesTypeParam);
    }
%>
<table border=1 cellspacing=0 cellpadding=10 style="background-color:white;">
    <tr><td>
    <table border='0' >

<tr>
    <td colspan=3><div class="searchHeader">Select at least one field</div></td>
</tr>
<tr>
    <td colspan=3>&nbsp;</td>
</tr>
<tr>
    <td colspan="6" ><b>Keyword</b>
        <select id="match_type" name="match_type">
            <option value="equals">Equals</option>
            <option value="contains" selected>Contains</option>
            <option value="begins">Begins with</option>
            <option value="ends">Ends with</option>
        </select>
        <input name="term" type="text" value="" size="50"/><input type="submit" value="Search <%=title%>" />&nbsp;&nbsp;&nbsp;</td>
</tr>
<tr>
    <td>
        <%
            FormUtility fu = new FormUtility();
            SearchBean search = (edu.mcw.rgd.process.search.SearchBean) request.getAttribute("searchBean");
            if (search == null) {
                search = new SearchBean();
            }
        %>
        <b>Chr</b>&nbsp;&nbsp;</td><td colspan='5'>

    <table>
        <tr><td>


    <select name="chr">

        <option <%=fu.optionParams(search.getChr(),"ALL")%> >All</option>
        <% for (int i = 1; i < 23; i++) { %>
            <option <%=fu.optionParams(search.getChr(),i + "")%> ><%=i%></option>
        <% } %>
        <option <%=fu.optionParams(search.getChr(),"X")%> >X</option>
        <option <%=fu.optionParams(search.getChr(),"Y")%> >Y</option>

        </select>
    </td>
    <td>&nbsp;</td><td><b>Start</b></td><td><input name="start" type="text" value=""/>(bp)</td>
    <td>&nbsp;</td><td><b>Stop</b></td><td><input name="stop" type="text" value=""/>(bp)</td>
    </tr></table></td>
</tr>
<tr>
    <td ><b>Assembly</b></td>
    <td >

        <select name="map" onChange='addParam("map",this.options[this.selectedIndex].value)'>

        <%
            String selected = "";
            String mapKey = request.getParameter("map");
            if (mapKey == null && selSpecies>0 ) {
                mapKey = MapManager.getInstance().getReferenceAssembly(selSpecies).getKey() + "";
            }

            List<Map> allMaps = Collections.emptyList();
            if( selSpecies>0 )
                allMaps = MapManager.getInstance().getAllMaps(selSpecies, "bp");
            for( Map m: allMaps ) {
                selected = "";
                if( mapKey!=null && mapKey.equals(m.getKey() + "")) {
                    selected = "selected";
                }
        %>
        <option value='<%=m.getKey()%>' <%=selected%>><%=m.getName()%></option>
        <%
            }
        %>
    </select>
</td>
</tr>

<tr>
    <td><b>Strains:</b></td>
    <td colspan="2">
        <input type="text" id = "rs_term" name="rs_term" size="40" >
        <input type="button" id="rs_popup" value="Browse ontology">
    </td>
</tr>
<tr>
    <td><b>Traits:</b></td>
    <td colspan="2">
        <input type="text" id = "vt_term" name="vt_term" size="40" >
        <input type="button" id="vt_popup" value="Browse ontology">
    </td>
</tr>

<script>
$(document).ready(function(){

    // handle to popup windows
    var rs_popup_wnd = null;
    var vt_popup_wnd = null;

    $("#rs_popup").click(function(){
        if( rs_popup_wnd!=null ) {
            if( !rs_popup_wnd.closed ) {
                rs_popup_wnd.focus();
                return;
            }
        }
        rs_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=RS&sel_term=rs_term&term="
               +document.getElementById("rs_term").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
    });

    $("#vt_popup").click(function(){
        if( vt_popup_wnd!=null ) {
            if( !vt_popup_wnd.closed ) {
                vt_popup_wnd.focus();
                return;
            }
        }
        vt_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=VT&sel_term=vt_term&term="
                +document.getElementById("vt_term").value,
                '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
    });


    $("input[name='rs_term']").autocomplete('/solr/OntoSolr/select', {
      extraParams:{
          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
          'bf': 'term_len_l^.02',

          'fq': 'cat:(RS)',
          'wt': 'velocity',
          'v.template': 'termidselect1'
      },
      max: 100,
      'termSeparator': ' OR '
    }
    );

    //$("input[name='rs_term']")
    //        .result(function(data, value){
    //    $("#rs_acc_id").val(value[1]);
    //});

    $("input[name='vt_term']").autocomplete('/solr/OntoSolr/select', {
      extraParams:{
          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
          'bf': 'term_len_l^.02',

          'fq': 'cat:(VT)',
          'wt': 'velocity',
          'v.template': 'termidselect1'
      },
      max: 100,
      'termSeparator': ' OR '
    }
    );

    //$("input[name='vt_term']")
    //        .result(function(data, value){
    //            $("#vt_acc_id").val(value[1]);
    //});
});
</script>

<tr>
    <td width="10%"><b>Species:</b></td>
    <td colspan=2>
        <select name="speciesType" onChange='addParam("speciesType",this.value)'>
            <% for( int speciesTypeKey: SpeciesType.getSpeciesTypeKeys()) { %>
                <% if (speciesTypeKey==1 || speciesTypeKey==2 || speciesTypeKey==3) { %>
                    <option value="<%=speciesTypeKey%>" <%=selSpecies==speciesTypeKey?"selected":""%>><%=SpeciesType.getCommonName(speciesTypeKey)%></option>
                <% } %>
            <% } %>
        </select>
    </td>
</tr>

<tr>
    <td colspan="4" align="right"><input type="submit" value="Search <%=title%>" /></td>
</tr>
</table>
</td></tr>
</table>

    <input type="hidden" name="obj" value="qtl" />

</form>

<a href="/objectSearch/qtlSubmit.jsp?species=Rat&go=Submit">Switch to classic QTL search</a><br>
<a href="/wg/searchHelp">View all search features</a>    
</div>
<%@ include file="/common/footerarea.jsp"%>
