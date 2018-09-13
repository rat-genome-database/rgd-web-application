<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="genomeInfoHeader.jsp"/>
<script type="text/javascript"  src="/rgdweb/js/jquery/jquery-1.7.1.min.js"></script>
<script src="/rgdweb/js/genomeInformation/genomeHome.js"></script>

<div class="container">

    <div id="wrapper" style="border-color: white">
    <c:forEach items="${model.hits}" var="hits">

        <c:forEach items="${hits}" var="hit">

                <c:if test="${hit.source.primaryAssembly=='Y'}">
               <div class="panel panel-default ${hit.source.species}" id="${hit.source.species}">
                       <div class="panel-heading" style="background-color: #24609c">
                           <!--div class="panel-heading" style="background-color: #6FB98F"-->
                           <a href="genomeInformation.html?species=${hit.source.species}&mapKey=${hit.source.mapKey}&details=true" id="headerLink${hit.source.species}" title="click to see more info and other assemblies"><strong style="margin-left:40%;color:white">${hit.source.species}</strong></a>
                       </div>
                       <div class="panel-body"  style="height:360px;overflow:auto">
                           <c:if test="${hit.source.species=='Rat'}">
                           <div><p><small>The Norway rat is an important experimental model for many human disease, including arthritis, hypertension, diabetes, and cardiovascular diseases.</small></p>
                           <p><strong>Lineage: </strong><small>Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Myomorpha; Muroidea; Muridae; Murinae; Rattus; Rattus norvegicus.</small></p></div>
                           </c:if>
                           <c:if test="${hit.source.species=='Human'}">
                               <div><p><small>Human genome projects have generated an unprecedented amount of knowledge about human genetics and health. Study of the human condition is <span class="more"> supported by a wealth of genome-scale data that will result in significant medical advances derived from a better understanding human biology.</span><a href="#" class="moreLink" title="Click to see more" >More...</a>
                                   .</small></p>
                                   <p><strong>Lineage: </strong><small>Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Primates[28]; Haplorrhini; Catarrhini; Hominidae; Homo; Homo sapiens.</small></p></div>
                           </c:if>
                           <c:if test="${hit.source.species=='Mouse'}">
                               <div><p><small>The laboratory mouse is a major model organism for basic mammalian biology, human disease, and genome evolution, and is extensively used for comparative genome analysis.
                                   .</small></p>
                                   <p><strong>Lineage: </strong><small> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Myomorpha; Muroidea; Muridae; Murinae; Mus; Mus; Mus musculus.</small></p></div>
                           </c:if>
                           <c:if test="${hit.source.species=='Chinchilla'}">
                               <div><p><small>The long-tailed chinchilla, a rodent native to the mountains of northern Chile, is the model of choice for the study of the human disease otitis media, infections of the middle ear.</small></p>
                                   <p><strong>Lineage: </strong><small> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Hystricomorpha; Chinchillidae; Chinchilla; Chinchilla lanigera.  </small>  </p>
                               </div>
                               </c:if>
                           <c:if test="${hit.source.species=='Squirrel'}">
                               <div><p><small>The thirteen-lined ground squirrel is a good model system for the study of vision and metabolism. Compared to other rodent genomes, <span class="more">ground squirrel genomes show a slower rate of evolution.</span><a href="#" class="moreLink" title="Click to see more">More...</a>
                                   </small></p>
                                   <p><strong>Lineage: </strong><small>  Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Sciuromorpha; Sciuridae; Xerinae; Marmotini; Ictidomys; Ictidomys tridecemlineatus.  </small>  </p>
                               </div>
                           </c:if>


                           <c:if test="${hit.source.species=='Dog'}">
                               <div><p><small>The dog is a useful model organism for medical research due to extensive genetic diversity and morphological variation within the species. <span class="more"> Many breeds of dog are particularly susceptible to inherited diseases that are also common in humans, such as cancer, heart disease, rheumatoid arthritis, autoimmune disorders, deafness, and blindness.</span><a href="#" class="moreLink" title="Click to see more">More...</a>
                                   </small></p>
                                   <p><strong>Lineage: </strong><small> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Laurasiatheria; Carnivora; Caniformia; Canidae; Canis; Canis lupus; Canis lupus familiaris.  </small>  </p>
                               </div>
                           </c:if>

                           <c:if test="${hit.source.species=='Bonobo'}">
                               <div><p><small>Although the bonobo, or pygmy chimpanzee, Pan paniscus and common chimpanzee Pan troglodytes are morphologically similar, <span class="more">studies have found that more than three per cent of the human genome is more closely related to either the bonobo or the chimpanzee genome than these are to each other.</span><a href="#" class="moreLink" title="Click to see more">More...</a>
                                   </small></p>
                                   <p><strong>Lineage: </strong><small>  Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Primates; Haplorrhini; Catarrhini; Hominidae; Pan; Pan paniscus.  </small>  </p>
                               </div>
                           </c:if>
                           <div>
                             <table class="table table-striped"> <tr><td>
                                <label>Assembly:
                                   <select class="${hit.source.species}Assembly">
                                        <c:forEach items="${model.assemblyListsMap}" var="entry">
                                            <c:if test="${entry.key.equalsIgnoreCase(hit.source.species)}">
                                                <c:forEach items="${entry.value}" var="e">
                                                    <c:if test="${e.key!=6 && e.key!=36 && e.key!=8 && e.key!=21 && e.key!=19 && e.key!=7}">
                                                    <option value="${e.key}">${e.name}</option>
                                               </c:if>
                                                </c:forEach>

                                            </c:if>
                                           </c:forEach>

                                   </select>
                                 </label>

                               </td></tr>
                             </table>
                           </div>
                        <div class="${hit.source.species}Class">

                           <table class="table table-striped">
                               <tr><td colspan="2" style="text-align: center">
                                   <!--form action="genomeInformation.html">
                                       <input type="hidden" name=species value="$--{hit.source.species}"/>
                                   <button type="submit">More</button>
                                   </form-->
                                   <a href="genomeInformation.html?species=${hit.source.species}&mapKey=${hit.source.mapKey}&details=true" title="click to see more info and other assemblies"><strong>More Details..</strong></a>
                               </td></tr>
                               <tr><td>Total Seq Length</td><td>${hit.source.totalLength}</td></tr>
                               <tr><td>Chromosomes</td><td>${hit.source.chromosomes}</td></tr>
                               <tr><td>Genes</td><td>${hit.source.totalGenes}</td></tr>

                           </table>
</div>
                       </div>
                   </div>
                </c:if>
    </c:forEach>

    </c:forEach>

</div>
</div>
</div>
<jsp:include page="genomeInfoFooter.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
<script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>