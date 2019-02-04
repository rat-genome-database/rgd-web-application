<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.web.*" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>


<%
    String pageTitle = "Gene Enrichment Tool";
    String headContent = "";
    String pageDescription = "Generate an enrichment report for a list of genes.";
%>
<%@ include file="/common/headerarea.jsp" %>

<% try { %>

<%@ include file="../ga/gaHeader.jsp" %>

<%

    //this page is written really poorly and needs to be refactored to use an ajax call to get maps and chromosomes.


    MapDAO mdao = new MapDAO();

    List<Map> ratMaps= mdao.getMaps(SpeciesType.RAT, "bp");
    List<Map> mouseMaps= mdao.getMaps(SpeciesType.MOUSE, "bp");
    List<Map> humanMaps= mdao.getMaps(SpeciesType.HUMAN, "bp");
    List<Map> chinMaps= mdao.getMaps(SpeciesType.CHINCHILLA, "bp");
    List<Map> bonoboMaps= mdao.getMaps(SpeciesType.BONOBO, "bp");
    List<Map> dogMaps= mdao.getMaps(SpeciesType.DOG, "bp");
    List<Map> squirrelMaps= mdao.getMaps(SpeciesType.SQUIRREL, "bp");

    List<Chromosome> ratChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey());
    List<Chromosome> mouseChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.MOUSE).getKey());
    List<Chromosome> humanChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.HUMAN).getKey());
    //List<Chromosome> chinchillaChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.CHINCHILLA).getKey());
    List<Chromosome> chinchillaChr = new ArrayList<Chromosome>();
    List<Chromosome> bonoboChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.BONOBO).getKey());
    List<Chromosome> dogChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.DOG).getKey());
    //List<Chromosome> squirrelChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.SQUIRREL).getKey());
    List<Chromosome> squirrelChr = new ArrayList<Chromosome>();

    LinkedHashMap chinKeyValues= new LinkedHashMap();
    LinkedHashMap ratKeyValues= new LinkedHashMap();
    LinkedHashMap humanKeyValues= new LinkedHashMap();
    LinkedHashMap mouseKeyValues= new LinkedHashMap();
    LinkedHashMap bonoboKeyValues= new LinkedHashMap();
    LinkedHashMap dogKeyValues= new LinkedHashMap();
    LinkedHashMap squirrelKeyValues= new LinkedHashMap();

    Iterator it = ratMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        ratKeyValues.put(m.getKey() + "", m.getName());
    }

    chinMaps = mdao.getMaps(SpeciesType.CHINCHILLA, "bp");
    it = chinMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        chinKeyValues.put(m.getKey() + "", m.getName());
    }
    it = mouseMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        mouseKeyValues.put(m.getKey() + "", m.getName());
    }
    it = humanMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        humanKeyValues.put(m.getKey() + "", m.getName());
    }
    it = bonoboMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        bonoboKeyValues.put(m.getKey() + "", m.getName());
    }
    it = dogMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        dogKeyValues.put(m.getKey() + "", m.getName());
    }
    it = squirrelMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        squirrelKeyValues.put(m.getKey() + "", m.getName());
    }


%>


<script>

    var ratMapHtml = '<%=fu.buildSelectList("mapKey", ratKeyValues, mdao.getPrimaryRefAssembly(3).getKey() + "")%>';
    var mouseMapHtml='<%=fu.buildSelectList("mapKey", mouseKeyValues, mdao.getPrimaryRefAssembly(2).getKey() + "")%>';
    var humanMapHtml='<%=fu.buildSelectList("mapKey", humanKeyValues, mdao.getPrimaryRefAssembly(1).getKey() + "")%>';
    var chinMapHtml = '<%=fu.buildSelectList("mapKey", chinKeyValues, mdao.getPrimaryRefAssembly(4).getKey() + "")%>';
    var bonoboMapHtml='<%=fu.buildSelectList("mapKey", bonoboKeyValues, mdao.getPrimaryRefAssembly(5).getKey() + "")%>';
    var dogMapHtml='<%=fu.buildSelectList("mapKey", dogKeyValues, mdao.getPrimaryRefAssembly(6).getKey() + "")%>';
    var squirrelMapHtml='<%=fu.buildSelectList("mapKey", squirrelKeyValues, mdao.getPrimaryRefAssembly(7).getKey() + "")%>';

    var ratChrHtml = '<%=fu.buildChrSelectList("chr", ratChr, "1")%>';
    var mouseChrHtml = '<%=fu.buildChrSelectList("chr", mouseChr, "1")%>';
    var humanChrHtml = '<%=fu.buildChrSelectList("chr", humanChr, "1")%>';
    var chinchillaChrHtml = '<%=fu.buildChrSelectList("chr", chinchillaChr, "1")%>';
    var bonoboChrHtml = '<%=fu.buildChrSelectList("chr", bonoboChr, "1")%>';
    var dogChrHtml = '<%=fu.buildChrSelectList("chr", dogChr, "1")%>';
    var squirrelChrHtml = '<%=fu.buildChrSelectList("chr", squirrelChr, "1")%>';


    function toggle(name) {
        checkboxes = document.getElementsByName(name);

        var checked = "checked";
        if (checkboxes[0].checked) {
            checked=false;
        }

        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = checked;
        }
    }

    function viewReport(rgdId) {
        document.report.rgdId.value = rgdId;
        document.report.submit();

    }


    function setMap(obj) {
        var selected = obj.options[obj.selectedIndex].value;

        var maps=document.getElementById("maps");

        if (selected==1) {
            maps.innerHTML=humanMapHtml;
            chroms.innerHTML=humanChrHtml;
        }else if (selected==2) {
            maps.innerHTML=mouseMapHtml;
            chroms.innerHTML=mouseChrHtml;
        }else if (selected==3) {
            maps.innerHTML=ratMapHtml;
            chroms.innerHTML=ratChrHtml;
        }else if (selected==4) {
            maps.innerHTML=chinMapHtml;
            chroms.innerHTML=chinchillaChrHtml;
        }else if (selected==5) {
            maps.innerHTML = bonoboMapHtml;
            chroms.innerHTML=bonoboChrHtml;
        }else if (selected==6) {
            maps.innerHTML = dogMapHtml;
            chroms.innerHTML=dogChrHtml;
        }else if (selected==7) {
            maps.innerHTML=squirrelMapHtml;
            chroms.innerHTML=squirrelChrHtml;
        }else {
            maps.innerHTML=ratMapHtml;
            chroms.innerHTML=ratChrHtml;
        }
    }
