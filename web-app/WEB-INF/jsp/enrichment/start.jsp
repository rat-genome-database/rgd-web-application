<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.web.*" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<script src="https://unpkg.com/vue@2.4.2"></script>

<style>
    .inputstl {
        padding: 9px;
        border: solid 1px #4B718B;
        outline: 0;
        background: -webkit-gradient(linear, left top, left 25, from(#FFFFFF), color-stop(4%, #e6f0ff), to(#FFFFFF));
        background: -moz-linear-gradient(top, #FFFFFF, #e6f0ff 1px, #FFFFFF 25px);
        box-shadow: rgba(0,0,0, 0.1) 0px 0px 8px;
        -moz-box-shadow: rgba(0,0,0, 0.1) 0px 0px 8px;
        -webkit-box-shadow: rgba(0,0,0, 0.1) 0px 0px 8px;
        font-weight: bold;

    }
    .heading
    {
        text-align: center;
        height: 80px;
        background: linear-gradient(135deg,#2655c1,#372f7f,#2655c1,#372f7f);
        color: #fff;
        font-weight: bold;
        line-height: 80px;
    }
    .btnSubmit
    {
        border:none;
        border-radius:1.5rem;
        padding: 3%;
        width: 25%;
        cursor: pointer;
        background: #2655c1;
        color: #fff;
    }
    hr {
        margin-top: 1rem;
        margin-bottom: 1rem;
        border: 0;
        border-top: 3px solid #372f7f;
    }

</style>


<%
    String pageTitle = "Gene Enrichment Tool";
    String headContent = "";
    String pageDescription = "Generate an enrichment report for a list of genes.";
%>
<%@ include file="/common/headerarea.jsp" %>

<% try { %>

<%@ include file="../ga/gaHeader.jsp" %>

<%  MapDAO mdao = new MapDAO();
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
    var v = new Vue({
        el: '#app',
        data: {
            selected: 0
        },
        methods: {

        viewReport: function (rgdId) {
        document.report.rgdId.value = rgdId;
        document.report.submit();
        },

        setMap: function () {
            alert(this.selected);
        var selected = this.selected;
        var maps = document.getElementById("maps");

        if (selected == 1) {

            maps.innerHTML = '<%=fu.buildSelectListWithCss("mapKey", humanKeyValues, mdao.getPrimaryRefAssembly(1).getKey() + "","form-control inputstl")%>';
            chroms.innerHTML = '<%=fu.buildChrSelectListWithCss("chr", humanChr, "1","form-control inputstl")%>';
        } else if (selected == 2) {
            maps.innerHTML = '<%=fu.buildSelectListWithCss("mapKey", mouseKeyValues, mdao.getPrimaryRefAssembly(2).getKey() + "","form-control inputstl")%>';
            chroms.innerHTML = '<%=fu.buildChrSelectListWithCss("chr", mouseChr, "1","form-control inputstl")%>';
        } else if (selected == 3) {
            maps.innerHTML = '<%=fu.buildSelectListWithCss("mapKey", ratKeyValues, mdao.getPrimaryRefAssembly(3).getKey() + "","form-control inputstl")%>';
            chroms.innerHTML = '<%=fu.buildChrSelectListWithCss("chr", ratChr, "1","form-control inputstl")%>';
        } else if (selected == 4) {
            maps.innerHTML = '<%=fu.buildSelectListWithCss("mapKey", chinKeyValues, mdao.getPrimaryRefAssembly(4).getKey() + "","form-control inputstl")%>';
            chroms.innerHTML = '<%=fu.buildChrSelectListWithCss("chr", chinchillaChr, "1","form-control inputstl")%>';
        } else if (selected == 5) {
            maps.innerHTML = '<%=fu.buildSelectListWithCss("mapKey", bonoboKeyValues, mdao.getPrimaryRefAssembly(5).getKey() + "","form-control inputstl")%>';
            chroms.innerHTML = '<%=fu.buildChrSelectListWithCss("chr", bonoboChr, "1","form-control inputstl")%>';
        } else if (selected == 6) {
            maps.innerHTML = '<%=fu.buildSelectListWithCss("mapKey", dogKeyValues, mdao.getPrimaryRefAssembly(6).getKey() + "","form-control inputstl")%>';
            chroms.innerHTML = '<%=fu.buildChrSelectListWithCss("chr", dogChr, "1","form-control inputstl")%>';
        } else if (selected == 7) {
            maps.innerHTML = '<%=fu.buildSelectListWithCss("mapKey", squirrelKeyValues, mdao.getPrimaryRefAssembly(7).getKey() + "","form-control inputstl")%>';
            chroms.innerHTML = '<%=fu.buildChrSelectListWithCss("chr", squirrelChr, "1","form-control inputstl")%>';
        } else {
            maps.innerHTML = '<%=fu.buildSelectListWithCss("mapKey", ratKeyValues, mdao.getPrimaryRefAssembly(3).getKey() + "","form-control inputstl")%>';
            chroms.innerHTML = '<%=fu.buildChrSelectListWithCss("chr", ratChr, "1","form-control inputstl")%>';
        }
        }
    },
     watch: {
         selected(){
             alert("changed");
             v.setMap();
         }
     }
    })
</script>

<%
    String pageHeader="Gene Enrichment Tool - Generate an enrichment report for a list of genes";
%>
<div class="heading">
    <p style="font-size:30px; color:white; font-weight:600;"><%=pageHeader%></p>
</div>

<br>


<hr></hr>
<br>
<div id="app">
<form action="/rgdweb/enrichment/analysis.html" method="POST">
    <table border=0>

        <tr>
            <td style=" font-size: 16px; font-weight:600;">Select a Species to view enrichment for all RGD ontologies</td>
            <td >
                <select  v-model="selected" class="form-control inputstl" name="species" id="species">
                    <option value="0">All</option>
                    <option value="3">Rat</option>
                    <option  value="2">Mouse</option>
                    <option  value="1">Human</option>
                    <option  value="4">Chinchilla</option>
                    <option  value="5">Bonobo</option>
                    <option  value="6">Dog</option>
                    <option  value="7">Squirrel</option>
                </select>
            </td>
        </tr>

        <tr><td>{{selected}}</td></tr>
        <tr>

            <td style=" font-size: 16px; font-weight:600;">Select an Ontology to view enrichment in all RGD species</td>
            <td>
                <select  class="form-control inputstl" name="o" id="o">
                    <option value="D">Disease</option>
                    <option value="W">Pathway</option>
                    <option  value="P">Phenotype</option>
                    <option  value="C">GO: Biological Process</option>
                    <option  value="F" >GO: Cellular Component</option>
                    <option  value="N" >GO: Molecular Function</option>
                    <option  value="E">Chemical Interactions</option>
                </select>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td  style=" font-size: 16px; font-weight:600;">Enter Gene Symbols</td>
            <td>
                <span style="font-weight:bold">Example: a2m,xiap,lepr,tnf</span><br>
                <textarea  class="form-control inputstl" placeholder="When entering multiple identifiers your list can be separated by commas, spaces, tabs, or line feeds" id="genes" name="genes" rows="6" cols=35 style="border-color: #2865a3;" ><%=dm.out("genes",req.getParameter("genes"))%></textarea>
                <%=dm.out("genes",req.getParameter("genes"))%>

            </td>
        </tr>


        <tr><td>&nbsp;</td></tr>
        <tr><td>&nbsp;</td><td><span style="color:#0062cc; font-size: 30px; font-weight:600;">(Or)</span></td></tr>
        <tr><td colspan="2">

            <table>
                <tr><td>&nbsp;</td></tr>
                <tr><td style="font-size: 16px; font-weight:600;">Enter a Genomic Region</td>
                    <td style="padding-left:120px;">
                        <table border=0>
                            <tr>
                                <td style="font-weight:bold">Chr</td><td> <div id="chroms"></div></td>
                                <td style="font-weight:bold">Start <input  class="form-control inputstl" type="text" name="start" value='<%=dm.out("start",req.getParameter("start"))%>' /></td>
                                <td style="font-weight:bold">Stop <input  class="form-control inputstl" type="text" name="stop" value='<%=dm.out("stop",req.getParameter("stop"))%>' /></td>
                                <td style="font-weight:bold">Assembly</td>
                                <td id="maps">

                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr><td>&nbsp;</td></tr>
            </table><!--#gaPos--></td></tr>

        <tr>
            <td><input class="btnSubmit" type="submit" value="Submit"/></td>
        </tr>
    </table>
</div>
    <script>
        v.setMap(document.getElementById("species"));
    </script>


        <% } catch (Exception e) {
        e.printStackTrace();
     } %>

    <%@ include file="/common/footerarea.jsp" %>

