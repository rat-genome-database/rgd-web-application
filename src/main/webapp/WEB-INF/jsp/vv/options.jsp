<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%
    String pageTitle = "Variant Visualizer (Options)";
    String headContent = "";
    String pageDescription = "Select Options";

    int mapKey=372;
    if(request.getParameter("mapKey")!=null)
        mapKey=Integer.parseInt(request.getParameter("mapKey"));
    edu.mcw.rgd.datamodel.Map currentMap = MapManager.getInstance().getMap(mapKey);
    VariantSearchBean vsb = (VariantSearchBean) request.getAttribute("vsb");
%>
<%@ include file="/common/headerarea.jsp" %>
<script type="text/javascript"  src="/solr/OntoSolr/files/jquery-1.4.3.min.js"></script>
<script type="text/javascript"  src="/solr/OntoSolr/files/jquery.autocomplete.js"></script>
<link rel="stylesheet" href="/solr/OntoSolr/files/jquery.autocomplete.css" type="text/css" />

<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>

<br>

<div class="typerMat">
    <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>


<table width="100%" class="stepLabel" border=0>
    <tr>
        <td><div style="padding:8px;">Select Sequence Annotation (Optional)</div></td>
        <td align="right" style="font-size:16px;"><%=currentMap.getName()%> assembly</td>
    </tr>
</table>

<% if( currentMap.getSpeciesTypeKey()!=SpeciesType.HUMAN ) { %>
<table width="100%" border=0 style="background-color:white;">
    <tr>
        <td><span style="color:red; font-weight:700;background-color:white;">Notice: </span>
            <span style="text-decoration:none; background-color:white; color:#011C47;"> Minimum read depth is now defaulted to 8
                and variants found in less than 15% of reads are excluded.<br>These defaults can be changed via the form below.</span>
        </td>
    </tr>
</table>
<% } %>

<form action="variants.html">
    <input type="hidden" name="start" value="<%=dm.out("start",vsb.getStartPosition() + "")%>"/>
    <input type="hidden" name="stop" size="25" value="<%=dm.out("stop",vsb.getStopPosition() + "")%>"/>

    <input type="hidden" name="chr" value="<%=dm.out("chr",vsb.getChromosome())%>"/>
    <input type="hidden" name="geneStart" value="<%=dm.out("geneStart",req.getParameter("geneStart"))%>"/>
    <input type="hidden" name="geneStop" value="<%=dm.out("geneStop",req.getParameter("geneStop"))%>"/>
    <input type="hidden" name="geneList" value="<%=dm.out("geneList",req.getParameter("geneList"))%>" />
    <input type="hidden" name="mapKey" value="<%=dm.out("mapKey",req.getParameter("mapKey"))%>" />

