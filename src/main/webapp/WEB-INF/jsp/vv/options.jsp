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
    if(request.getParameter("mapKey")!=null && !request.getParameter("mapKey").isEmpty())
        mapKey=Integer.parseInt(request.getParameter("mapKey"));
    edu.mcw.rgd.datamodel.Map currentMap = MapManager.getInstance().getMap(mapKey);
    VariantSearchBean vsb = (VariantSearchBean) request.getAttribute("vsb");
%>
<%@ include file="/common/headerarea.jsp" %>
<script type="text/javascript" src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
<script type="text/javascript"  src="/solr/OntoSolr/files/jquery.autocomplete.js"></script>
<link rel="stylesheet" href="/solr/OntoSolr/files/jquery.autocomplete.css" type="text/css" />

<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>

<style>
    /* Modern Options Page Styles */
    .options-container {
        max-width: 1000px;
        margin: 20px auto;
        padding: 0 20px;
    }

    .options-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 2px solid #2a5a8a;
    }

    .options-title {
        font-size: 18px;
        font-weight: bold;
        color: white;
    }

    .options-assembly {
        font-size: 14px;
        color: #acd;
    }

    .options-notice {
        background: rgba(255, 193, 7, 0.15);
        border-left: 4px solid #ffc107;
        padding: 12px 15px;
        margin-bottom: 20px;
        border-radius: 0 4px 4px 0;
        color: #ffe082;
        font-size: 13px;
        line-height: 1.5;
    }

    .options-notice strong {
        color: #ffc107;
    }

    .options-instructions {
        background: rgba(42, 90, 138, 0.3);
        border-left: 4px solid #4a9eff;
        padding: 12px 15px;
        margin-bottom: 20px;
        border-radius: 0 4px 4px 0;
        color: #cde;
        font-size: 13px;
        line-height: 1.5;
    }

    .options-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 20px;
    }

    @media (max-width: 800px) {
        .options-grid {
            grid-template-columns: 1fr;
        }
    }

    .options-card {
        background: linear-gradient(to bottom, #1a3a5a 0%, #0d2035 100%);
        border: 1px solid #2a5a8a;
        border-radius: 6px;
        padding: 15px 20px;
    }

    .options-card.full-width {
        grid-column: 1 / -1;
    }

    .card-title {
        font-size: 15px;
        font-weight: bold;
        color: white;
        margin-bottom: 15px;
        padding-bottom: 8px;
        border-bottom: 1px solid #2a5a8a;
    }

    .filter-row {
        display: flex;
        align-items: flex-start;
        margin-bottom: 12px;
    }

    .filter-label {
        min-width: 130px;
        color: #7cb9ff;
        font-size: 13px;
        font-weight: 600;
        padding-top: 2px;
    }

    .filter-options {
        display: flex;
        flex-wrap: wrap;
        gap: 8px 16px;
        color: white;
        font-size: 13px;
    }

    .filter-options label {
        display: flex;
        align-items: center;
        gap: 5px;
        cursor: pointer;
    }

    .filter-options input[type="checkbox"] {
        margin: 0;
    }

    .filter-options input[type="text"] {
        padding: 5px 8px;
        border: 1px solid #456;
        border-radius: 4px;
        background: #0a1520;
        color: white;
        font-size: 13px;
        width: 80px;
    }

    .filter-options input[type="text"]:focus {
        outline: none;
        border-color: #4a9eff;
    }

    .filter-options select {
        padding: 5px 8px;
        border: 1px solid #456;
        border-radius: 4px;
        background: #0a1520;
        color: white;
        font-size: 13px;
    }

    .zygosity-table {
        width: 100%;
    }

    .zygosity-row {
        display: flex;
        align-items: center;
        margin-bottom: 8px;
    }

    .zygosity-label {
        min-width: 180px;
        display: flex;
        align-items: center;
        gap: 5px;
    }

    .zygosity-desc {
        font-style: italic;
        color: #89a;
        font-size: 12px;
    }

    /* Find Variants Button */
    .submit-section {
        display: flex;
        justify-content: center;
        margin: 20px 0;
    }

    .findVariantsButton {
        font-size: 16px;
        font-weight: bold;
        background: linear-gradient(to bottom, #28a745 0%, #1e7e34 100%);
        color: white;
        border: 1px solid #1e7e34;
        border-radius: 6px;
        padding: 12px 40px;
        cursor: pointer;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        transition: all 0.2s ease;
    }

    .findVariantsButton:hover {
        background: linear-gradient(to bottom, #34ce57 0%, #28a745 100%);
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.3);
    }

    /* Strains Card */
    .strains-card {
        background: linear-gradient(to bottom, #1a3a5a 0%, #0d2035 100%);
        border: 1px solid #2a5a8a;
        border-radius: 6px;
        padding: 15px 20px;
    }

    .strains-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 10px;
    }

    .strains-title {
        font-size: 14px;
        font-weight: bold;
        color: white;
    }

    .strains-count {
        font-size: 12px;
        color: #acd;
        background: #2a5a8a;
        padding: 2px 8px;
        border-radius: 10px;
    }

    .strains-list {
        color: #cde;
        font-size: 12px;
        line-height: 1.6;
    }
</style>

<div class="typerMat">
    <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>

    <div class="options-container">
        <!-- Header -->
        <div class="options-header">
            <div class="options-title">Filter Variant Results (Optional)</div>
            <div class="options-assembly"><%=currentMap.getName()%> assembly</div>
        </div>

        <% if( currentMap.getSpeciesTypeKey()!=SpeciesType.HUMAN ) { %>
        <!-- Notice -->
        <div class="options-notice">
            <strong>Notice:</strong> Minimum read depth is now defaulted to 8 and variants found in less than 15% of reads are excluded.
            These defaults can be changed via the form below.
        </div>
        <% } %>

        <!-- Instructions -->
        <div class="options-instructions">
            These filters are <strong>optional</strong>. Leave all options unchecked to include all variants in the defined region.
        </div>

        <form action="variants.html">
            <input type="hidden" name="start" value="<%=dm.out("start",vsb.getStartPosition() + "")%>"/>
            <input type="hidden" name="stop" size="25" value="<%=dm.out("stop",vsb.getStopPosition() + "")%>"/>
            <input type="hidden" name="chr" value="<%=dm.out("chr",vsb.getChromosome())%>"/>
            <input type="hidden" name="geneStart" value="<%=dm.out("geneStart",req.getParameter("geneStart"))%>"/>
            <input type="hidden" name="geneStop" value="<%=dm.out("geneStop",req.getParameter("geneStop"))%>"/>
            <input type="hidden" name="geneList" value="<%=dm.out("geneList",req.getParameter("geneList"))%>" />
            <input type="hidden" name="mapKey" value="<%=dm.out("mapKey",req.getParameter("mapKey"))%>" />

            <div class="options-grid">
                <!-- Genome Card -->
                <div class="options-card">
                    <div class="card-title">Genome</div>

                    <div class="filter-row">
                        <div class="filter-label">Location</div>
                        <div class="filter-options">
                            <label><%=dm.makeCheckBox("intergenic", " Intergenic")%></label>
                            <label><%=dm.makeCheckBox("genic", " Genic")%></label>
                            <label><%=dm.makeCheckBox("nearSpliceSite", " Near Splice Site")%></label>
                            <label><%=dm.makeCheckBox("intron", " Intron")%></label>
                            <label><%=dm.makeCheckBox("3prime", " 3' UTR")%></label>
                            <label><%=dm.makeCheckBox("5prime", " 5' UTR")%></label>
                        </div>
                    </div>

                    <div class="filter-row">
                        <div class="filter-label">Variant Type</div>
                        <div class="filter-options">
                            <label><%=dm.makeCheckBox("snv", " SNV")%></label>
                            <label><%=dm.makeCheckBox("ins", " Insertion")%></label>
                            <label><%=dm.makeCheckBox("del", " Deletion")%></label>
                        </div>
                    </div>

                    <div class="filter-row">
                        <div class="filter-label">Limit to</div>
                        <div class="filter-options">
                            <label><%=dm.makeCheckBox("proteinCoding", " Coding Exon")%></label>
                            <label><%=dm.makeCheckBox("frameshift", " Frameshift")%></label>
                            <label><%=dm.makeCheckBox("prematureStopCodon", " Premature Stop")%></label>
                            <label><%=dm.makeCheckBox("readthroughMutation", " Readthrough")%></label>
                        </div>
                    </div>

                    <%if (!vsb.getConScoreTable().equals("")) {%>
                    <div class="filter-row">
                        <div class="filter-label">Conservation</div>
                        <div class="filter-options">
                            <select name="con">
                                <option value="">Any</option>
                                <option value="n">None (0)</option>
                                <option value="l">Low (.01-.49)</option>
                                <option value="m">Moderate (.5-.749)</option>
                                <option value="h">High (.75-1.0)</option>
                            </select>
                        </div>
                    </div>
                    <%} else {%>
                    <input type="hidden" name="con" value=""/>
                    <% } %>
                </div>

                <!-- Protein Card -->
                <% if( currentMap.getSpeciesTypeKey()==SpeciesType.RAT || currentMap.getSpeciesTypeKey()==SpeciesType.DOG || currentMap.getSpeciesTypeKey()==SpeciesType.HUMAN || currentMap.getSpeciesTypeKey()==SpeciesType.PIG) {%>
                <div class="options-card">
                    <div class="card-title">Protein</div>

                    <% if( currentMap.getSpeciesTypeKey()==SpeciesType.RAT || currentMap.getSpeciesTypeKey()==SpeciesType.DOG || currentMap.getSpeciesTypeKey()==SpeciesType.PIG) { %>
                    <div class="filter-row">
                        <div class="filter-label">Amino Acid Change</div>
                        <div class="filter-options">
                            <label><%=dm.makeCheckBox("synonymous", " Synonymous")%></label>
                            <label><%=dm.makeCheckBox("nonSynonymous", " Non-Synonymous")%></label>
                        </div>
                    </div>
                    <% } %>

                    <% if( currentMap.getSpeciesTypeKey()==SpeciesType.RAT || currentMap.getSpeciesTypeKey()==SpeciesType.DOG) { %>
                    <div class="filter-row">
                        <div class="filter-label">Polyphen Prediction</div>
                        <div class="filter-options">
                            <label><%=dm.makeCheckBox("probably", " Probably Damaging")%></label>
                            <label><%=dm.makeCheckBox("possibly", " Possibly Damaging")%></label>
                            <label><%=dm.makeCheckBox("benign", " Benign")%></label>
                        </div>
                    </div>
                    <% } %>

                    <% if( currentMap.getSpeciesTypeKey()==SpeciesType.HUMAN ) { %>
                    <div class="filter-row">
                        <div class="filter-label">Clinical Significance</div>
                        <div class="filter-options">
                            <label><%=dm.makeCheckBox("cs_pathogenic", " Pathogenic / Likely Pathogenic")%></label>
                            <label><%=dm.makeCheckBox("cs_benign", " Benign")%></label>
                            <label><%=dm.makeCheckBox("cs_other", " Uncertain Significance")%></label>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>

                <% if (currentMap.getSpeciesTypeKey()==SpeciesType.RAT || currentMap.getSpeciesTypeKey()==SpeciesType.DOG) { %>
                <!-- Call Statistics Card -->
                <div class="options-card">
                    <div class="card-title">Call Statistics</div>

                    <% String defaultDepth = "1";
                       if (!dm.out("depthLowBound", req.getParameter("depthLowBound")).equals("")) {
                           defaultDepth = dm.out("depthLowBound",req.getParameter("depthLowBound"));
                       }
                    %>

                    <div class="filter-row">
                        <div class="filter-label">Depth of Coverage</div>
                        <div class="filter-options">
                            Min Reads <input type="text" name="depthLowBound" value="<%=defaultDepth%>"/>
                            &nbsp;&nbsp;Max Reads <input type="text" name="depthHighBound" value="<%=dm.out("depthHighBound",req.getParameter("depthHighBound"))%>"/>
                        </div>
                    </div>

                    <div class="filter-row">
                        <div class="filter-label">Zygosity</div>
                        <div class="filter-options" style="flex-direction: column; gap: 6px;">
                            <div class="zygosity-row">
                                <span class="zygosity-label">
                                    <input type="checkbox" name="het" value="true" <% if (req.getParameter("het").equals("true")) out.print("checked"); %>> Heterozygous
                                </span>
                                <span class="zygosity-desc">2 alleles called between 15% and 85% of reads</span>
                            </div>
                            <div class="zygosity-row">
                                <span class="zygosity-label">
                                    <input type="checkbox" name="hom" value="true" <% if (req.getParameter("hom").equals("true")) out.print("checked"); %>> Homozygous
                                </span>
                                <span class="zygosity-desc">Variant read in 100% of reads</span>
                            </div>
                            <div class="zygosity-row">
                                <span class="zygosity-label">
                                    <input type="checkbox" name="possiblyHom" value="true" <% if (req.getParameter("possiblyHom").equals("true")) out.print("checked"); %>> Possibly Homozygous
                                </span>
                                <span class="zygosity-desc">Variants read in 85% to 99% of reads</span>
                            </div>
                            <div class="zygosity-row">
                                <span class="zygosity-label">
                                    <input type="checkbox" name="excludePossibleError"> Exclude Low Read %
                                </span>
                                <span class="zygosity-desc">Variant read in less than 15% of reads</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Additional Options Card -->
                <div class="options-card">
                    <div class="card-title">Additional Options</div>

                    <div class="filter-row">
                        <div class="filter-label">Show Differences</div>
                        <div class="filter-options">
                            <label>
                                <input type="checkbox" name="showDifferences" value="true" <% if (req.getParameter("showDifferences").equals("true")) out.print("checked"); %>>
                                Exclude Common Variants between strains
                            </label>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Submit Button -->
            <div class="submit-section">
                <input class="findVariantsButton" type="submit" value="Find Variants"/>
            </div>

            <!-- Strains Selected Card -->
            <%
                int strainCount = 0;
                List<String> strainNames = new ArrayList<>();
                if (request.getParameter("sample1")!=null && request.getParameter("sample1").equals("all")) {
                    SampleDAO sdao = new SampleDAO();
                    sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
                    List<Sample> samples = sdao.getSamplesByMapKey(currentMap.getKey());
                    strainCount = samples.size();
                    for (Sample s : samples) {
                        strainNames.add(SampleManager.getInstance().getSampleName(s.getId()).getAnalysisName());
                    }
                } else {
                    for (int i=1; i<1000; i++) {
                        if (request.getParameter("sample" + i) != null) {
                            strainCount++;
                            strainNames.add(SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName());
                        }
                    }
                }
            %>
            <div class="strains-card">
                <div class="strains-header">
                    <div class="strains-title">Strains Selected</div>
                    <div class="strains-count"><%=strainCount%> strain<%= strainCount != 1 ? "s" : "" %></div>
                </div>
                <div class="strains-list">
                    <%
                        if (request.getParameter("sample1")!=null && request.getParameter("sample1").equals("all")) {
                            SampleDAO sdao = new SampleDAO();
                            sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
                            List<Sample> samples = sdao.getSamplesByMapKey(currentMap.getKey());
                            int count=1;
                            boolean first = true;
                            for (Sample s : samples) {
                                if (!first) out.print(", ");
                                first = false;
                                out.print(SampleManager.getInstance().getSampleName(s.getId()).getAnalysisName());
                    %>
                                <input type="hidden" name="sample<%=count++%>" value="<%=s.getId()%>"/>
                    <%
                            }
                        } else {
                            boolean first = true;
                            for (int i=1; i<1000; i++) {
                                if (request.getParameter("sample" + i) != null) {
                                    if (!first) out.print(", ");
                                    first = false;
                                    out.print(SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName());
                    %>
                                <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
                    <%
                                }
                            }
                        }
                    %>
                </div>
            </div>
        </form>
    </div>
</div>
<%@ include file="/common/footerarea.jsp" %>