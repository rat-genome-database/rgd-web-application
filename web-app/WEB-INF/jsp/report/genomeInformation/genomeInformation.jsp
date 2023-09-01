<%@ page import="java.util.List" %>
<%@ include file="genomeInfoHeader.jsp"%>
<%
    List<String> assemblyList = (List<String>) request.getAttribute("assemblyList");
    List<String> speciesList = (List<String>) request.getAttribute("speciesList");
    String species = (String) request.getAttribute("species");
    Integer mapKey = (Integer) request.getAttribute("mapKey");
    String assembly = (String) request.getAttribute("assembly");
%>
        <div  style="margin-left:60%">
            <input type="hidden" id="mapKey" value="<%=mapKey%>"/>

            <form id="speciesForm" action="genomeInformation.html?action=change&details=true">
            <div style="width:20%;float:left">
                <label>Species:
                    <select id="species" name="species">
                        <option selected><%=species%></option>
                        <%for (String item : speciesList) {
                        if (!species.equals(item) && !item.equals("All")) {%>
                        <option><%=item%></option>
                        <% }
                        } %>
                    </select>
                </label>
            </div>
            </form>
            <form id="assemblyForm" action="genomeInformation.html?species=<%=species%>&action=change&details=true">
                <input type="hidden"  name="species" value="<%=species%>"/>
            <div style="width:30%;margin-left:21%;">
                <label>Assembly:
                    <select id="assembly" name="assembly">
                        <%for (String item : assemblyList) {
                        if (assembly.equals(item)){%>
                        <option selected><%=item%></option>
                        <%}
                        else {%>
                        <option><%=item%></option>
                        <% } } %>
                    </select>
                </label>
            </div>
            </form>
        </div>
   <%@ include file="Info.jsp"%>
 <%@ include file="genomeInfoFooter.jsp"%>

<script>
    $(document).ready(function() {

        var mapKey= $('#mapKey').val();
        var species=$('#species').val();
        var $jbrowse= document.getElementById('jbrowseMini');
        var URL="https://rgd.mcw.edu/jbrowse?tracks=ARGD_curated_genes&highlight=&tracklist=0&nav=0&overview=0&data=";
        if($jbrowse!=null && typeof $jbrowse != 'undefined') {
            if (species == 'Chinchilla') {
                if (mapKey == 44)
                    $jbrowse.src = URL + "data_cl1_0&loc=";
            }

            if (species == 'Squirrel') {
                if (mapKey == 720)
                    $jbrowse.src = URL + "data_squirrel2_0&loc=";
            }
            if (species == 'Naked Mole-rat') {
                if (mapKey == 1410)
                    $jbrowse.src = URL + "data_hetGla2&loc=";
            }
            if (species == 'Green Monkey') {
                if (mapKey == 1311)
                    $jbrowse.src = URL + "data_chlSab2&loc=";
                if (mapKey == 1313)
                    $jbrowse.src = URL + "data_veroWho&loc=";
            }
        }
    });
</script>





