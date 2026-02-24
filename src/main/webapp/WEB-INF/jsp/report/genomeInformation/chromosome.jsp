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
        <div class="panel-body" style="overflow:hidden">
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
            <div style="width:40%;float:right;" >
                <div  id="chart" style="width:400px; height:200px;margin-left:10%"></div>
            </div>
        </div>
    </div>
    <div style="display:flex;gap:15px;margin-bottom:15px">
    <div class="panel panel-default" style="flex:1;min-width:0;margin-bottom:0" >
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
    <div class="panel panel-default" style="flex:1;min-width:0;margin-bottom:0" >
        <div class="panel-heading">
            <span style="font-weight:normal">Other </span>
        </div>
        <div class="panel-body" >

            <table class="table table-striped table-condensed genome" style="border:1px solid gainsboro;">

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
    </div>
            <c:if test="${model.species=='Rat'}">
            <div class="panel panel-default" style="clear:both" >
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
    <div class="panel panel-default" style="clear:both" >
        <div class="panel-heading">
            <span style="font-weight:normal">Disease Gene Sets (Chromosome ${chromosome})</span>
        </div>
        <div class="panel-body" style="padding:15px">
            <style>
                .dgs-table { width:100%; border-collapse:collapse; margin-bottom:20px; }
                .dgs-table th { background:#f7f9fc; color:#333; font-weight:600; font-size:13px; text-transform:uppercase; letter-spacing:0.5px; padding:10px 12px; border-bottom:2px solid #d0d7e2; text-align:left; }
                .dgs-table td { padding:8px 12px; border-bottom:1px solid #eef1f5; font-size:13px; vertical-align:middle; }
                .dgs-table tr:hover td { background:#f0f5ff; }
                .dgs-table .dgs-disease { color:#24609c; text-decoration:none; font-weight:500; text-transform:capitalize; }
                .dgs-table .dgs-disease:hover { color:#1a4570; text-decoration:underline; }
                .dgs-table .dgs-count { font-weight:600; color:#333; min-width:50px; }
                .dgs-table .dgs-dl { color:#999; font-size:12px; margin-left:6px; transition:color 0.2s; }
                .dgs-table .dgs-dl:hover { color:#24609c; }
                .dgs-chart-wrap { position:relative; width:100%; overflow-x:auto; }
                .dgs-tooltip { position:absolute; pointer-events:none; background:rgba(30,50,80,0.92); color:#fff; padding:8px 12px; border-radius:6px; font-size:12px; line-height:1.4; white-space:nowrap; opacity:0; transition:opacity 0.15s; z-index:10; box-shadow:0 2px 8px rgba(0,0,0,0.2); }
                .dgs-tooltip strong { display:block; font-size:13px; margin-bottom:2px; }
                .dgs-tooltip .dgs-tip-count { color:#7ec8e3; }
            </style>

            <div style="width:100%;overflow-x:auto">
                <table class="dgs-table">
                    <thead><tr><th>Disease</th><th style="width:120px">Genes</th></tr></thead>
                    <tbody>
                    <c:forEach items="${hit.sourceAsMap.diseaseGenes}" var="d">
                        <tr>
                            <td><a class="dgs-disease" href="/rgdweb/ontology/annot.html?acc_id=${d.ontTermAccId}&species=${model.species}" title="View disease annotations">${d.ontTerm}</a></td>
                            <td><span class="dgs-count">${d.geneCount}</span><a class="dgs-dl" href="diseaseGenes.html?mapKey=${hit.sourceAsMap.mapKey}&chr=${hit.sourceAsMap.chromosome}&accId=${d.ontTermAccId}" title="Download gene list"><span class="glyphicon glyphicon-cloud-download"></span></a></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <div class="dgs-chart-wrap" id="dgsChartWrap">
                <div class="dgs-tooltip" id="dgsTooltip"></div>
            </div>

            <script>
            (function() {
                var data = ${hit.sourceAsMap.diseaseGenechartData};
                if (!data || !data.length) return;

                data.sort(function(a, b) { return b.geneCount - a.geneCount; });

                var container = document.getElementById('dgsChartWrap');
                var containerWidth = container.offsetWidth || 800;

                var barHeight = 22;
                var barGap = 4;
                var margin = { top: 30, right: 30, bottom: 40, left: 220 };
                var width = Math.max(containerWidth, 600) - margin.left - margin.right;
                var height = data.length * (barHeight + barGap);
                var svgHeight = height + margin.top + margin.bottom;
                var svgWidth = width + margin.left + margin.right;

                var svg = d3.select('#dgsChartWrap')
                    .append('svg')
                    .attr('width', svgWidth)
                    .attr('height', svgHeight);

                var g = svg.append('g')
                    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

                var maxCount = d3.max(data, function(d) { return d.geneCount; });

                var x = d3.scaleLinear()
                    .domain([0, maxCount])
                    .range([0, width]);

                var y = d3.scaleBand()
                    .domain(data.map(function(d) { return d.disease; }))
                    .range([0, height])
                    .padding(0.15);

                var colorScale = d3.scaleLinear()
                    .domain([0, maxCount * 0.5, maxCount])
                    .range(['#7ec8e3', '#2b7bba', '#1a4570']);

                // gridlines
                g.append('g')
                    .attr('class', 'dgs-grid')
                    .selectAll('line')
                    .data(x.ticks(5))
                    .enter().append('line')
                    .attr('x1', function(d) { return x(d); })
                    .attr('x2', function(d) { return x(d); })
                    .attr('y1', 0)
                    .attr('y2', height)
                    .attr('stroke', '#e8ecf1')
                    .attr('stroke-dasharray', '3,3');

                // x-axis
                g.append('g')
                    .attr('transform', 'translate(0,' + height + ')')
                    .call(d3.axisBottom(x).ticks(5).tickSizeOuter(0))
                    .selectAll('text')
                    .style('font-size', '11px')
                    .style('fill', '#666');

                // x-axis label
                g.append('text')
                    .attr('x', width / 2)
                    .attr('y', height + 32)
                    .attr('text-anchor', 'middle')
                    .style('font-size', '12px')
                    .style('fill', '#888')
                    .text('Number of Annotated Genes');

                // y-axis
                g.append('g')
                    .call(d3.axisLeft(y).tickSizeOuter(0))
                    .selectAll('text')
                    .style('font-size', '11px')
                    .style('fill', '#444')
                    .style('text-transform', 'capitalize')
                    .each(function() {
                        var text = d3.select(this).text();
                        if (text.length > 32) {
                            d3.select(this).text(text.substring(0, 30) + '...');
                        }
                    });

                // remove axis domain lines for cleaner look
                g.selectAll('.domain').attr('stroke', '#ccc');

                var tooltip = document.getElementById('dgsTooltip');

                // bars
                g.selectAll('.dgs-bar')
                    .data(data)
                    .enter().append('rect')
                    .attr('class', 'dgs-bar')
                    .attr('x', 0)
                    .attr('y', function(d) { return y(d.disease); })
                    .attr('width', 0)
                    .attr('height', y.bandwidth())
                    .attr('fill', function(d) { return colorScale(d.geneCount); })
                    .attr('rx', 3)
                    .style('cursor', 'pointer')
                    .on('mouseover', function(d) {
                        d3.select(this).attr('fill', '#e8913a');
                        tooltip.innerHTML = '<strong>' + d.disease + '</strong><span class="dgs-tip-count">' + d.geneCount + ' genes</span>';
                        tooltip.style.opacity = '1';
                    })
                    .on('mousemove', function() {
                        var coords = d3.mouse(container);
                        tooltip.style.left = (coords[0] + 15) + 'px';
                        tooltip.style.top = (coords[1] - 10) + 'px';
                    })
                    .on('mouseout', function(d) {
                        d3.select(this).attr('fill', colorScale(d.geneCount));
                        tooltip.style.opacity = '0';
                    })
                    .transition()
                    .duration(600)
                    .delay(function(d, i) { return i * 30; })
                    .attr('width', function(d) { return x(d.geneCount); });

                // value labels on bars
                g.selectAll('.dgs-label')
                    .data(data)
                    .enter().append('text')
                    .attr('class', 'dgs-label')
                    .attr('x', function(d) { return x(d.geneCount) + 5; })
                    .attr('y', function(d) { return y(d.disease) + y.bandwidth() / 2; })
                    .attr('dy', '0.35em')
                    .style('font-size', '11px')
                    .style('fill', '#666')
                    .style('font-weight', '600')
                    .style('opacity', 0)
                    .text(function(d) { return d.geneCount; })
                    .transition()
                    .duration(400)
                    .delay(function(d, i) { return i * 30 + 400; })
                    .style('opacity', 1);
            })();
            </script>
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




<script>
(function() {
    var cells = document.querySelectorAll('td.vc');
    if (!cells.length) return;

    var values = [];
    cells.forEach(function(cell) {
        var text = cell.textContent.trim().replace(/,/g, '');
        var num = parseFloat(text);
        if (!isNaN(num) && num > 0) values.push(num);
    });
    if (!values.length) return;

    var maxVal = Math.max.apply(null, values);
    var logMax = Math.log1p(maxVal);

    var stops = [
        { pct: 0,    r: 255, g: 255, b: 229 },
        { pct: 0.25, r: 254, g: 217, b: 142 },
        { pct: 0.5,  r: 254, g: 153, b: 41  },
        { pct: 0.75, r: 217, g: 95,  b: 14  },
        { pct: 1,    r: 153, g: 52,  b: 4   }
    ];

    function interpolateColor(t) {
        t = Math.max(0, Math.min(1, t));
        var i;
        for (i = 0; i < stops.length - 1; i++) {
            if (t <= stops[i + 1].pct) break;
        }
        var s0 = stops[i], s1 = stops[i + 1];
        var f = (t - s0.pct) / (s1.pct - s0.pct);
        var r = Math.round(s0.r + f * (s1.r - s0.r));
        var g = Math.round(s0.g + f * (s1.g - s0.g));
        var b = Math.round(s0.b + f * (s1.b - s0.b));
        return 'rgb(' + r + ',' + g + ',' + b + ')';
    }

    function luminance(r, g, b) {
        return 0.299 * r + 0.587 * g + 0.114 * b;
    }

    cells.forEach(function(cell) {
        var text = cell.textContent.trim().replace(/,/g, '');
        var num = parseFloat(text);
        if (isNaN(num) || num === 0) {
            cell.style.backgroundColor = '#f5f5f5';
            cell.style.color = '#999';
            return;
        }
        var t = logMax > 0 ? Math.log1p(num) / logMax : 0;
        var color = interpolateColor(t);
        cell.style.backgroundColor = color;

        var i;
        for (i = 0; i < stops.length - 1; i++) {
            if (t <= stops[i + 1].pct) break;
        }
        var s0 = stops[i], s1 = stops[i + 1];
        var f = (t - s0.pct) / (s1.pct - s0.pct);
        var r = Math.round(s0.r + f * (s1.r - s0.r));
        var g = Math.round(s0.g + f * (s1.g - s0.g));
        var b = Math.round(s0.b + f * (s1.b - s0.b));
        cell.style.color = luminance(r, g, b) > 160 ? '#333' : '#fff';
    });
})();
</script>
<%@ include file="/common/footerarea.jsp"%>