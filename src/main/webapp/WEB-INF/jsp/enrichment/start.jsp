<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.web.*" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>
<script src="https://unpkg.com/vue@2.4.2"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/start.css">



<%
    String pageTitle = "Ontology Enrichment";
    String headContent = "";
    String pageDescription = "Generate an enrichment report for a list of genes.";
%>
<%@ include file="/common/headerarea.jsp" %>

<% try { %>
<%
    //initializations
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req,  new java.util.ArrayList());
    FormUtility fu = new FormUtility();
    UI ui=new UI();
    AnnotationDAO adao = new AnnotationDAO();
    GeneDAO gdao = new GeneDAO();

    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
    List termSet= Utils.symbolSplit(req.getParameter("terms"));
    List<TermWrapper> termWrappers = new ArrayList();

    MapDAO mdao = new MapDAO();
    List<Map> ratMaps= mdao.getMaps(SpeciesType.RAT, "bp");
    List<Map> mouseMaps= mdao.getMaps(SpeciesType.MOUSE, "bp");
    List<Map> humanMaps= mdao.getMaps(SpeciesType.HUMAN, "bp");
    List<Map> chinMaps= mdao.getMaps(SpeciesType.CHINCHILLA, "bp");
    List<Map> bonoboMaps= mdao.getMaps(SpeciesType.BONOBO, "bp");
    List<Map> dogMaps= mdao.getMaps(SpeciesType.DOG, "bp");
    List<Map> squirrelMaps= mdao.getMaps(SpeciesType.SQUIRREL, "bp");
    List<Map> pigMaps= mdao.getMaps(SpeciesType.PIG, "bp");
    List<Map> moleRatMaps= mdao.getMaps(SpeciesType.NAKED_MOLE_RAT, "bp");
    List<Map> greenMonkeyMaps= mdao.getMaps(SpeciesType.VERVET, "bp");
    List<Map> blackRatMaps= mdao.getMaps(SpeciesType.BLACK_RAT, "bp");
    List<Chromosome> ratChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey());
    List<Chromosome> mouseChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.MOUSE).getKey());
    List<Chromosome> humanChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.HUMAN).getKey());
    //List<Chromosome> chinchillaChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.CHINCHILLA).getKey());
    List<Chromosome> chinchillaChr = new ArrayList<Chromosome>();
    List<Chromosome> bonoboChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.BONOBO).getKey());
    List<Chromosome> dogChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.DOG).getKey());
    //List<Chromosome> squirrelChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.SQUIRREL).getKey());
    List<Chromosome> squirrelChr = new ArrayList<Chromosome>();
    List<Chromosome> pigChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.PIG).getKey());
    List<Chromosome> moleRatChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.NAKED_MOLE_RAT).getKey());
    List<Chromosome> greenMonkeyChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.VERVET).getKey());
    List<Chromosome> blackRatChr = mdao.getChromosomes(MapManager.getInstance().getReferenceAssembly(SpeciesType.BLACK_RAT).getKey());
    LinkedHashMap chinKeyValues= new LinkedHashMap();
    LinkedHashMap ratKeyValues= new LinkedHashMap();
    LinkedHashMap humanKeyValues= new LinkedHashMap();
    LinkedHashMap mouseKeyValues= new LinkedHashMap();
    LinkedHashMap bonoboKeyValues= new LinkedHashMap();
    LinkedHashMap dogKeyValues= new LinkedHashMap();
    LinkedHashMap squirrelKeyValues= new LinkedHashMap();
    LinkedHashMap pigKeyValues= new LinkedHashMap();
    LinkedHashMap moleRatKeyValues= new LinkedHashMap();
    LinkedHashMap greenMonkeyKeyValues= new LinkedHashMap();
    LinkedHashMap blackRatKeyValues= new LinkedHashMap();

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
    it = pigMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        pigKeyValues.put(m.getKey() + "", m.getName());
    }
    it = moleRatMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        moleRatKeyValues.put(m.getKey() + "", m.getName());
    }
    it = greenMonkeyMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        greenMonkeyKeyValues.put(m.getKey() + "", m.getName());
    }
    it = blackRatMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
       blackRatKeyValues.put(m.getKey() + "", m.getName());
    }
%>


