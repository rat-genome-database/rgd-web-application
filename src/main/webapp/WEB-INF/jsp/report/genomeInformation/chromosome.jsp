<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %><%
    String description = "Genome Information of Various Species";
    String pageTitle = "Genome Information"+ " - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = description;

%>

<%@ include file="/common/headerarea.jsp"%>

<script src="https://d3js.org/d3.v4.min.js"></script>
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
<link href="/rgdweb/css/genomeInformation/genomeInfo.css" type="text/css" rel="stylesheet"/>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<script src="/rgdweb/js/genomeInformation/jbrowseScript.js"></script>
<script src="/rgdweb/js/genomeInformation/d3-tip.js"></script>

<div class="panel panel-default">
     <div class="panel-body" >
         <c:set var="chromosome" value=""/>
         <c:set var="pieData" value=""/>
         <input type="hidden" id="species" value="${model.species}"/>
    <c:forEach items="${model.hits}" var="hits">
    <c:forEach items="${hits}" var="hit">
        <c:set var="chromosome" value="${hit.sourceAsMap.chromosome}"/>
        <c:set var="pieData" value="${hit.sourceAsMap.pieData}"/>
        <input type="hidden" id="mapKey" value="${hit.sourceAsMap.mapKey}"/>

        <input type="hidden" id="chr" value="${hit.sourceAsMap.chromosome}"/>
        <div style="margin-left:70%;"><a href="/rgdweb/report/genomeInformation/genomeInformation.html?species=${model.species}&mapKey=${hit.sourceAsMap.mapKey}" style=";font-weight:bold;color: #24609c" title="click to go to Genome page"><i class="fa fa-arrow-left" aria-hidden="true" style="color:green"></i>&nbsp;Back to ${hit.sourceAsMap.assembly}</a></div>
        <p style="font-size: 25px;font-weight:100;color: #24609c;"><a href="/rgdweb/report/genomeInformation/genomeInformation.html?species=${model.species}&mapKey=${hit.sourceAsMap.mapKey}" style="font-size: 25px;font-weight:100;color: #24609c" title="click to go to Genome page">
        <c:if test="${model.species!='Dog' && model.species!='Bonobo'}">
        ${model.species}</c:if> ${hit.sourceAsMap.assembly}</a>/Chromosome ${hit.sourceAsMap.chromosome}</p>


        <hr>

        <div class="container">

           <table class="borderless genome" style=";width:100%;background-color: #f4f4f4;">
               <tr><td>
               <table>
                <tr><td class="label">Chromosome Assembly</td><td>${hit.sourceAsMap.assembly}</td></tr>
                <tr><td class="label">RefSeq Id</td><td><a href="https://www.ncbi.nlm.nih.gov/nuccore/${hit.sourceAsMap.refseqId}" target="_blank">${hit.sourceAsMap.refseqId} <i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></td></tr>
                <tr><td class="label">Chromosome Sequence Length</td><td>${hit.sourceAsMap.seqLength} bp</td></tr>
                <tr><td class="label">Gap Length</td><td>${hit.sourceAsMap.gapLength}</td></tr>
                <tr><td class="label">Gap Count</td><td>${hit.sourceAsMap.gapCount}</td></tr>
                <tr><td class="label">Contig Count</td><td>${hit.sourceAsMap.contigCount}</td></tr>
               </table>
               </td>

                   <td style="text-align: right;">
         <c:if test="${model.xlinks.ncbiChr!=null ||  model.xlinks.ensembl!=null || model.xlinks.ucsc!=null}">
                           <div style="; width:150px;  border:1px solid gainsboro;margin-left:50%">
            <strong style="padding:10px;color:grey">External Links</strong>

             <ul class="list-group">
                 <c:if test="${model.xlinks.ncbiChr!=null}">
                 <li class="list-group-item list-group-item-success" ><a href="${model.xlinks.ncbiChr}" target="_blank">NCBI</a></li>
                 </c:if>
                 <c:if test="${model.xlinks.ensembl!=null}">
                 <li class="list-group-item list-group-item-success"><a href="${model.xlinks.ensembl}" target="_blank">Ensembl</a></li>
                 </c:if>
                 <c:if test="${model.xlinks.ucsc!=null}">
                 <li class="list-group-item list-group-item-success"><a href="${model.xlinks.ucsc}" target="_blank">UCSC</a></li>
                 </c:if>

             </ul>
         </div>
         </c:if>
                   </td>
               </tr>
            </table>

<hr>

