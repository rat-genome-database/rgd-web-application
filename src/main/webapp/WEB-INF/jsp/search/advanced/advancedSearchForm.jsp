<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="edu.mcw.rgd.datamodel.Chromosome" %>

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
    System.out.println(speciesTypeParam);
    if( speciesTypeParam!=null && SpeciesType.isValidSpeciesTypeKey(Integer.parseInt(speciesTypeParam)) ) {
        selSpecies = Integer.parseInt(speciesTypeParam);
    }
    String assemblyParam = request.getParameter("assembly");
    String selectedAssembly=new String();
    if( assemblyParam!=null ) {
        selectedAssembly = assemblyParam;
    }else selectedAssembly="All";
%>
<table border="1" cellspacing=0 cellpadding=10 style="background-color:white;">
<%--    <%if(title.equals("Variants")){%>--%>
    <tr><td>
        <table border='0' >

            <tr>
                <td colspan="6" ><b style="font-size: 15px">Keyword</b> <input name="term" id="objectSearchTerm" type="text" value="" size="85" style="font-size: 15px;height: 28px;"/>&nbsp;&nbsp;</td>
            </tr>
            <tr><td colspan=3>&nbsp;</td></tr>
            <% if (!(title.equals("Strains") || title.equals("References"))) { %>
            <tr>
                        <%
                        int species = 3;

                        try {
                            species = Integer.parseInt(request.getParameter("species"));
                        }catch (Exception ignored) {

                        }

                    %>
                <td><b>Species:</b>
                    <select name="speciesType" onChange='addParam("species",this.value)'>
                        <%--            <select name="species")>--%>
                        <% if (request.getServletPath().endsWith("markers.jsp")) { %>
                        <% for( int speciesTypeKey: new int[]{1,2,3} ) {
                            if(speciesTypeKey==selSpecies){%>
                        <option selected value="<%=speciesTypeKey%>"><%=SpeciesType.getCommonName(speciesTypeKey)%></option>
                        <%}else{%>  <option><%=SpeciesType.getCommonName(speciesTypeKey)%></option>
                        <% }}
                        } else {
                            for( int speciesTypeKey: SpeciesType.getSpeciesTypeKeys()) {
                                if( !SpeciesType.isSearchable(speciesTypeKey) ) { continue; } // skip non-searchable species
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
                    <select  id="assembly" name="assembly" onChange='addParam("assembly",this.value)'>
                        <option <%=fu.optionParams(selectedAssembly,"all")%>>All</option>

                        <%
                            List<Map> maps = MapManager.getInstance().getAllMaps(search.getSpeciesType());
                            for (Map map: maps) {%>
                        <option  <%=fu.optionParams(selectedAssembly,String.valueOf( map.getDescription()))%>><%=map.getName()%></option>
                        <%}%>
                    </select>
                </td>
            </tr>
            <tr><td colspan=3>&nbsp;</td></tr>
<%--            <tr><td style="border: 1px solid black;">--%>
            <tr>
                <td colspan="6">
                    <table cellspacing="0" cellpadding="10" border="1" style="border-collapse: collapse;max-width: 60vw;">
            <tr><td colspan=3 style="border-bottom: 0;border-collapse: collapse;padding-bottom: 0"><div class="searchHeader">Limit Results (optional)</div></td></tr>
            <tr>
                <td colspan='5' style="border-top: 0;border-collapse: collapse;padding-top: 3px">
                    <table>
                        <tr>
                            <td><b>Chr</b>&nbsp;</td>
                            <td>
                            <select name="chr">
                                <option <%=fu.optionParams(search.getChr(),"ALL")%> >All</option>
                                <%
                                    List<Chromosome> chromosomes = MapManager.getInstance().getChromosomes(MapManager.getInstance().getReferenceAssembly(search.getSpeciesType()).getKey());
                                    for (Chromosome ch: chromosomes) {
                                        //for (int i = 1; i < 23; i++) { %>
                                <option <%=fu.optionParams(search.getChr(),ch.getChromosome() + "")%> ><%=ch.getChromosome()%></option>
                                <%  } %>
                            </select>
                        </td>
                            <td>&nbsp;</td><td><b>Start</b></td><td><input name="start" type="text" size="30" value=""/>(bp)</td>
                            <td>&nbsp;</td><td><b>Stop</b></td><td><input name="stop" type="text" size="30" value=""/>(bp)</td>
                        </tr>
                    </table>
                </td>
            </tr>
            <% } %>

                    </table>
               </td>
            </tr>
            <tr><td colspan=3>&nbsp;</td></tr>
            <% } %>
            <tr>
                <td colspan="4" align="center"><input style="font-size: 9pt" type="submit" value="Search <%=title%>" /></td>
            </tr>
        </table>
    </td></tr>
<%--    <% } %>--%>
</table>