<script>

       var humanMaps = '<%=fu.buildSelectListWithCss("mapKey", humanKeyValues, mdao.getPrimaryRefAssembly(1).getKey() + "","form-control inputstl")%>';
       var humanChroms = '<%=fu.buildChrSelectListWithCss("chr", humanChr, "1","form-control inputstl")%>';
       var mouseMaps = '<%=fu.buildSelectListWithCss("mapKey", mouseKeyValues, mdao.getPrimaryRefAssembly(2).getKey() + "","form-control inputstl")%>';
       var mouseChroms = '<%=fu.buildChrSelectListWithCss("chr", mouseChr, "1","form-control inputstl")%>';
       var ratMaps = '<%=fu.buildSelectListWithCss("mapKey", ratKeyValues, mdao.getPrimaryRefAssembly(3).getKey() + "","form-control inputstl")%>';
       var ratChroms = '<%=fu.buildChrSelectListWithCss("chr", ratChr, "1","form-control inputstl")%>';
        var chinMaps = '<%=fu.buildSelectListWithCss("mapKey", chinKeyValues, mdao.getPrimaryRefAssembly(4).getKey() + "","form-control inputstl")%>';
        var chinChroms = '<%=fu.buildChrSelectListWithCss("chr", chinchillaChr, "1","form-control inputstl")%>';
        var bonoboMaps = '<%=fu.buildSelectListWithCss("mapKey", bonoboKeyValues, mdao.getPrimaryRefAssembly(5).getKey() + "","form-control inputstl")%>';
        var bonoboChroms= '<%=fu.buildChrSelectListWithCss("chr", bonoboChr, "1","form-control inputstl")%>';
        var dogMaps = '<%=fu.buildSelectListWithCss("mapKey", dogKeyValues, mdao.getPrimaryRefAssembly(6).getKey() + "","form-control inputstl")%>';
        var dogChroms = '<%=fu.buildChrSelectListWithCss("chr", dogChr, "1","form-control inputstl")%>';
        var squiMaps = '<%=fu.buildSelectListWithCss("mapKey", squirrelKeyValues, mdao.getPrimaryRefAssembly(7).getKey() + "","form-control inputstl")%>';
        var squiChroms = '<%=fu.buildChrSelectListWithCss("chr", squirrelChr, "1","form-control inputstl")%>';
       var pigMaps = '<%=fu.buildSelectListWithCss("mapKey", pigKeyValues, mdao.getPrimaryRefAssembly(9).getKey() + "","form-control inputstl")%>';
       var pigChroms = '<%=fu.buildChrSelectListWithCss("chr", pigChr, "1","form-control inputstl")%>';
       var moleRatMaps = '<%=fu.buildSelectListWithCss("mapKey", moleRatKeyValues, mdao.getPrimaryRefAssembly(14).getKey() + "","form-control inputstl")%>';
       var moleRatChroms = '<%=fu.buildChrSelectListWithCss("chr", moleRatChr, "1","form-control inputstl")%>';
       var greenMonkeyMaps = '<%=fu.buildSelectListWithCss("mapKey", greenMonkeyKeyValues, mdao.getPrimaryRefAssembly(13).getKey() + "","form-control inputstl")%>';
       var greenMonkeyChroms = '<%=fu.buildChrSelectListWithCss("chr", greenMonkeyChr, "1","form-control inputstl")%>';
       var blackRatMaps = '<%=fu.buildSelectListWithCss("mapKey", blackRatKeyValues, mdao.getPrimaryRefAssembly(17).getKey() + "","form-control inputstl")%>';
       var blackRatChroms = '<%=fu.buildChrSelectListWithCss("chr", blackRatChr, "1","form-control inputstl")%>';
</script>
<script src="/rgdweb/js/enrichment/start.js"></script>

<%
    String pageHeader="MOET - Multi Ontology Enrichment Tool";
%>

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%></div><br>
    <a href = "https://rgd.mcw.edu/wg/new-moet-algorithm/">*The New MOET Algorithm (v.2 released in May 2021)*</a>
</div>


