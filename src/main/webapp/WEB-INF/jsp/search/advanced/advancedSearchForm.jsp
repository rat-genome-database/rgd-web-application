<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="edu.mcw.rgd.datamodel.Chromosome" %>
<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>

<script type="text/javascript">

    function addParam(name, value) {
        console.log(name);
        console.log(value);
        // if(name==='species'&&value==='All'){
        //     value='';
        // }
        var re = new RegExp(name + "=[^\&]*");
        if( re.exec(location.href) != null ) {
            location.href = location.href.replace(re, name + "=" + value);
        }
        else {
            if( location.href.indexOf("?")>=0 ) {
                    location.href = location.href + "&" + name + "=" + value;
            }
            else {
                location.href = location.href + "?" + name + "=" + value;
            }
        }
    }

    // example searches: <button class="rsm-chip" data-term="..."> anywhere on the page runs that
    // keyword on its own, without a chromosome limit (not every search has a chromosome list)
    document.addEventListener('click', function (e) {
        var chip = e.target.closest ? e.target.closest('.rsm-chip[data-term]') : null;
        if (!chip) {
            return;
        }
        var form = document.adSearch;
        form.term.value = chip.getAttribute('data-term');
        if (form.chr) {
            form.chr.value = '0';
        }
        form.submit();
    });
</script>
<style>
    td b{
        font-size: 15px;
    }
    select,input{
        font-size: 15px;
        height: 24px;
    }

    .searchExamples b{
        font-size: 12px;
    }
</style>
<%
    int selSpecies = RgdContext.isChinchilla(request) ? SpeciesType.CHINCHILLA : SpeciesType.RAT;
//    String speciesTypeParam = request.getParameter("speciesType");
    String speciesTypeParam = request.getParameter("species");

//    if(speciesTypeParam != null&&speciesTypeParam.equals("All")){
//        selSpecies=0;
//    }
    System.out.println(speciesTypeParam);
        if (speciesTypeParam != null && SpeciesType.isValidSpeciesTypeKey(Integer.parseInt(speciesTypeParam))) {
                selSpecies = Integer.parseInt(speciesTypeParam);
        }
//        System.out.println(selSpecies);
    Map mapDefault=null;
        try {
            mapDefault = new MapDAO().getPrimaryRefAssembly(selSpecies);
        }
        catch(Exception ignore){

        }

//    System.out.println(mapDefault.getDescription());
//    System.out.println(mapDefault.getName());

    //adding pipeline check to make equals default in gene search as per RGDD-2763
    boolean isPipelines = RgdContext.getHostname().equals("https://pipelines.rgd.mcw.edu");
    String assemblyParam = request.getParameter("assembly");
    String selectedAssembly=new String();
    if( assemblyParam!=null ) {
        selectedAssembly = assemblyParam;
    }else selectedAssembly="All";

    // For variant search, get map_keys that have variant data to filter species and assemblies
    boolean isVariantSearch = title != null && title.equals("Variants");
    Set<Integer> variantMapKeys = new HashSet<>();
    Set<Integer> variantSpeciesKeys = new HashSet<>();
    if (isVariantSearch) {
        try {
            List<Integer> mapKeys = new SampleDAO().getVariantMapKeys();
            variantMapKeys.addAll(mapKeys);
            // Determine which species have variant data by checking their assemblies
            for (int spKey : SpeciesType.getSpeciesTypeKeys()) {
                if (spKey == 0) continue;
                List<Map> spMaps = MapManager.getInstance().getAllMaps(spKey);
                if (spMaps == null) continue;
                for (Map m : spMaps) {
                    if (variantMapKeys.contains(m.getKey())) {
                        variantSpeciesKeys.add(spKey);
                        break;
                    }
                }
            }
        } catch (Exception e) {
            // If query fails, don't filter — show all species
            e.printStackTrace();
            isVariantSearch = false;
        }
    }
%>
<%-- the asf-* classes are layout hooks for /rgdweb/css/searchForm.css, which only applies on pages
     that wrap this form in class "rsm"; everywhere else they have no effect --%>