<%--    <div class="panel panel-default" style="height:300px">--%>
<%--        <div class="panel-heading">--%>
<%--            <span style="font-weight:normal">Gene Density Chromosome ${chromosome}</span>--%>
<%--        </div>--%>
<%--        <div class="panel-body" style="overflow-x: scroll">--%>
<%--            <iframe id="jbrowseMini" width="800" height="200px" style="margin-left:10%"></iframe>--%>
<%--        </div>--%>
<%--    </div>--%>

    <div class="panel panel-default"  >
        <div class="panel-heading">
            <span style="font-weight:normal">Gene Counts (Chromosome ${chromosome}) </span>
        </div>
        <div class="panel-body" >
            <div style="width:50%;float:left">
            <table  class="borderless genome" style="width:100%">

                <c:if test="${hit.sourceAsMap.totalGenes!=0}">
                    <tr><td>Total Genes</td><td>${hit.sourceAsMap.totalGenes}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.proteinCoding!=0}">
                    <tr><td>Protein Coding genes</td><td>${hit.sourceAsMap.proteinCoding} </td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.ncrna!=0}">
                    <tr><td>Non coding RNA</td><td>${hit.sourceAsMap.ncrna}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.tRna!=0}">
                    <tr><td>tRNA</td><td>${hit.sourceAsMap.tRna}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.snRna!=0}">
                    <tr><td>SnRNA</td><td>${hit.sourceAsMap.snRna}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.rRna!=0}">
                    <tr><td>rRNA</td><td>${hit.sourceAsMap.rRna}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.pseudo!=0}">
                    <tr><td>Pseudogenes</td><td>${hit.sourceAsMap.pseudo}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.mirnaTargetsConfirmed!=0}">
                    <tr><td>miRNA Targets Confirmed</td><td>${hit.sourceAsMap.mirnaTargetsConfirmed}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.mirnaTargetsPredicted!=0}">
                    <tr><td>miRNA Targets Predicted</td><td>${hit.sourceAsMap.mirnaTargetsPredicted}</td></tr>
                </c:if>

                <c:if test="${hit.sourceAsMap.genesWithoutOrthologs!=0}">
                    <tr><td>Genes without orthologs</td><td>${hit.sourceAsMap.genesWithoutOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.genesWithOrthologs!=0}">
                    <tr><td>Genes with Orthologs</td><td>${hit.sourceAsMap.genesWithOrthologs}</td></tr>
                </c:if>
            </table>

            </div>
            <div class="panel-body" style="width:40%;float:right;" >
                <div  id="chart" style="width:400px; height:200px;margin-left:10%"></div>
            </div>
        </div>
    </div>
    <div class="panel panel-default" style="width:49%;float:left;height:300px" >
        <div class="panel-heading">
            <span style="font-weight:normal">${model.species} Genes with Orthologs in .. (Chromosome ${chromosome}) </span>
        </div>
        <div class="panel-body" >

            <table class="table table-striped table-condensed genome" style="border:1px solid gainsboro;">

                <c:if test="${hit.sourceAsMap.humanOrthologs!=0}">
                    <tr><td>Human</td><td>${hit.sourceAsMap.humanOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.mouseOrthologs!=0}">
                    <tr><td>Mouse</td><td>${hit.sourceAsMap.mouseOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.ratOrthologs!=0}">
                    <tr><td>Rat</td><td>${hit.sourceAsMap.ratOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.chinchillaOrthologs!=0}">
                    <tr><td>Chinchilla</td><td>${hit.sourceAsMap.chinchillaOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.bonoboOrthologs!=0}">
                    <tr><td>Bonobo</td><td>${hit.sourceAsMap.bonoboOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.dogOrthologs!=0}">
                    <tr><td>Dog</td><td>${hit.sourceAsMap.dogOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.squirrelOrthologs!=0}">
                    <tr><td>Squirrel</td><td>${hit.sourceAsMap.squirrelOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.pigOrthologs!=0}">
                    <tr><td>Pig</td><td>${hit.sourceAsMap.pigOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.moleRatOrthologs!=0}">
                    <tr><td>Naked Mole-rat</td><td>${hit.sourceAsMap.moleRatOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.greenMonkeyOrthologs!=0}">
                    <tr><td>Green Monkey</td><td>${hit.sourceAsMap.greenMonkeyOrthologs}</td></tr>
                </c:if>
            </table>

        </div>
    </div>
    <div class="panel panel-default" style="width: 50%;margin-left:50%;height:300px" >
        <div class="panel-heading">
            <span style="font-weight:normal">Other </span>
        </div>
        <div class="panel-body" >

            <table class="table table-striped table-condensed genome" style="border:1px solid gainsboro;">

                <!--c:if test="$-{hit.sourceAsMap.utrs3!=0}">
                    <!--tr><td>3UTRS</td><td>$-{hit.sourceAsMap.utrs3}</td></tr>
                <!--/c:if-->
                <!--c:if test="$-{hit.sourceAsMap.utrs5!=0}">
                    <!--tr><td>5UTRS</td><td>$-{hit.sourceAsMap.utrs5}</td></tr>
                <!--/c:if-->
                <c:if test="${hit.sourceAsMap.exons!=0}">
                    <tr><td>Exons</td><td>${hit.sourceAsMap.exons}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.proteins!=null && hit.sourceAsMap.proteins!=0 }">
                    <tr><td>Proteins</td><td>${hit.sourceAsMap.proteins}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.qtls!=0}">
                    <tr><td>QTLS</td><td>${hit.sourceAsMap.qtls}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.sslps!=0}">
                    <tr><td>SSLPs</td><td>${hit.sourceAsMap.sslps}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.strains!=0}">
                    <tr><td>Strains</td><td>${hit.sourceAsMap.strains}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.variants!=0}">
                    <tr><td>ClinVar Variants</td><td>${hit.sourceAsMap.variants}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.transcripts!=0}">
                    <tr><td>Gene transcripts</td><td>${hit.sourceAsMap.transcripts}</td></tr>
                </c:if>

            </table>


        </div>
    </div>
            <c:if test="${model.species=='Rat'}">
            <div class="panel panel-default"  >
                <div class="panel-heading">
                    <span style="font-weight:normal">Variants (Chromosome ${chromosome}) </span>
                </div>
                <div class="panel-body" >
                    <div style="overflow: scroll">
                        <c:set var="row1" value="true"/>
                        <c:set var="i" value="1"/>
                        <table>
                       <c:forEach items="${hit.sourceAsMap.variantsMatrix}" var="row">
                            <c:if test="${i<=4}">
                               <c:choose>
                                   <c:when test="${row1=='true'}">
                                       <tr>
                                       <th class="rotate"></th>
                                       <c:forEach items="${row}" var="cell">
                                           <th class="rotate"><div><span style="font-size: x-small;font-weight:normal">${cell}</span></div></th>
                                       </c:forEach>
                                       </tr>
                                   </c:when>
                                   <c:otherwise>
                                       <tr class="vcRow">
                                       <c:if test="${i==2}">
                                           <th class="row-header">SNV</th>

                                       </c:if>
                                       <c:if test="${i==3}">
                                           <th class="row-header">Ins</th>

                                       </c:if>
                                       <c:if test="${i==4}">
                                           <th class="row-header">Del</th>

                                       </c:if>
                                       <!--c:if test="$-{i==5}">
                                           <th class="row-header">SNV</th>

                                       <!--/c:if-->

                                       <c:forEach items="${row}" var="cell">
                                           <c:choose>
                                               <c:when test="${cell==null}">
                                                   <td style="text-align: center">-</td>
                                               </c:when>
                                               <c:otherwise>
                                                   <td class="vc" data-original-title="555" data-container="body" data-toggle="tooltip" data-placement="bottom" style="text-align: center;" title=""><span style="font-size: small;font-weight: bold">${cell}</span></td>
                                               </c:otherwise>
                                           </c:choose>

                                       </c:forEach>
                                       </tr>
                                   </c:otherwise>
                               </c:choose>


                           <c:set var="row1" value="false"/>
                           <c:set var="i" value="${i+1}"/>
                            </c:if>
                       </c:forEach>
                        </table>
                    </div>

                </div>

            </div>
            </c:if>
    <div class="panel panel-default"  >
        <div class="panel-heading">
            <span style="font-weight:normal">Disease Gene Sets (Chromosome ${chromosome})</span>
        </div>
        <div class="panel-body" >
            <div class="column" id="diseaseGeneSets" style="width:100%;overflow-x: auto">
                <table class="table  table-condensed table-hover">
                    <tr><th>Disease</th><th>Genes</th></tr>

                    <c:forEach items="${hit.sourceAsMap.diseaseGenes}" var="d">
                        <tr><td><a href="/rgdweb/ontology/annot.html?acc_id=${d.ontTermAccId}&species=${model.species}" title="click to go to disease page"><span class="text-capitalize">${d.ontTerm}</span></a></td><td>${d.geneCount}&nbsp;
                            <a href="diseaseGenes.html?mapKey=${hit.sourceAsMap.mapKey}&chr=${hit.sourceAsMap.chromosome}&accId=${d.ontTermAccId}" title="click to download Genes"><span class="glyphicon glyphicon-cloud-download" style="color:grey;"></span> </a>
                        </td>
                      </tr>
                    </c:forEach>


                </table>
            </div>
            <div style="width:100%;overflow-x: auto">
            <svg width="960" height="500"></svg>
            <script>
                var svg = d3.select("svg"),
                        margin = {top: 20, right: 20, bottom: 30, left: 40},
                        width = 900,
                        height = 300;

                var x = d3.scaleBand().rangeRound([0, width]).padding(0.1),
                        y = d3.scaleLinear().rangeRound([height, 0]);

                var g = svg.append("g")
                        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

                var data=${hit.sourceAsMap.diseaseGenechartData};

                var tip = d3.tip()
                        .attr('class', 'd3-tip')
                        .offset([-10, 0])
                        .html(function(d) {
                            return "<strong>"+d.disease+"</strong><br><span style='color:yellow'>" + d.geneCount + " genes</span>";
                        });

                x.domain(data.map(function(d) { return d.disease; }));
                y.domain([0, d3.max(data, function(d) { return d.geneCount; })]);
                svg.call(tip);
                g.append("g")
                        .attr("class", "axis axis--x")
                        .attr("transform", "translate(0," + height + ")")
                        .call(d3.axisBottom(x))
                        .selectAll("text")
                        .attr("transform", "rotate(90)")
                        .attr("y",0)
                        .attr("x",9)
                        .attr("dy", ".70em")
                        .style("text-anchor","start");

                g.append("g")
                        .attr("class", "axis axis--y")
                        .call(d3.axisLeft(y).ticks(1))
                        .append("text")
                        .attr("transform", "rotate(-90)")
                        .attr("y", 6)
                        .attr("dy", "0.71em")
                        .attr("text-anchor", "end")
                        .text("No. of Genes");

                g.selectAll(".bar")
                        .data(data)
                        .enter().append("rect")
                        .attr("class", "bar")

                        .attr("x", function(d) { return x(d.disease); })
                        .attr("y", function(d) { return y(d.geneCount); })
                        .attr("width", x.bandwidth())
                        .attr("height", function(d) { return height - y(d.geneCount); })
                      //  .attr("fill", "yellow")
                        .on("click", function (d) {
                            alert("DISEASE: " +d.disease + "\nANNOTATED GENE COUNT: " + d.geneCount);
                        })
                        .on("mouseover", tip.show)
                        .on("mouseout", tip.hide)




            </script>
            </div>
        </div>
    </div>

    </c:forEach>
    </c:forEach>
