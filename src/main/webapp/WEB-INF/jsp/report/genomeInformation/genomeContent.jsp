<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="card">
    <div class="card-title" style="background-color: #24609c">
        <!--div class="panel-heading" style="background-color: #6FB98F"-->
        <a href="genomeInformation.html?species=${hit.sourceAsMap.species}&mapKey=${hit.sourceAsMap.mapKey}&details=true" id="headerLink${hit.sourceAsMap.species}" title="click to see more info and other assemblies"><strong style="margin-left:40%;color:white">${hit.sourceAsMap.species}</strong></a>
    </div>
    <div class="card-text" >
        <c:if test="${hit.sourceAsMap.species=='Rat'}">
            <div><p><small>The Norway rat is an important experimental model for many human disease, including arthritis, hypertension, diabetes, and cardiovascular diseases.</small></p>
                <p><strong>Lineage: </strong><small>Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Myomorpha; Muroidea; Muridae; Murinae; Rattus; Rattus norvegicus.</small></p></div>
        </c:if>
        <c:if test="${hit.sourceAsMap.species=='Human'}">
            <div><p><small>Human genome projects have generated an unprecedented amount of knowledge about human genetics and health. Study of the human condition is <span class="more"> supported by a wealth of genome-scale data that will result in significant medical advances derived from a better understanding human biology.</span><a href="#" class="moreLink" title="Click to see more" >More...</a>
                .</small></p>
                <p><strong>Lineage: </strong><small>Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Primates[28]; Haplorrhini; Catarrhini; Hominidae; Homo; Homo sapiens.</small></p></div>
        </c:if>
        <c:if test="${hit.sourceAsMap.species=='Mouse'}">
            <div><p><small>The laboratory mouse is a major model organism for basic mammalian biology, human disease, and genome evolution, and is extensively used for comparative genome analysis.
                .</small></p>
                <p><strong>Lineage: </strong><small> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Myomorpha; Muroidea; Muridae; Murinae; Mus; Mus; Mus musculus.</small></p></div>
        </c:if>
        <c:if test="${hit.sourceAsMap.species=='Chinchilla'}">
            <div><p><small>The long-tailed chinchilla, a rodent native to the mountains of northern Chile, is the model of choice for the study of the human disease otitis media, infections of the middle ear.</small></p>
                <p><strong>Lineage: </strong><small> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Hystricomorpha; Chinchillidae; Chinchilla; Chinchilla lanigera.  </small>  </p>
            </div>
        </c:if>
        <c:if test="${hit.sourceAsMap.species=='Squirrel'}">
            <div><p><small>The thirteen-lined ground squirrel is a good model system for the study of vision and metabolism. Compared to other rodent genomes, <span class="more">ground squirrel genomes show a slower rate of evolution.</span><a href="#" class="moreLink" title="Click to see more">More...</a>
            </small></p>
                <p><strong>Lineage: </strong><small>  Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Glires; Rodentia; Sciuromorpha; Sciuridae; Xerinae; Marmotini; Ictidomys; Ictidomys tridecemlineatus.  </small>  </p>
            </div>
        </c:if>


        <c:if test="${hit.sourceAsMap.species=='Dog'}">
            <div><p><small>The dog is a useful model organism for medical research due to extensive genetic diversity and morphological variation within the species. <span class="more"> Many breeds of dog are particularly susceptible to inherited diseases that are also common in humans, such as cancer, heart disease, rheumatoid arthritis, autoimmune disorders, deafness, and blindness.</span><a href="#" class="moreLink" title="Click to see more">More...</a>
            </small></p>
                <p><strong>Lineage: </strong><small> Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Laurasiatheria; Carnivora; Caniformia; Canidae; Canis; Canis lupus; Canis lupus familiaris.  </small>  </p>
            </div>
        </c:if>

        <c:if test="${hit.sourceAsMap.species=='Bonobo'}">
            <div><p><small>Although the bonobo, or pygmy chimpanzee, Pan paniscus and common chimpanzee Pan troglodytes are morphologically similar, <span class="more">studies have found that more than three per cent of the human genome is more closely related to either the bonobo or the chimpanzee genome than these are to each other.</span><a href="#" class="moreLink" title="Click to see more">More...</a>
            </small></p>
                <p><strong>Lineage: </strong><small>  Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Primates; Haplorrhini; Catarrhini; Hominidae; Pan; Pan paniscus.  </small>  </p>
            </div>
        </c:if>
        <c:if test="${hit.sourceAsMap.species=='Pig'}">
            <div><p><small>The pig (Sus scrofa) is a member of the artiodactyls, or cloven-hoofed mammals, which are an evolutionary clade distinct from the primates and rodents. <span class="more"> Pigs exist in both feral and domesticated populations that have distinct phenotypes and karyotypes. The haploid genome of the domesticated pig is estimated to be 2800 Mb. The diploid genome is organized in 18 pairs of autosomes and two sex chromosomes.Sus scrofa is an important model organism for health research due to parallels with humans. Swine are omnivores and their digestive physiology is similar to humans. Similarities between humans and pigs also exist in renal function, vascular structure, and respiratory rates. Pigs are used as model organism in many areas of medical research including obesity, cardiovascular disease, endocrinology, alcoholism, diabetes, nephropathy, and organ transplantation. Pigs are also agriculturally important, as pork is a leading source of protein worldwide.</span><a href="#" class="moreLink" title="Click to see more">More...</a>
            </small></p>
                <p><strong>Lineage: </strong><small>  Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Laurasiatheria; Cetartiodactyla; Suina; Suidae; Sus; Sus scrofa  </small>  </p>
            </div>
        </c:if>
        <c:if test="${hit.sourceAsMap.species=='Green Monkey'}">
            <div><p><small>The green monkey or vervet (Chlorocebus sabaeus) is native to West Africa and was introduced to the Caribbean islands in the 1600s. The term "vervet" is often applied to any of the species in the genus Chlorocebus <span class="more">as they were formerly treated as subspecies of the vervet (Chlorocebus aethiops). For example, the green monkey was formerly classified as Chlorocebus aethiops sabaeus. Green monkeys, and vervets in general, are commonly used in biomedical research as models for the study of neurodegeneration, diabetes and other metabolic syndromes, HIV transmission, and AIDS. Green monkeys are a natural host of the simian immunodeficiency virus (SIV) but, when infected, do not develop AIDS-like symptoms despite having a high viral load. The human immunodeficiency virus (HIV) likely evolved from SIV .</span><a href="#" class="moreLink" title="Click to see more">More...</a>
            </small></p>
                <p><strong>Lineage: </strong><small>Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires; Primates; Haplorrhini; Catarrhini; Cercopithecidae; Cercopithecinae; Chlorocebus; Chlorocebus sabaeus</small>  </p>
            </div>
        </c:if>
        <c:if test="${hit.sourceAsMap.species=='Naked Mole-rat'}">
            <div><p><small>The naked mole-rat is a hairless rodent native to tropical grasslands of East Africa. It is the longest-lived rodent with a lifespan exceeding thirty years. Naked mole-rats are eusocial organisms, <span class="more"> resistant to a variety of cancers, insensitive to certain types of pain, and adapted to life in harsh locales, including low oxygen and high carbon dioxide environments. They do not regulate body temperature, which conforms to ambient temperature.
               </span><a href="#" class="moreLink" title="Click to see more">More...</a>
            </small></p>
                <p><strong>Lineage: </strong><small>  Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia; Eutheria; Euarchontoglires[170]; Glires; Rodentia; Hystricomorpha; Bathyergidae; Heterocephalus; Heterocephalus glaber </small>  </p>
            </div>
        </c:if>
        <div>
            <table class="table table-striped"> <tr><td>
                <label>Assembly:
                    <select class="${fn:replace(hit.sourceAsMap.species," ", "")}Assembly">
                        <c:forEach items="${model.assemblyListsMap}" var="entry">
                            <c:if test="${entry.key.equalsIgnoreCase(hit.sourceAsMap.species)}">
                                <c:forEach items="${entry.value}" var="e">
                                    <c:if test="${e.key!=6 && e.key!=36 && e.key!=8 && e.key!=21 && e.key!=19 && e.key!=7}">
                                        <c:choose>
                                            <c:when test="${e.key==hit.sourceAsMap.mapKey}">
                                                <option value="${e.key}" selected>${e.name}</option>

                                            </c:when>
                                            <c:otherwise>
                                                <option value="${e.key}">${e.name}</option>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:if>
                                </c:forEach>

                            </c:if>
                        </c:forEach>

                    </select>
                </label>

            </td></tr>
            </table>
        </div>
        <div class="${fn:replace(hit.sourceAsMap.species, " ","")}Class">

            <table class="table table-striped">
                <tr><td colspan="2" style="text-align: center">
                    <!--form action="genomeInformation.html">
                        <input type="hidden" name=species value="$--{hit.sourceAsMap.species}"/>
                    <button type="submit">More</button>
                    </form-->
                    <a href="genomeInformation.html?species=${hit.sourceAsMap.species}&mapKey=${hit.sourceAsMap.mapKey}&details=true" title="click to see more info and other assemblies"><strong>More Details..</strong></a>
                </td></tr>
                <tr><td>Total Seq Length</td><td>${hit.sourceAsMap.totalSeqLength}</td></tr>
                <c:choose>
                    <c:when test="${hit.sourceAsMap.species!='Squirrel' && hit.sourceAsMap.species!='Chinchilla'}">
                        <tr><td>Chromosomes(haploid)</td><td>
                            <c:choose>
                                <c:when test="${hit.sourceAsMap.chromosomes<=1}">
                                    -
                                </c:when>
                                <c:otherwise>
                                    ${hit.sourceAsMap.chromosomes}
                                </c:otherwise>
                            </c:choose>
                        </td></tr>
                    </c:when>
                    <c:otherwise>
                        <tr><td>Scaffolds</td><td></td></tr>
                    </c:otherwise>
                </c:choose>
                <tr><td>Genes</td><td>${hit.sourceAsMap.totalGenes}</td></tr>

            </table>
        </div>
    </div>
</div>