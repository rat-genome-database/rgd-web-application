<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="org.springframework.ui.ModelMap" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="/rgdweb/gviewer/script/gviewer1.js"></script>
<script src="/rgdweb/gviewer/script/util.js"></script>
<script src="/rgdweb/gviewer/script/genomeInformation/event.js"></script>
<script src="/rgdweb/gviewer/script/domain.js"></script>
<script src="/rgdweb/gviewer/script/jkl-parsexml.js"></script>

<script src="/rgdweb/gviewer/script/ZoomPane.js"></script>
<script type="text/javascript"  src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/gviewer/css/gviewer.css" />

<script src="/rgdweb/js/genomeInformation/genomeInfo.js"></script>
<!--id="subHead"-->
<style>
    th.rotate {
        /* Something you can count on */
        height: 140px;
        white-space: nowrap;
    }

    th.rotate > div {
        transform:
            /* Magic Numbers */
                translate(25px, 51px)
                    /* 45 is really 360 - 45 */
                rotate(315deg);
        width: 30px;
    }
    th.rotate > div > span {
        border-bottom: 1px solid #ccc;
        padding: 5px 10px;
    }
    .vcRow{
        padding:5px
    }
    .vc{
        padding:8px 5px;
        text-align:center;
        transition: background-color 0.2s ease;
    }
    .row-header{
        font-size:small;
        font-weight:100;
        padding:5px
    }
</style>
<%
    ModelMap model= (ModelMap) request.getAttribute("model");
    Map map= MapManager.getInstance().getMap((Integer) model.get("mapKey"));
%>