<div class="panel panel-default">
    <div class="panel-heading">
        References
    </div>
    <div class="panel-body" >
        <c:set var="url" value="https://www.ncbi.nlm.nih.gov/pubmed/"/>
        <c:if test="${model.species.equals('Rat') }">
            <ul>
                <li><a href="/rgdweb/report/reference/main.html?id=1303377">Genome sequence of the Brown Norway rat yields insights into mammalian evolution. Nature. 2004 Apr 1;428(6982):493-521. </a>PMID: 15057822&nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/15057822" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></li>
                <li>Integrated and sequence-ordered BAC- and YAC-based physical maps for the rat genome. PMID: 15060021 &nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/15060021" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></li>
                <li>Genomic analysis of the nuclear receptor family: new insights into structure, regulation, and evolution from the rat genome. PMID: 15059999 &nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/15059999" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></li>
                <li>Glass bead purification of plasmid template DNA for high throughput sequencing of mammalian genomes. PMID: 11917038 &nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/11917038" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></li>
            </ul>

        </c:if>
        <c:if test="${model.species.equals('Human') }">
            <ul>
                <c:if test="${hit.sourceAsMap.chromosome=='1'}">

                <li><a href="/rgdweb/report/reference/main.html?id=11058543">The DNA sequence and biological annotation of human chromosome 1. </a> PMID:16710414&nbsp;<a href="${url}16710414" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></li>
                </c:if>
                <li> <a href="/rgdweb/report/reference/main.html?id=11052910">Initial sequencing and analysis of the human genome. Nature. 2001 Feb 15;409(6822):860-921.</a>PMID:11237011<a href="https://www.ncbi.nlm.nih.gov/pubmed/11237011"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></li>
                <li><a href="/rgdweb/report/reference/main.html?id=11054860">The sequence of the human genome.</a></li>
                <li> Integration of cytogenetic landmarks into the draft sequence of the human genome. Nature. 2001 Feb 15;409(6822):953-8. PMID: 11237021&nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/11237021" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a>  </li>

                <li>Kent WJ, Haussler D. Assembly of the working draft of the human genome with gigAssembler. Genome Res. 2001 Sep;11(9)1541-1548. PMID: 11544197&nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/11544197" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></li>
            </ul>

        </c:if>
        <c:if test="${model.species.equals('Mouse') }">
            Mouse Genome Sequencing Consortium. Initial sequencing and comparative analysis of the mouse genome. Nature. 2002 Dec 5;420(6915):520-62.
            PMID: 12466850&nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/12466850" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a>
        </c:if>
        <c:if test="${model.species.equals('Dog') }">
            Lindblad-Toh K, Wade CM, Mikkelsen TS, Karlsson EK, Jaffe DB, Kamal M, Clamp M, Chang JL, Kulbokas EJ 3rd, Zody MC et al. Genome sequence, comparative analysis and haplotype structure of the domestic dog. Nature. 2005 Dec 8;438(7069):803-19.

            PMID: 16341006&nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/16341006" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a>
        </c:if>
        <c:if test="${model.species.equals('Squirrel') }">
            The squirrel sequence has been made freely available as part of the Mammalian Genome Project (29 Mammals Project). The initial analysis of this dataset can be found in Lindblad-Toh K et al. A high-resolution map of human evolutionary constraint using 29 mammals. Nature. 2011 Oct 12;478(7370):476-82. PMID: 21993624&nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/21993624" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a>  ; PMCID: PMC3207357
        </c:if>
        <c:if test="${model.species.equals('Bonobo') }">
            The bonobo sequence is made freely available by the Max-Planck Institute for Evolutionary Anthropology. The initial analysis of this dataset can be found in Prufer K et al. The bonobo genome compared with the chimpanzee and human genomes. Nature. 2012 Jun 28;486(7404):527-31. PMID: 22722832&nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/22722832" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a>
        </c:if>
    </div>