<table border=0 align="center" style="padding:8px; ">
    <tr>
        <td align="right" style="font-size:16px;color:white;" width=150>Additional options are not required. Leave form empty to include all variants in the defined region</td>
        <td>&nbsp;&nbsp;&nbsp;</td>
        <td >
            <table border="0" cellspacing=4 cellpadding=0 class="carpeASTable">
                <tr>
                    <td colspan=3><div class="typerSubTitle" >Genome</div></td>
                </tr>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Location</td>
                    <td><%=dm.makeCheckBox("intergenic", " Intergenic")%>
                        <%=dm.makeCheckBox("genic", " Genic")%>
                        <%=dm.makeCheckBox("nearSpliceSite", " Near Splice Site")%>
                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td>&nbsp;</td>
                    <td><%=dm.makeCheckBox("intron", " Intron")%>
                        <%=dm.makeCheckBox("3prime", " 3 Prime UTR")%>
                        <%=dm.makeCheckBox("5prime", " 5 Prime UTR")%>
                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Variant Type</td>
                    <td><%=dm.makeCheckBox("snv", " SNV")%>
                        <%=dm.makeCheckBox("ins", " Insertion")%>
                        <%=dm.makeCheckBox("del", " Deletion")%>
                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Limit to</td>
                    <td><%=dm.makeCheckBox("proteinCoding", " Coding Exon")%>
                        <%=dm.makeCheckBox("frameshift", " Frameshift")%>
                        <%=dm.makeCheckBox("prematureStopCodon", " Premature Stop")%>
                        <%=dm.makeCheckBox("readthroughMutation", " Readthrough")%>
                    </td>
                </tr>

                <%if (!vsb.getConScoreTable().equals("")) {%>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Conservation</td>
                    <td>
                        <select name="con">
                        <option value=""></option>
                        <option value="n">None (0)</option>
                        <option value="l">Low (.01-.49)</option>
                        <option value="m">Moderate (.5-.749)</option>
                        <option value="h">High (.75-1.0)</option>
                        </select>
                    </td>
                </tr>
                <%} else {%>
                    <input type="hidden" name="con" vlaue=""/>
                <% } %>
                <tr>
                    <td></td>
                    <!--td class="carpeLabel">Novelty</td-->
                    <!--td><%--=dm.makeCheckBox("foundDBSNP", " pos/change found in "+currentMap.getDbsnpVersion()+" &nbsp;"--)%>
                        <%=--dm.makeCheckBox("notDBSNP", " pos/change novel to "+currentMap.getDbsnpVersion())--%>
                    </td-->
                </tr>
                <tr>
                    <td>&nbsp;</td>
                </tr>
                <% if( currentMap.getSpeciesTypeKey()==SpeciesType.RAT || currentMap.getSpeciesTypeKey()==SpeciesType.DOG || currentMap.getSpeciesTypeKey()==SpeciesType.HUMAN) {%>
                <tr>
                    <td colspan=3><div class="typerSubTitle" >Protein</div></td>
                </tr>

                <%}
                    if( currentMap.getSpeciesTypeKey()==SpeciesType.RAT || currentMap.getSpeciesTypeKey()==SpeciesType.DOG ) { %>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Amino Acid Change</td>
                    <td><%=dm.makeCheckBox("synonymous", " Synonymous")%>
                        <%=dm.makeCheckBox("nonSynonymous", " Non-Synonymous")%>
                    </td>
                </tr>
                <% } %>

                <% if( currentMap.getSpeciesTypeKey()==SpeciesType.RAT || currentMap.getSpeciesTypeKey()==SpeciesType.DOG) { %>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Polyphen&nbsp;Prediction</td>
                    <td><%=dm.makeCheckBox("probably", " Probably Damaging")%>
                        <%=dm.makeCheckBox("possibly", " Possibly Damaging")%>
                        <%=dm.makeCheckBox("benign", " Benign")%>
                    </td>
                </tr>
                <% } %>

                <% if( currentMap.getSpeciesTypeKey()==SpeciesType.HUMAN ) { %>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Clinical&nbsp;Significance</td>
                    <td><%=dm.makeCheckBox("cs_pathogenic", " Pathogenic / Likely Pathogenic")%>
                        <%=dm.makeCheckBox("cs_benign", " Benign")%>
                        <%=dm.makeCheckBox("cs_other", " Uncertain Significance")%>
                    </td>
                </tr>
                <% } %>

                <tr>
                    <td>&nbsp;</td>
                </tr>

                <% if (currentMap.getSpeciesTypeKey()==SpeciesType.RAT || currentMap.getSpeciesTypeKey()==SpeciesType.DOG) { %>
                <tr>
                    <td   colspan=3 ><div class="typerSubTitle" >Call Statistics</div></td>
                </tr>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Depth of Coverage</td>
                    <% String defaultDepth = "1";

                       if (!dm.out("depthLowBound", req.getParameter("depthLowBound")).equals("")) {
                           defaultDepth = dm.out("depthLowBound",req.getParameter("depthLowBound"));
                       }
                    %>

                    <td> Minimum Reads&nbsp;&nbsp;<input type="text" size=10 name="depthLowBound" value="<%=defaultDepth%>">&nbsp;&nbsp; Maximum Reads&nbsp;&nbsp;<input type="text" size=10 name="depthHighBound" value="<%=dm.out("depthHighBound",req.getParameter("depthHighBound"))%>"></td>
                </tr>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Total Alleles Read</td>
                    <td><%=dm.makeCheckBox("alleleCount1", " 1")%>
                        <%=dm.makeCheckBox("alleleCount2", " 2")%>
                        <%=dm.makeCheckBox("alleleCount3", " 3")%>
                        <%=dm.makeCheckBox("alleleCount4", " 4")%>
                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Zygosity</td><td>
                        <table cellpadding=0 cellspacing=0 border=0>
                            <tr>
                                <td width=200>
                                    <input type="checkbox"  style="border:0px solid black;" name="het" value="true" <% if (req.getParameter("het").equals("true")) out.print("checked"); %>> Heterozygous
                                </td>
                                <td style="font-style:italic;">
                                    2 alleles called between 15% and 85% of reads
                                </td>
                            </tr>
                            <tr>
                                <td>
                                <input type="checkbox" name="hom" style="border:0px solid black;"  value="true" <% if (req.getParameter("hom").equals("true")) out.print("checked"); %>> Homozygous
                                </td>
                                <td style="font-style:italic;">
                                    Variant read in 100% of reads
                                </td>
                            </tr>
                            <tr>
                                <td>
                                <input type="checkbox" name="possiblyHom"  style="border:0px solid black;" value="true" <% if (req.getParameter("possiblyHom").equals("true")) out.print("checked"); %>> Possibly Homozygous
                                </td>
                                <td style="font-style:italic;">
                                    Variants read in 85% to 99% of reads
                                </td>
                            </tr>
                            <tr>
                                <td>
                                <input type="checkbox" style="border:0px solid black;"  name="excludePossibleError" > Exclude Low Read Percentage                                </td>
                                <td style="font-style:italic;">
                                    Variant read in less than 15% of reads
                                </td>
                            </tr>
                        </table>

                     </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td   colspan=3 ><div class="typerSubTitle" >Additional Options</div></td>
                </tr>
                <tr>
                    <td></td>
                    <td class="carpeLabel">Show Differences</td>
                    <td>  <input type="checkbox" style="border:0px solid black;"  name="showDifferences" value="true" <% if (req.getParameter("showDifferences").equals("true")) out.print("checked"); %>> Exclude Common Variants between strains</td>
                </tr>
              <% } //end only show for rat %>

            </table>

            </td>
        <td valign="top" align="left">
            <div style="margin-left:10px;"><input  class="continueButton" type="submit" value="Find Variants"/></div>
        </td>
    </tr>