<style>
    .gi-title { color:#24609c; font-size:22px; font-weight:400; margin:0 0 10px 0; }
    .gi-intro { display:flex; align-items:flex-start; gap:20px; margin-bottom:12px; }
    .gi-desc { flex:1; min-width:0; font-size:13px; line-height:1.5; color:#444; }
    .gi-desc p { margin:0 0 6px 0; }
    .gi-desc .gi-lineage { color:#666; font-size:12px; }
    .gi-xlinks { border:1px solid #e0e0e0; border-radius:4px; padding:8px 12px; background:#fafbfc; font-size:13px; flex-shrink:0; white-space:nowrap; }
    .gi-xlinks strong { color:#888; font-size:12px; text-transform:uppercase; letter-spacing:0.3px; display:block; margin-bottom:4px; }
    .gi-xlinks ul { list-style:none; margin:0; padding:0; }
    .gi-xlinks li { padding:2px 0; }
    .gi-xlinks a { color:#24609c; text-decoration:none; }
    .gi-xlinks a:hover { text-decoration:underline; }
</style>
<c:forEach items="${model.hits}" var="hit">
        <h4 class="gi-title">${model.species} Genome Information - ${model.assembly}</h4>
        <div class="gi-intro">
            <div class="gi-desc">
            <c:if test="${model.species=='Rat'}">
                <p>The Norway rat is an important experimental model for many human disease, including arthritis, hypertension, diabetes, and cardiovascular diseases.</p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Myomorpha; Muroidea; Muridae; Murinae; Rattus; Rattus norvegicus.</p>
            </c:if>
            <c:if test="${model.species=='Human'}">
                <p>Human genome projects have generated an unprecedented amount of knowledge about human genetics and health. Study of the human condition is supported by a wealth of genome-scale data that will result in significant medical advances derived from a better understanding human biology.</p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Primates; Haplorrhini; Catarrhini; Hominidae; Homo; Homo sapiens.</p>
            </c:if>
            <c:if test="${model.species=='Mouse'}">
                <p>The laboratory mouse is a major model organism for basic mammalian biology, human disease, and genome evolution, and is extensively used for comparative genome analysis.</p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Myomorpha; Muroidea; Muridae; Murinae; Mus; Mus; Mus musculus.</p>
            </c:if>
            <c:if test="${model.species=='Chinchilla'}">
                <p>The long-tailed chinchilla, a rodent native to the mountains of northern Chile, is the model of choice for the study of the human disease otitis media, infections of the middle ear.</p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Hystricomorpha; Chinchillidae; Chinchilla; Chinchilla lanigera.</p>
            </c:if>
            <c:if test="${model.species=='Squirrel'}">
                <p>The thirteen-lined ground squirrel is a good model system for the study of vision and metabolism. Compared to other rodent genomes, ground squirrel genomes show a slower rate of evolution.</p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Sciuromorpha; Sciuridae; Xerinae; Marmotini; Ictidomys; Ictidomys tridecemlineatus.</p>
            </c:if>
            <c:if test="${model.species=='Dog'}">
                <p>The dog is a useful model organism for medical research due to extensive genetic diversity and morphological variation within the species. Many breeds of dog are particularly susceptible to inherited diseases that are also common in humans, such as cancer, heart disease, rheumatoid arthritis, autoimmune disorders, deafness, and blindness.</p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Laurasiatheria; Carnivora; Caniformia; Canidae; Canis; Canis lupus; Canis lupus familiaris.</p>
            </c:if>
            <c:if test="${model.species=='Bonobo'}">
                <p>Although the bonobo, or pygmy chimpanzee, Pan paniscus and common chimpanzee Pan troglodytes are morphologically similar, studies have found that more than three per cent of the human genome is more closely related to either the bonobo or the chimpanzee genome than these are to each other.</p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Primates; Haplorrhini; Catarrhini; Hominidae; Pan; Pan paniscus.</p>
            </c:if>
            <c:if test="${model.species=='Pig'}">
                <p>The pig (Sus scrofa) is a member of the artiodactyls, or cloven-hoofed mammals, which are an evolutionary clade distinct from the primates and rodents. Pigs exist in both feral and domesticated populations that have distinct phenotypes and karyotypes. The haploid genome of the domesticated pig is estimated to be 2800 Mb. The diploid genome is organized in 18 pairs of autosomes and two sex chromosomes. Sus scrofa is an important model organism for health research due to parallels with humans. Swine are omnivores and their digestive physiology is similar to humans. Similarities between humans and pigs also exist in renal function, vascular structure, and respiratory rates. Pigs are used as model organism in many areas of medical research including obesity, cardiovascular disease, endocrinology, alcoholism, diabetes, nephropathy, and organ transplantation. Pigs are also agriculturally important, as pork is a leading source of protein worldwide.</p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Laurasiatheria; Cetartiodactyla; Suina; Suidae; Sus; Sus scrofa</p>
            </c:if>
            <c:if test="${model.species=='Green Monkey'}">
                <p>The green monkey or vervet (Chlorocebus sabaeus) is native to West Africa and was introduced to the Caribbean islands in the 1600s. The term "vervet" is often applied to any of the species in the genus Chlorocebus <span class="more">as they were formerly treated as subspecies of the vervet (Chlorocebus aethiops). For example, the green monkey was formerly classified as Chlorocebus aethiops sabaeus. Green monkeys, and vervets in general, are commonly used in biomedical research as models for the study of neurodegeneration, diabetes and other metabolic syndromes, HIV transmission, and AIDS. Green monkeys are a natural host of the simian immunodeficiency virus (SIV) but, when infected, do not develop AIDS-like symptoms despite having a high viral load. The human immunodeficiency virus (HIV) likely evolved from SIV.</span><a href="#" class="moreLink" title="Click to see more">More...</a></p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Primates; Haplorrhini; Catarrhini; Cercopithecidae; Cercopithecinae; Chlorocebus; Chlorocebus sabaeus</p>
            </c:if>
            <c:if test="${model.species=='Naked Mole-rat'}">
                <p>The naked mole-rat is a hairless rodent native to tropical grasslands of East Africa. It is the longest-lived rodent with a lifespan exceeding thirty years. Naked mole-rats are eusocial organisms, <span class="more">resistant to a variety of cancers, insensitive to certain types of pain, and adapted to life in harsh locales, including low oxygen and high carbon dioxide environments. They do not regulate body temperature, which conforms to ambient temperature.</span><a href="#" class="moreLink" title="Click to see more">More...</a></p>
                <p class="gi-lineage"><strong>Lineage:</strong> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Hystricomorpha; Bathyergidae; Heterocephalus; Heterocephalus glaber</p>
            </c:if>
            </div>
        <c:if test="${model.xlinks.ncbiGenome!=null || model.xlinks.ncbiAssembly!=null || model.xlinks.ensembl!=null || model.xlinks.ucsc!=null}">
            <div class="gi-xlinks">
                <strong>External Links</strong>
                <ul>
                <c:if test="${model.mapKey==360 || model.mapKey==38 || model.mapKey==35 || model.mapKey==720 || model.mapKey==44 || model.mapKey==631 || model.mapKey==511 || model.mapKey==372}">
                    <c:if test="${model.xlinks.ncbiGenome!=null}">
                        <li><a href="${model.xlinks.ncbiGenome}" target="_blank">NCBI Genome <i class="fa fa-external-link" style="font-size:10px"></i></a></li>
                    </c:if>
                </c:if>
                <c:if test="${model.xlinks.ncbiAssembly!=null}">
                    <li><a href="${model.xlinks.ncbiAssembly}" target="_blank">NCBI Assembly <i class="fa fa-external-link" style="font-size:10px"></i></a></li>
                </c:if>
                <c:if test="${model.xlinks.ensembl!=null}">
                    <li><a href="${model.xlinks.ensembl}" target="_blank">Ensembl <i class="fa fa-external-link" style="font-size:10px"></i></a></li>
                </c:if>
                <c:if test="${model.xlinks.ucsc!=null}">
                    <li><a href="${model.xlinks.ucsc}" target="_blank">UCSC <i class="fa fa-external-link" style="font-size:10px"></i></a></li>
                </c:if>
                </ul>
            </div>
        </c:if>
        </div>

        <div class="container" style="padding:0">
        <div style="overflow:hidden">

        <div style="float:left;width:40%">
            <h4>Summary</h4>
            <table class="table table-striped" style="border:1px solid gainsboro;">


                <tr><td>Assembly</td><td>${model.assembly}<br><a href="${hit.sourceAsMap.ncbiLink}" target="_blank">${hit.sourceAsMap.refSeqAssemblyAccession} <i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></td></tr>
                <!--tr><td>Base Pairs</td><td>$-{hit.sourceAsMap.basePairs}</td></tr-->
                <tr><td>Total Sequence Length (bp)</td><td>${hit.sourceAsMap.totalSeqLength}</td></tr>
                <tr><td>Total Ungapped Length (bp)</td><td>${hit.sourceAsMap.totalUngappedLength}</td></tr>
                <tr><td>Gaps Between Scaffolds (bp)</td><td>${hit.sourceAsMap.gapBetweenScaffolds}</td></tr>
                <tr><td>Number of Scaffolds</td><td>${hit.sourceAsMap.scaffolds}</td></tr>
                <tr><td>Scaffold N50 (bp)</td><td>${hit.sourceAsMap.scaffoldN50}</td></tr>
                <tr><td>Scaffold L50</td><td>${hit.sourceAsMap.scaffoldL50}</td></tr>
                <tr><td>Number of Contigs</td><td>${hit.sourceAsMap.contigs}</td></tr>
                <tr><td>Contig N50 (bp)</td><td>${hit.sourceAsMap.contigN50}</td></tr>
                <tr><td>Contig L50</td><td>${hit.sourceAsMap.contigL50}</td></tr>
                <tr><td>No. of NCBI chromosome records</td><td>${hit.sourceAsMap.chromosomes}</td></tr>
            </table>
            <h4>Gene Counts</h4>
            <table class="table table-striped" style="border:1px solid gainsboro;">

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
                <c:if test="${hit.sourceAsMap.transcripts!=0}">
                <tr><td>Gene transcripts</td><td>${hit.sourceAsMap.transcripts}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.genesWithoutOrthologs!=0}">
                <tr><td>Genes without orthologs</td><td>${hit.sourceAsMap.genesWithoutOrthologs}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.genesWithOrthologs!=0}">
                <tr><td>Genes with Orthologs</td><td>${hit.sourceAsMap.genesWithOrthologs}</td></tr>
                </c:if>
            </table>
            <h4>#${model.species} Genes with Orthologs in...</h4>
                <table class="table table-striped" style="border:1px solid gainsboro;">

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
            <h4>Other</h4>
            <table class="table table-striped" style="border:1px solid gainsboro;">

                <c:if test="${hit.sourceAsMap.exons!=0}">
                    <tr><td>Exons</td><td>${hit.sourceAsMap.exons}</td></tr>
                </c:if>
                <c:if test="${hit.sourceAsMap.proteins!=0 && hit.sourceAsMap.proteins!=null}">
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


            </table>

        </div>
        <div style="margin-left:41%;">
            <c:choose>

                <c:when test="${!model.species.equals('Squirrel') && !model.species.equals('Chinchilla') && !model.species.equals('Naked Mole-Rat') && !model.species.equals('Green Monkey')}">
                    <div class="panel panel-default" style=";">
                    <div class="panel-heading">
                        <strong>Karyotype ${model.species}</strong>
                    </div>
                    <div class="panel-body">
                        <!--iframe id="jbrowseMini"  style="border: 1px solid black" width="100%"></iframe-->
                        <%
                            String ucscAssemblyId="";
                            if(map!=null && map.getUcscAssemblyId()!=null){
                                ucscAssemblyId+=map.getUcscAssemblyId();
                            }
                        %>

                        <input type="hidden" id="assemblyId" value="<%=ucscAssemblyId%>">
                        <div id="content" style="width: 100%;overflow-x: scroll ">

                            <table  cellpadding=0 cellspacing=0 align="center" border="0" width="100%">
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                    <td align="center"><div id="gviewer" class="gviewer"></div><div id="zoomWrapper" class="zoom-pane"></div></td>
                                </tr>

                            </table>

                        </div>
                    </div>
                        </div>
                </c:when>
                  <c:otherwise>
<%--            <div class="panel panel-default" style=";height:300px;">--%>
<%--                      <div class="panel-heading">--%>
<%--                          <strong>JBrowse</strong>--%>
<%--                      </div>--%>
<%--                      <div class="panel-body">--%>
<%--                          <!--iframe id="jbrowseMini"  style="border: 1px solid black" width="100%"></iframe-->--%>

<%--                          <div  style="width: 100%;overflow-x: scroll ">--%>

<%--                              <iframe id="jbrowseMini" width="600" height="200px"></iframe>--%>

<%--                          </div>--%>
<%--                      </div>--%>
<%--            </div>--%>
                  </c:otherwise>
            </c:choose>
            <div style="">
                <div class="panel panel-default" >
                    <div class="panel-heading">
                        <strong>Chromosomes</strong>
                    </div>
                    <div class="panel-body" >
                        <div style="height:850px;overflow: scroll">
                            <table class="table table-stripped">
                                <thead>
                                <tr><td>Chromosome</td><td>Sequence Length</td><td>Gap Length</td>,<td>Gap Count</td><td>Contig Count</td><td>RefSeq Id</td></tr>
                                </thead>
                                <c:forEach items="${model.chromosomes}" var="chr">
                                    <tr>
                                        <td>
                                            <c:choose>
                                                <c:when test="${chr.mapKey!=720 && chr.mapKey!=44}">
                                            <a href="chromosome.html?chr=${chr.chromosome}&mapKey=${chr.mapKey}&locus=${chr.refseqId}" title="Click to see Chromosome Report">${chr.chromosome}</a>
                                                </c:when>
                                                <c:otherwise>
                                                    ${chr.chromosome}
                                                </c:otherwise>
                                            </c:choose>

                                        </td>
                                        <td>${chr.seqLength}</td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${chr.gapLength==0}">
                                                    -
                                                </c:when>
                                                <c:otherwise>
                                                    ${chr.gapLength}
                                                </c:otherwise>
                                            </c:choose>

                                        </td>


                                        <td>
                                            <c:choose>
                                                <c:when test="${chr.gapCount==0}">
                                                    -
                                                </c:when>
                                                <c:otherwise>
                                                    ${chr.gapCount}
                                                </c:otherwise>
                                            </c:choose>

                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${chr.contigCount==0}">
                                                  1
                                                </c:when>
                                                <c:otherwise>
                                                    ${chr.contigCount}
                                                </c:otherwise>
                                            </c:choose>

                                        </td>

                                        <td><a href="https://www.ncbi.nlm.nih.gov/nuccore/${chr.refseqId}" title="Click to go NCBI Chromosome Page" target="_blank">${chr.refseqId}</a></td>
                                    </tr>
                                </c:forEach>
                            </table>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <c:if test="${model.mapKey==360 || model.mapKey==60 || model.mapKey==70 ||model.mapKey==372}">

            <div class="panel panel-default" style="clear:both" >
                <div class="panel-heading">
                    <span style="font-weight:bold">Variants</span>
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

                                            <c:forEach items="${row}" var="cell">
                                                <c:choose>
                                                    <c:when test="${cell==null}">
                                                        <td style="text-align: center">-</td>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <td class="vc" title="${cell}"><span style="font-size: small;font-weight: bold">${cell}</span></td>
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

        <div style="clear:both">
            <div class="panel panel-default" >
                <div class="panel-heading">
                    <strong>References</strong>
                </div>
                <div class="panel-body" >
                    <div style="overflow: scroll">
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
                                <li> <a href="/rgdweb/report/reference/main.html?id=11052910">Initial sequencing and analysis of the human genome. Nature. 2001 Feb 15;409(6822):860-921.</a>PMID:11237011<a href="https://www.ncbi.nlm.nih.gov/pubmed/11237011"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a></li>
                                <li><a href="/rgdweb/report/reference/main.html?id=11054860">The sequence of the human genome.</a></li>
                                <li> Integration of cytogenetic landmarks into the draft sequence of the human genome. Nature. 2001 Feb 15;409(6822):953-8. 11237021&nbsp;<a href="https://www.ncbi.nlm.nih.gov/pubmed/11237021" target="_blank"><i class="fa fa-external-link" aria-hidden="true" style="color:dodgerblue;font-weight: bold"></i></a>  </li>

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
        </div>

        </c:forEach>



<script>
$(document).ready(function() {
    var cells = document.querySelectorAll('td.vc');
    if (cells.length === 0) return;

    // Parse numeric values from cells (handle commas in numbers)
    var values = [];
    cells.forEach(function(cell) {
        var text = cell.textContent.trim().replace(/,/g, '');
        var num = parseFloat(text);
        if (!isNaN(num) && num > 0) values.push(num);
    });

    if (values.length === 0) return;

    var maxVal = Math.max.apply(null, values);
    var minVal = Math.min.apply(null, values);

    // Use log scale for better distribution across large ranges
    var logMax = Math.log1p(maxVal);
    var logMin = Math.log1p(minVal);
    var logRange = logMax - logMin || 1;

    // Heatmap color stops: light yellow -> orange -> dark red
    var colorStops = [
        { r: 255, g: 255, b: 229 },  // #ffffe5  (low)
        { r: 254, g: 217, b: 142 },  // #fed98e
        { r: 254, g: 153, b: 41  },  // #fe9929
        { r: 217, g: 95,  b: 14  },  // #d95f0e
        { r: 153, g: 52,  b: 4   }   // #993404  (high)
    ];

    function interpolateColor(t) {
        // t is 0..1, map to color stops
        var seg = t * (colorStops.length - 1);
        var i = Math.floor(seg);
        var f = seg - i;
        if (i >= colorStops.length - 1) { i = colorStops.length - 2; f = 1; }
        var c0 = colorStops[i], c1 = colorStops[i + 1];
        return 'rgb(' +
            Math.round(c0.r + (c1.r - c0.r) * f) + ',' +
            Math.round(c0.g + (c1.g - c0.g) * f) + ',' +
            Math.round(c0.b + (c1.b - c0.b) * f) + ')';
    }

    cells.forEach(function(cell) {
        var text = cell.textContent.trim().replace(/,/g, '');
        var num = parseFloat(text);
        if (isNaN(num) || num === 0) {
            cell.style.backgroundColor = '#f5f5f5';
            cell.style.color = '#999';
        } else {
            var t = (logMax === logMin) ? 0.5 : (Math.log1p(num) - logMin) / logRange;
            cell.style.backgroundColor = interpolateColor(t);
            // Dark text for light cells, white text for dark cells
            cell.style.color = (t > 0.6) ? '#fff' : '#333';
        }
    });
});
</script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
<script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>