<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.VariantDAO" %>
<%
    MapData md50 = null;
    if( obj.getSpeciesTypeKey() == SpeciesType.RAT ) {
        List<MapData> mds = mapDAO.getMapData(obj.getRgdId(), 360);
        if( !mds.isEmpty() ) {
            md50 = mds.get(0);
        }
    }
    if( md50!=null && md50.getChromosome() != null && md50.getStartPos() != null && md50.getStopPos() != null) {

        String chr = md50.getChromosome();
        long start = md50.getStartPos();
        long stop = md50.getStopPos();

        SampleDAO sampleDAO = new SampleDAO();
        sampleDAO.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
        List<Sample> samples = sampleDAO.getSamplesOrderedByName(600);

        VariantDAO vdao = new VariantDAO();
        vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
%>
<br><div class="subTitle" id="strainVariation">Strain Variation</div><br>

<%@ include file="sectionHeader.jsp"%>


<div class="sectionHeading" id="strainSequenceVariants">Strain Sequence Variants (Rnor 6.0)</div>

<div id="strainSequenceVariantsTableDiv">

    <div id="modelsViewContent" >
        <div id="strainSequenceVariantsPager" class="pager" style="float:right;margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="5">5</option>
                    <option value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>





<table border=0  width="100%" id="strainSequenceVariantsTable">
    <thead></thead>
    <tbody>
<%
    for (Sample samp: samples) {
        String url = "/rgdweb/carpe/search.html?chr=" + chr + "&sampleId=" + samp.getId() + "&start=" + start + "&end=" + stop;
%>
       <tr>
           <td valign="left">
               <table border=0 id="table<%=samp.getId()%>" width="100%" style="border-bottom: 2px solid #eeeeee;" >
                   <tr>
                       <td colspan=0 width=200 valign="top"><a href="/rgdweb/front/variants.html?chr=&start=&stop=&geneStart=&geneStop=&mapKey=360&geneList=<%=obj.getSymbol()%>&con=&polyphenPrediction=&depthLowBound=&depthHighBound=&sample1=<%=samp.getId()%>"><%=samp.getAnalysisName()%></a><br></td>
                       <td valign=top width=250>
                           <table>
                               <tr>
                                   <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><a href="/rgdweb/front/variants.html?chr=&start=&stop=&geneStart=&geneStop=&mapKey=360&geneList=<%=obj.getSymbol()%>&con=&polyphenPrediction=&depthLowBound=&depthHighBound=&sample1=<%=samp.getId()%>" style="font-size:10px;">Visual</a>
                                   <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><a href="<%=url%>&fmt=2" style="font-size:10px;">CSV</a>
                                   <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><a href="<%=url%>&fmt=3" style="font-size:10px;">TAB</a>
                                   <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><a href="<%=url%>&fmt=4" style="font-size:10px;">Printer</a>
                               </tr>
                           </table>
                       </td>


                       <td style="font-size:11px;" >
                           <table border=0 >

                               <% if (samp.getSequencedBy() != null) { %>
                               <tr>
                                   <td width=125 valign="top" style="font-size:10px; font-weight:700;">Sequenced By:</td>
                                   <td style="font-size:10px;"><%=samp.getSequencedBy()%></td>
                               </tr>
                               <% } %>
                               <% if (samp.getSequencer() != null) { %>
                               <tr>
                                   <td style="font-size:10px; font-weight:700;">Platform:</td>
                                   <td style="font-size:10px;"><%=samp.getSequencer()%></td>
                               </tr>
                               <% } %>
                               <% if (samp.getSecondaryAnalysisSoftware() != null) { %>
                               <tr>
                                   <td style="font-size:10px; font-weight:700;">Secondary Analysis:</td>
                                   <td style="font-size:10px;"><%=samp.getSecondaryAnalysisSoftware()%></td>
                               </tr>
                               <% } %>
                               <% if (samp.getWhereBred() != null) { %>
                               <tr>
                                   <td style="font-size:10px; font-weight:700;">Breeder:</td>
                                   <td style="font-size:10px;"><%=samp.getWhereBred()%></td>
                               </tr>
                               <% } %>
                               <%--
                               <% if (samp.getGrantNumber() != null) { %>
                               <tr>
                                   <td style="font-size:10px; font-weight:700;">Grant Information:</td>
                                   <td style="font-size:10px;"><%=samp.getGrantNumber()%></td>
                               </tr>
                               <% } %>
                               --%>
                               <% if (samp.getDescription() != null) { %>
                               <tr>
                                   <td style="font-size:10px; font-weight:700;">Description:</td>
                                   <td style="font-size:10px;"><%=samp.getDescription()%></td>
                               </tr>
                               <% } %>
                               <% if (samp.getRefRgdId() != 0) {
                                   Reference sampleRef = referenceDAO.getReferenceByRgdId(samp.getRefRgdId());
                               %>
                               <tr>
                                   <td style="font-size:10px; font-weight:700;">Publications:</td>
                                   <td style="font-size:10px;"><%=sampleRef.getCitation()%></td>
                               </tr>
                               <% } %>
                           </table>
                       </td>
                   </tr>
               </table>
           </td>
       </tr>

    <% } %>
    </tbody>
</table>

</div>

<%@ include file="sectionFooter.jsp"%>

<% } %>