</script>

<%
    String tutorialLink="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/gene-annotator-tutorial";
    String pageHeader="Gene Enrichment Tool - Generate an enrichment report for a list of genes";
%>
<%@ include file="/common/title.jsp" %>
<br>

<%
    int speciesTypeKey=3;
    String mapKey=request.getParameter("mapKey");

    if (mapKey != null &&  !mapKey.equals("")) {
        speciesTypeKey=SpeciesType.getSpeciesTypeKeyForMap(Integer.parseInt(mapKey));
    }
%>


<form action="/rgdweb/enrichment/analysis.html" method="POST">
    <table border=0>

        <tr>
            <td style="color: #2865a3; font-size: 16px; font-weight:600;">Select a Species</td>
            <td style="padding-left:30px;">
                <select name="species" id="species" onChange="setMap(this)">
                    <option value="3" <% if (speciesTypeKey==3) out.print("SELECTED"); %>>Rat</option>
                    <option  value="2" <% if (speciesTypeKey==2) out.print("SELECTED"); %>>Mouse</option>
                    <option  value="1" <% if (speciesTypeKey==1) out.print("SELECTED"); %>>Human</option>
                    <option  value="4" <% if (speciesTypeKey==4) out.print("SELECTED"); %>>Chinchilla</option>
                    <option  value="5" <% if (speciesTypeKey==5) out.print("SELECTED"); %>>Bonobo</option>
                    <option  value="6" <% if (speciesTypeKey==6) out.print("SELECTED"); %>>Dog</option>
                    <option  value="7" <% if (speciesTypeKey==7) out.print("SELECTED"); %>>Squirrel</option>
                </select>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td  style="color: #2865a3; font-size: 16px; font-weight:600;">Enter Gene Symbols</td>
            <td style="padding-left:30px;">
                Example: a2m,xiap,lepr,tnf<br>
                <textarea placeholder="When entering multiple identifiers your list can be separated by commas, spaces, tabs, or line feeds" id="genes" name="genes" rows="12" cols=70  ><%=dm.out("genes",req.getParameter("genes"))%></textarea>
                <!--
            <textarea name="genes" rows="12" cols=70 ng-model="importTarget" >
                {{importTarget}}<%=dm.out("genes",req.getParameter("genes"))%>
            </textarea>
            -->
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr><td style="color: #2865a3; font-size: 16px; font-weight:600;">Select the Ontologies</td>
            <td style="padding-left:30px;">
            <table class="gaLabel">
                <tr>
                    <td class="gaLabel" colspan=2>Ontology Annotations &nbsp;&nbsp;<a href="javascript:void(0);" style="color:#4088b8;" onclick="toggle('o')">(toggle)</a></td>

                        <%
                for( java.util.Map.Entry<String,String> aspect: aspects.entrySet() ) {
                %>
                <tr>
                    <td><input type="checkbox" name="o" value="<%=aspect.getKey()%>" <% if (req.isInParameterValues("o",aspect.getKey())) out.print("checked"); %>>
                    </td>
                    <td><%=aspect.getValue()%>
                    </td>
                </tr>

                <% } %>
            </table> </td></tr>
        <tr><td colspan="2"><div id="gaPos"><table>
            <tr><td style="color: #2865a3; font-size: 16px; font-weight:600; background-color:#e6e6e6;" colspan="2"><b>Enter a genomic region &nbsp;&nbsp;<span style="color:#205080;">(Optional)</span></b></td></tr>
            <tr><td>Genes in this region are appended to your gene list</td></tr>
            <tr><td style="color: #2865a3; font-size: 16px; font-weight:600;">Enter a Position</td>
                <td>
                    <table border=0>
                        <tr>
                            <td>Chr</td><td> <div id="chroms"></div></td>
                            <td>Start <input type="text" name="start" value='<%=dm.out("start",req.getParameter("start"))%>' /></td>
                            <td>Stop <input type="text" name="stop" value='<%=dm.out("stop",req.getParameter("stop"))%>' /></td>
                            <td>Assembly</td>
                            <td>
                                <div id="maps"></div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr><td>&nbsp;</td></tr>
        </table></div><!--#gaPos--></td></tr>

        <tr>
            <td><input type="submit" value="Submit >>"/></td>
        </tr>
    </table>

    <script>
        setMap(document.getElementById("species"));
    </script>

        <% } catch (Exception e) {
        e.printStackTrace();
     } %>

    <%@ include file="/common/footerarea.jsp" %>