</table>

    <div style="margin-top:12px; margin-bottom:12px;">
    <table border=0 width="100%" style="border:1px dashed white; padding-bottom:5px;">
        <tr>
         <td style="font-size:11px; color:white;" >
        <%
            if (request.getParameter("sample1")!=null && request.getParameter("sample1").equals("all")) {

                SampleDAO sdao = new SampleDAO();
                sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
                List<Sample> samples = sdao.getSamplesByMapKey(currentMap.getKey());

                int count=1;
                for (Sample s : samples) {
                    String strain = "";
                    if (count > 1) {
                        strain += ",&nbsp;";
                    }

                    strain+= SampleManager.getInstance().getSampleName(s.getId()).getAnalysisName();
            %>
                    <%=strain%>
                    <input type="hidden" name="sample<%=count++%>" value="<%=s.getId()%>"/>
             <%

                }

            } else {

                for (int i=1; i<1000; i++) {
                if (request.getParameter("sample" + i) != null) {
                    String strain = "";
                    if (i > 1) {
                        strain += ",&nbsp;";
                    }

                    strain+= SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName();
            %>
                <%=strain%>
                <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
            <%
                }
              }
            }
        %>
            </td>
        </tr>
    </table>
    </div>


</div>


</form>
<%@ include file="/common/footerarea.jsp" %>