<table class="asf-card" border="1" cellspacing=0 cellpadding=10 style="background-color:white;">
<%--    <%if(title.equals("Variants")){%>--%>
    <tr><td>
        <table border='0' >

            <tr class="asf-row">

                <td class="asf-keyword" colspan="6" ><b style="font-size: 15px">Keyword:</b>
                    <%if(pageTitle.toLowerCase().contains("gene") || pageTitle.toLowerCase().contains("qtl")){%>
                    <select id="match_type" name="match_type">
                    <option value="equals" <%=isPipelines?"selected":""%>>Equals</option>
                    <option value="contains" <%=isPipelines?"":"selected"%>>Contains</option>
                    <option value="begins">Begins with</option>
                    <option value="ends">Ends with</option>
                </select>
                <%}%>
                    <input name="term" id="objectSearchTerm" type="text" value="" size="85" style="font-size: 15px;height: 28px;" aria-label="Keyword"/></td>
            </tr>
            <tr class="asf-spacer"><td colspan=3>&nbsp;</td></tr>
            <% if (!(title.equals("Strains") || title.equals("References"))) { %>
            <tr class="asf-row asf-scope-row">
                        <%
                        int species = 3;

                        try {
                            species = Integer.parseInt(request.getParameter("species"));
                        }catch (Exception ignored) {

                        }

                    %>
                <td><b>Species:</b>
                    <select name="speciesType" aria-label="Species" onChange='addParam("species",this.value)'>
<%--                        <% if (!request.getServletPath().endsWith("qtls.jsp")) { %>--%>
                        <option value="0" disabled hidden>All</option>
<%--                        <% } %>--%>
                        <%--            <select name="species")>--%>
                        <% if (request.getServletPath().endsWith("markers.jsp") || request.getServletPath().endsWith("qtls.jsp")) { %>
                        <% for( int speciesTypeKey: new int[]{1,2,3} ) {
                            if(speciesTypeKey==selSpecies){%>
                        <option selected value="<%=speciesTypeKey%>"><%=SpeciesType.getCommonName(speciesTypeKey)%></option>
                        <%}else{%>  <option value="<%=speciesTypeKey%>"><%=SpeciesType.getCommonName(speciesTypeKey)%></option>
                        <% }}
                        } else {
                            for( int speciesTypeKey: SpeciesType.getSpeciesTypeKeys()) {
                                if( !SpeciesType.isSearchable(speciesTypeKey) ) { continue; } // skip non-searchable species
                                if( isVariantSearch && !variantSpeciesKeys.contains(speciesTypeKey) ) { continue; } // skip species without variant data
                                if(speciesTypeKey==selSpecies){%>
                        <option selected value="<%=speciesTypeKey%>"><%=SpeciesType.getCommonName(speciesTypeKey)%></option>
                        <%}else if(speciesTypeKey==0){%>

                        <%}else{%>
                        <option value="<%=speciesTypeKey%>"><%=SpeciesType.getCommonName(speciesTypeKey)%></option>
                        <% }}
                        } %>
                    </select>
                </td>
                <% if (includeMapping) {
                    FormUtility fu = new FormUtility();
                    SearchBean search = (edu.mcw.rgd.process.search.SearchBean) request.getAttribute("searchBean");
                    if (search == null) {
                        search = new SearchBean();
                    }

                %>
                <td style="padding-right: 100px"><b>Assembly&nbsp;</b>
                    <select  id="assembly" name="assembly" aria-label="Assembly" onChange='addParam("assembly",this.value)'>
                        <%if(mapDefault!=null && (!isVariantSearch || variantMapKeys.contains(mapDefault.getKey()))){%>
                        <option  <%=fu.optionParams(selectedAssembly,String.valueOf( mapDefault.getDescription()))%>><%=mapDefault.getName()%></option>
                        <%}%>
                        <option <%=fu.optionParams(selectedAssembly,"all")%>>All</option>
                        <%
                        List<Map> maps = MapManager.getInstance().getAllMaps(selSpecies);
                        if (maps == null) maps = Collections.emptyList();
                        for (Map map: maps) {
                            if (isVariantSearch && !variantMapKeys.contains(map.getKey())) { continue; }%>
                        <option  <%=fu.optionParams(selectedAssembly,String.valueOf( map.getDescription()))%>><%=map.getName()%></option>
                        <%}%>
                    </select>
                </td>
            </tr>
            <tr class="asf-spacer"><td colspan=3>&nbsp;</td></tr>
<%--            <tr><td style="border: 1px solid black;">--%>
            <tr class="asf-row">
                <td colspan="6">
                    <table class="asf-limit" cellspacing="0" cellpadding="10" border="1" style="border-collapse: collapse;max-width: 60vw;">
            <tr><td colspan=3 style="border-bottom: 0;border-collapse: collapse;padding-bottom: 0"><div class="searchHeader">Limit Results (optional)</div></td></tr>
            <tr>
                <td colspan='5' style="border-top: 0;border-collapse: collapse;padding-top: 3px">
                    <table class="asf-position">
                        <tr>
                            <td class="asf-pos-chr-label"><b>Chr</b>&nbsp;</td>
                            <td class="asf-pos-chr">
                            <select name="chr" aria-label="Chromosome">
                                <option <%=fu.optionParams(search.getChr(),"ALL")%> >All</option>
                                <%
                                    List<Chromosome> chromosomes = MapManager.getInstance().getChromosomes(MapManager.getInstance().getReferenceAssembly(search.getSpeciesType()).getKey());
                                    for (Chromosome ch: chromosomes) {
                                        //for (int i = 1; i < 23; i++) { %>
                                <option <%=fu.optionParams(search.getChr(),ch.getChromosome() + "")%> ><%=ch.getChromosome()%></option>
                                <%  } %>
                            </select>
                        </td>
                            <td class="asf-pos-gap">&nbsp;</td><td class="asf-pos-start-label"><b>Start</b></td><td class="asf-pos-start"><input name="start" type="text" size="30" value="" aria-label="Start position (bp)"/>(bp)</td>
                            <td class="asf-pos-gap">&nbsp;</td><td class="asf-pos-stop-label"><b>Stop</b></td><td class="asf-pos-stop"><input name="stop" type="text" size="30" value="" aria-label="Stop position (bp)"/>(bp)</td>
                        </tr>
                    </table>
                </td>
            </tr>
            <% } %>

                    </table>
               </td>
            </tr>
            <tr class="asf-spacer"><td colspan=3>&nbsp;</td></tr>
            <% }%>
<%--                <%if (title.equals("Gene")){%>--%>
<%--            <%@include file="advancedOptions.jsp"%>--%>
<%--            <%}%>--%>
            <tr class="asf-row asf-submit-row">

                <td colspan="4" align="center">
<%--                    <input type="reset" name="reset" value="Reset">&nbsp;--%>
                    <input  type="submit" value="Search <%=title%>" /></td>
            </tr>
        </table>
    </td></tr>
<%--    <% } %>--%>
</table>


