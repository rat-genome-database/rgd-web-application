<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>

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

<%
    int selSpecies = RgdContext.isChinchilla(request) ? SpeciesType.CHINCHILLA : SpeciesType.RAT;
    String speciesTypeParam = request.getParameter("speciesType");
    if( speciesTypeParam!=null && SpeciesType.isValidSpeciesTypeKey(Integer.parseInt(speciesTypeParam)) ) {
        selSpecies = Integer.parseInt(speciesTypeParam);
    }
%>

<style>
    .searchLabel {
        font-weight:700;
        font-size:14px;
        padding:10px;
    }
</style>

<table align="center" border=0 cellspacing=0 cellpadding=10 style="background-color:white;" border="0">
    <tr><td>
    <table border='0' >

        <tr>
            <td width="10%"><span class="searchLabel" >Species:</span></td>
            <td colspan=2>
                <select style="font-size:16px;" name="species")>
                    <% for( int speciesTypeKey: SpeciesType.getSpeciesTypeKeys()) {
                          if( !SpeciesType.isSearchable(speciesTypeKey) ) { continue; } // skip non-searchable species
                        %>
                        <option><%=SpeciesType.getCommonName(speciesTypeKey)%></option>
                    <% }%>
                </select>
            </td>
        </tr>

        <tr>
            <td  ><span class="searchLabel">Search&nbsp;by&nbsp;Keyword</span></td>
            <td><input name="term" id="objectSearchTerm" type="text" value="" style="font-size:20px;" size="40"/></td>
            <td><input type="submit" value="Search <%=title%>" style="font-size:20px;" />&nbsp;&nbsp;&nbsp;</td>
        </tr>
        <tr><td colspan=3>&nbsp;</td></tr>
        <% if (!(title.equals("Strains") || title.equals("References"))) { %>

        <% if (includeMapping) {
            FormUtility fu = new FormUtility();
            SearchBean search = (edu.mcw.rgd.process.search.SearchBean) request.getAttribute("searchBean");
            if (search == null) {
                search = new SearchBean();
            }

        %>
        <input type="hidden" name="chr" value="All"/>

    </td>
    </tr>
<% } %>

<% } %>
</table>
</td></tr>
</table>