</div>
</div>
     </div>
</div>
<div id="pieChart">
</div>


<script type="">
    (function(d3) {
        'use strict';
        var dataset = ${pieData};
        var width = 250;
        var height = 200;
        var radius = Math.min(width, height) / 2;
        var donutWidth = 50;
        var legendRectSize = 15;
        var legendSpacing = 4;

        var color = d3.scaleOrdinal(d3.schemeCategory20c);

        var svg = d3.select('#chart')
                .append('svg')
                .attr('width', width)
                .attr('height', height)
                .append('g')
                .attr('transform', 'translate(' + (width / 2) +
                        ',' + (height / 2) + ')');

        var arc = d3.arc()
                .innerRadius(radius - donutWidth)
                .outerRadius(radius);

        var pie = d3.pie()
                .value(function(d) { return d.value; })
                .sort(null);

        var tip = d3.tip()
                .attr('class', 'd3-tip')
                .offset([-10, 0])
                .html(function(d) {
                    return "<strong>"+d.data.value+" genes</strong>";
                });
        var path = svg.selectAll('path')
                .data(pie(dataset))
                .enter()
                .append('path')
                .attr('d', arc)
                .attr('fill', function(d, i) {
                    return color(d.data.label);
                });
        path.on('mouseover', tip.show);

        path.on('mouseout', tip.hide);

        path.on('click', function (i) {
            alert(color(i))
        });
        svg.call(tip);
        var legend = svg.selectAll('.legend')
                .data(color.domain())
                .enter()
                .append('g')
                .attr('class', 'legend')
                .attr('transform', function(d, i) {
                    var height = legendRectSize + legendSpacing;
                    var offset =  height * color.domain().length / 2;
                   var horz = -2 * legendRectSize;
                    var vert = i * height - offset;
                    return 'translate(' + horz + ',' + vert + ')';
                });

        legend.append('rect')
                .attr('width', legendRectSize)
                .attr('height', legendRectSize)
                .style('fill', color)
                .style('stroke', color);

        legend.append('text')
                .attr('x', legendRectSize + legendSpacing)
                .attr('y', legendRectSize - legendSpacing)
                .text(function(d) { return d; });
   /*     svg.append('g')
                .attr('class', 'legend')
                .selectAll('text')
                .data(pie(dataset))
                .enter()
                .append('text')
                .text(function (d) {
                    return "*" + d.data.label;
                }).attr('fill', function (d) {return color(d.data.label)

        }).attr('y', function (d, i) {
            return 20*(i+1);
        })*/


    })(window.d3);
</script>




<%@ include file="/common/footerarea.jsp"%>