<br>
<div id="app">
<form name="enrichment" action="/rgdweb/enrichment/analysis.html" onsubmit="return v.validate()" method="POST">

    <table border=0>

        <tr>
            <td style=" font-size: 16px; " >Select a Species to view enrichment for all RGD ontologies</td>
            <td >
                <select class="form-control inputstl" name="species" id="species" onChange="v.setMap(this)">
                    <option value="3">Rat</option>
                    <option  value="2">Mouse</option>
                    <option  value="1">Human</option>
                    <option  value="4">Chinchilla</option>
                    <option  value="5">Bonobo</option>
                    <option  value="6">Dog</option>
                    <option  value="7">Squirrel</option>
                    <option value="9">Pig</option>
                    <option value="14">Naked Mole-Rat</option>
                    <option value="13">Green Monkey</option>
                    <option value="17">Black Rat</option>

                </select>
            </td>
        </tr>

        <tr><td>&nbsp;</td></tr>
        <tr>

            <td style=" font-size: 16px; ">Select an Ontology to view enrichment in all RGD species</td>
            <td>
                <select  class="form-control inputstl" name="o" id="o">
                    <option value="RDO">Disease</option>
                    <option value="PW">Pathway</option>
                    <option  value="MP">Phenotype</option>
                    <option  value="BP">GO: Biological Process</option>
                    <option  value="CC" >GO: Cellular Component</option>
                    <option  value="MF" >GO: Molecular Function</option>
                    <option  value="CHEBI">Chemical Interactions</option>
                </select>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td  style=" font-size: 16px; ">Enter Symbols<br>
             <span style=" font-size: 12px; "><b>Please select an identifier type</b></span>

                <table>
                        <tr>
                            <td style="font-size:11px;"><input type="radio" name="idType" value="affy"/>Affymetrix Array ID</td>
                            <td style="font-size:11px;"><input type="radio" name="idType" value=" "/>&nbsp;GenBank Nucleotide</td>
                            <td style="font-size:11px;"><input type="radio" name="idType" value=" "/>&nbsp;GO Term ID</td>
                        </tr>
                        <tr>
                            <td style="font-size:11px;"><input type="radio" name="idType" value=" "/>&nbsp;Ensembl Gene</td>
                            <td style="font-size:11px;"><input type="radio" name="idType" value=" "/>&nbsp;GenBank Protein</td>
                            <td style="font-size:11px;"> <input type="radio" name="idType" value="rgd" />Gene&nbsp;RGD ID &nbsp;</td>
                        </tr>
                        <tr>
                            <td style="font-size:11px;"><input type="radio" name="idType" value=" "/>&nbsp;Ensembl Protein</td>
                            <td style="font-size:11px;"><input type="radio" name="idType" value=" " checked="checked"/>&nbsp;Gene Symbol</td>
                            <td style="font-size:11px;"><input type="radio" name="idType" value="entrez"/>&nbsp;EntrezGene ID</td>
                        </tr>
                </table>
            </td>
            <td>

                <textarea  class="form-control inputstl" placeholder="When entering multiple identifiers your list can be separated by commas, spaces, tabs, or line feeds" id="genes" name="genes" rows="6" cols=35 ><%=dm.out("genes",req.getParameter("genes"))%></textarea>
                <%=dm.out("genes",req.getParameter("genes"))%>

            </td>
        </tr>


        <tr><td>&nbsp;</td></tr>
        <tr><td>&nbsp;</td><td><span style="color:#0062cc; font-size: 30px; font-weight:600;">(Or)</span></td></tr>
        <tr><td colspan="2">

            <table border="0">
                <tr><td>&nbsp;</td></tr>
                <tr><td style="font-size: 16px; ">Enter a Genomic Region</td>
                    <td style="padding-left:120px;">
                        <table border=0 width="100%">
                            <tr>
                                <td style="font-weight:bold">Chr <div id="chroms"></div></td>
                                <td>&nbsp;</td>
                                <td style="font-weight:bold">Start<input  class="form-control inputstl" type="text" name="start" value='<%=dm.out("start",req.getParameter("start"))%>' /></td>
                                <td>&nbsp;</td>
                                <td style="font-weight:bold">Stop <input  class="form-control inputstl" type="text" name="stop" value='<%=dm.out("stop",req.getParameter("stop"))%>' /></td>
                                <td>&nbsp;</td>
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
            <td ><input class="btn btn-primary btn-lg" style="background-color:#2B84C8;" type="submit" value="Continue"/></td>
        </tr>
    </table>
    </form>
</div>
    <script>
        var species = document.getElementById("species");
        species.value = <%=request.getParameter("species")%>;
        v.setMap(document.getElementById("species"));
    </script>


        <% } catch (Exception e) {
        e.printStackTrace();
     } %>

    <%@ include file="/common/footerarea.jsp" %>

