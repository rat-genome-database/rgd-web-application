<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ taglib prefix="f" uri="/WEB-INF/tld/functions.tld" %>


<script>
    var link=true;
    var highlightTerm="${model.term}";
</script>
<script>
    $(function () {
        var highlightTerm="${model.term}";


        $(".more").hide();
        $(".moreLink").on("click", function(e) {

            var $this = $(this);
            var $content = $this.parent().find(".more");
            var linkText = $this.text().toUpperCase();

            if(linkText === "SHOW MATCHES..."){
                linkText = "Hide...";
                $content.show();
            } else {
                linkText = "Show Matches...";
                $content.hide();
            }
            $this.text(linkText);
            return false;

        });
    })

</script>

<table width="100%">

<tr><td>
<div>
    <c:if test="${model.totalHits == 10000}">
        <span style="font-weight: bold">Showing Top</span>
    </c:if>
    <span style="color:#24609c;font-size:15px;"><span id="totalHits"><strong>${model.totalHits}</strong></span>
                            <c:if test="${model.searchBean.category!='General' && model.searchBean.category!='general' && model.searchBean.category!='Ontology'}">
                                <c:if test="${model.searchBean.type!='null'}">
                             <span style="color:blue">${model.searchBean.type}</span>
                                </c:if>
                                <c:if test="${model.searchBean.trait!=null && model.searchBean.trait!='null'}">
                                    <span style="color:blue">${model.searchBean.trait}</span>
                                </c:if>
                                <span class="${model.searchBean.category}">${model.searchBean.category}</span>
                            </c:if>
                             <c:if test="${model.searchBean.category=='Ontology' && model.searchBean.subCat!=''}">
                                 <span class="${model.searchBean.category}" style="color:mediumpurple;font-weight: bold;" > ${model.searchBean.subCat}</span>
                             </c:if>
                             <c:if test="${model.searchBean.category=='Ontology' && model.searchBean.subCat==''}">
                                 <span class="${model.searchBean.category}" style="color:mediumpurple;font-weight: bold;" > ${model.searchBean.category}</span>
                             </c:if>
                            records found for <strong>"${model.term}"</strong></span>


        <c:if test="${model.searchBean.species!='' || fn:length(model.aggregations.species)==1}">
            of species <span class="${model.searchBean.species} ${model.aggregations.species[0].key}" style="font-weight: bold; font-size: 20px">
                    <c:if test="${model.searchBean.species!=''}">
                        ${model.searchBean.species}
                    </c:if>
                     <c:if test="${fn:length(model.aggregations.species)==1 && model.searchBean.species==''}">
                            ${model.aggregations.species[0].key}
                        </c:if>
                          </span>
                          <c:if test="${model.searchBean.chr!='0' && model.searchBean.chr!=''}">
                           on chromosome <span style="font-weight:bold;font-size: 15px">${model.searchBean.chr}</span>
                          </c:if>
        </c:if>
    <h4>Showing results <span id="showResultsFrom">1</span> - <span id="showResultsTo"><c:if test="${model.totalHits<50}">${model.totalHits}</c:if>
        <c:if test="${model.totalHits>50}">50</c:if></span> of ${model.totalHits} results</h4>

    </div>
</td></tr>
    <tr><td>
<div class="results" id="tableDiv" style=";word-wrap: break-word; " >

    <table  id="resultsTable" style="width:100%;z-index:999;" >
        <thead>
        <tr>
            <c:choose>
                <c:when test="${!model.searchBean.category.equalsIgnoreCase('general')}">
                    <c:choose>
                        <c:when test="${model.searchBean.species!='' || model.searchBean.subCat!='' || model.searchBean.category=='Reference' || fn:length(model.aggregations.species)==1 || fn:length(model.aggregations.ontology)==1}">
                            <td title="Toggle Check All"><input type="checkbox" onclick="toggle(this)"></td>
                        </c:when>
                        <c:otherwise>
                            <td></td>
                        </c:otherwise>
                    </c:choose>

                </c:when>
                <c:otherwise>
                    <td></td>
                </c:otherwise>
            </c:choose>

            <td></td>
            <td>
                <c:if test="${model.searchBean.category!='Reference' && model.searchBean.category!='Ontology'}">
                    <c:if test="${model.searchBean.species=='' && fn:length(model.aggregations.species)!=1}">
                        Species
                    </c:if>
                    <c:if test="${model.searchBean.species=='' && fn:length(model.aggregations.species)==1}">

                    </c:if>
                    <c:if test="${model.searchBean.species!='' || fn:length(model.aggregations.species)==1}">

                    </c:if>
                </c:if>
            </td>
            <td>
                <c:if test="${!model.searchBean.category.equals('Ontology')}">
                    <c:if test="${model.searchBean.category.equals('General') || model.searchBean.category.equals('general')}">
                        Object
                    </c:if>
                </c:if>
                <c:if test="${model.searchBean.category.equals('Ontology')&& model.searchBean.subCat.equals('')}">
                    Object
                </c:if>
                <c:if test="${model.searchBean.category.equals('Ontology')&& !model.searchBean.subCat.equals('')}">

                </c:if>
            </td>
            <td style="width: 10em;">
                <c:if test="${model.searchBean.category!='Reference' && model.searchBean.category!='Ontology' && model.searchBean.category!='Variant'}">
                    Symbol
                </c:if>
            </td>
            <td style="width:30%">
                <c:if test="${model.searchBean.category=='Reference'}">
                    Title
                </c:if>
                <c:if test="${model.searchBean.category=='Ontology'}">
                    Term
                </c:if>
                <c:if test="${model.searchBean.category!='Reference' && model.searchBean.category!='Ontology'}">
                    <c:if test="${model.searchBean.category.equalsIgnoreCase('General')}">
                        Name/Term/Title
                    </c:if>
                    <c:if test="${!model.searchBean.category.equalsIgnoreCase('General')}">
                        Name
                    </c:if>

                </c:if>
            </td>
            <td>
                <c:if test="${model.searchBean.category!='Reference' && model.searchBean.category!='Ontology'}">
                    Chr
                </c:if>
                <c:if test="${model.searchBean.category=='Reference'}">
                    Citation
                </c:if>
            </td>
            <td>
                <c:if test="${model.searchBean.category!='Reference' && model.searchBean.category!='Ontology'}">
                    Start
                </c:if>
                <c:if test="${model.searchBean.category=='Reference'}">
                    Authors
                </c:if>
            </td>
            <td>
                <c:if test="${model.searchBean.category!='Reference' && model.searchBean.category!='Ontology'}">
                    Stop
                </c:if>
            </td>
            <td>
                <c:if test="${!model.searchBean.category.equalsIgnoreCase('Reference')}">
                    Annotations
                </c:if>
            </td>
            <td>RGD ID / <br>Term_acc
            </td>
            <td>Matched By</td><!--td>Score</td-->
        </tr>
        </thead>

        <tbody>
        <c:set var="xRecordCount" value="0"/>
        <c:set var="sampleExists" value="0"/>
        <c:forEach items="${model.hitArray}" var="hitArray">
            <c:forEach items="${hitArray}" var="hit">
                <c:set var="xRecordCount" value="${xRecordCount+ hit.getSourceAsMap().experimentRecordCount}"/>
                <c:set var="sampleExists" value="${sampleExists+ hit.getSourceAsMap().sampleExists}"/>
                <c:set var="url" value="/rgdweb/report/${hit.getSourceAsMap().category.toLowerCase()}/main.html?id=${hit.getSourceAsMap().id}${hit.getSourceAsMap().term_acc}"/>
                <c:if test="${hit.getSourceAsMap().category=='Reference'}">
                    <c:set var="url" value="/rgdweb/report/reference/main.html?id=${hit.getSourceAsMap().id}${hit.getSourceAsMap().term_acc}"/>
                </c:if>
                <c:if test="${hit.getSourceAsMap().category=='SSLP'}">
                    <c:set var="url" value="/rgdweb/report/marker/main.html?id=${hit.getSourceAsMap().id}${hit.getSourceAsMap().term_acc}"/>
                </c:if>
                <c:if test="${hit.getSourceAsMap().category!='SSLP'&& hit.getSourceAsMap().category!='Gene' && hit.getSourceAsMap().category!='Strain' && hit.getSourceAsMap().category!='QTL' && hit.getSourceAsMap().category!='Variant' && hit.getSourceAsMap().category!='Reference'}">
                    <c:set var="url" value="/rgdweb/ontology/annot.html?acc_id=${hit.getSourceAsMap().term_acc}&species=-1"/>
                </c:if>
                <c:if test="${hit.getSourceAsMap().category=='Promoter'}">
                    <c:set var="url" value="/rgdweb/report/ge/main.html?id=${hit.getSourceAsMap().term_acc}"/>
                </c:if>
                <c:if test="${hit.getSourceAsMap().category=='Cell line'}">
                    <c:set var="url" value="/rgdweb/report/cellline/main.html?id=${hit.getSourceAsMap().term_acc}"/>
                </c:if>
                <!--tr onmouseover="this.style.cursor='pointer'" onclick="if (link) window.location= '$-{url}'"-->
                <tr onmouseover="this.style.cursor='pointer'" onclick="if (link) window.open('${url}', '_blank')">
                    <c:choose>
                        <c:when test="${model.searchBean.category.equals('Gene') || model.searchBean.category.equals('Strain') || model.searchBean.category.equals('QTL')
                                         || model.searchBean.category.equals('SSLP') || model.searchBean.category.equals('Variant') || model.searchBean.category.equals('Promoter') || model.searchBean.category.equals('Reference') || model.searchBean.category.equals('Cell line')}">
                            <c:choose>
                                <c:when test="${model.searchBean.species!='' ||  fn:length(model.aggregations.species)==1 || model.searchBean.category.equals('Reference')}">
                                    <td  class="${hit.getSourceAsMap().species}" onmouseover="link=false;" onmouseout="link=true;">
                                        <c:choose>
                                            <c:when test="${model.searchBean.category!='Gene'}">
                                                <input class="checkedObjects" name="checkedObjects" type="checkbox" value="${hit.getSourceAsMap().term_acc}" data-count="${hit.getSourceAsMap().experimentRecordCount}" data-symbol="${hit.getSourceAsMap().symbol}" data-sampleExists="${hit.getSourceAsMap().sampleExists}">
                                            </c:when>
                                            <c:otherwise>
                                                <input class="checkedObjects" name="checkedObjects" type="checkbox" value="${hit.getSourceAsMap().term_acc}" data-rgdids="${hit.getSourceAsMap().term_acc}">
                                            </c:otherwise>
                                        </c:choose>

                                    </td>
                                </c:when>
                                <c:otherwise>

                                    <td  class="${hit.getSourceAsMap().species}"></td>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                                <c:when test="${fn:length(model.aggregations.category)==1 || (fn:length(model.aggregations.category)==1 && model.searchBean.species!='')}">
                                    <c:if test="${model.aggregations.category[0].key!='Ontology'}">
                                        <td  class="${hit.getSourceAsMap().species}" onmouseover="link=false;" onmouseout="link=true;">
                                            <c:choose>
                                                <c:when test="${model.aggregations.category[0].key!='Gene'}">
                                                    <input class="checkedObjects" name="checkedObjects" type="checkbox" value="${hit.getSourceAsMap().term_acc}" data-count="${hit.getSourceAsMap().experimentRecordCount}" data-symbol="${hit.getSourceAsMap().symbol}" data-sampleExists="${hit.getSourceAsMap().sampleExists}">
                                                </c:when>
                                                <c:otherwise>
                                                    <input class="checkedObjects" name="checkedObjects" type="checkbox" value="${hit.getSourceAsMap().symbol}">
                                                </c:otherwise>
                                            </c:choose>

                                        </td>
                                    </c:if>
                                    <c:if test="${model.aggregations.category[0].key=='Ontology'}">

                                        <c:choose>
                                            <c:when test="${fn:length(model.aggregations.category)==1}">
                                                <td  class="${hit.getSourceAsMap().species}" onmouseover="link=false;" onmouseout="link=true;">
                                                    <c:choose>
                                                        <c:when test="${model.aggregations.category[0].key!='Gene'}">
                                                            <input class="checkedObjects" name="checkedObjects" type="checkbox" value="${hit.getSourceAsMap().term_acc}" data-count="${hit.getSourceAsMap().experimentRecordCount}" data-symbol="${hit.getSourceAsMap().symbol}" data-sampleExists="${hit.getSourceAsMap().sampleExists}">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <input class="checkedObjects" name="checkedObjects" type="checkbox" value="${hit.getSourceAsMap().term_acc}">
                                                        </c:otherwise>
                                                    </c:choose>

                                                </td>
                                            </c:when>
                                            <c:otherwise>
                                                <td  class="${hit.getSourceAsMap().species}"></td>
                                            </c:otherwise>
                                        </c:choose>

                                    </c:if>

                                </c:when>
                                <c:otherwise>
                                    <c:choose>
                                        <c:when test="${model.searchBean.category.equals('Ontology') && model.searchBean.subCat!=''}">

                                            <td  class="${hit.getSourceAsMap().species}" onmouseover="link=false;" onmouseout="link=true;">

                                                <input class="checkedObjects" name="checkedObjects" type="checkbox" value="${hit.getSourceAsMap().term_acc}" data-count="${hit.getSourceAsMap().experimentRecordCount}" data-symbol="${hit.getSourceAsMap().symbol}" data-sampleExists="${hit.getSourceAsMap().sampleExists}">
                                            </td>



                                        </c:when>
                                        <c:otherwise>
                                            <td  class="${hit.getSourceAsMap().species}"></td>
                                        </c:otherwise>
                                    </c:choose>


                                </c:otherwise>
                            </c:choose>

                        </c:otherwise>
                    </c:choose>
                    <td class="${hit.getSourceAsMap().species}">

                        <c:if test="${hit.getSourceAsMap().species!='All' && hit.getSourceAsMap().species!=null}">

                            <c:if test="${model.searchBean.species=='' && fn:length(model.aggregations.species)!=1}">
                                <i class="fa fa-star fa-lg" aria-hidden="true"></i>
                                <!--div style="float:left"><figure class="circle $-{hit.getSourceAsMap().species}"></figure></div-->
                            </c:if>
                            <c:if test="${model.searchBean.species!='' || fn:length(model.aggregations.species)==1 }">

                            </c:if>
                            <c:if test="${model.searchBean.species=='' && fn:length(model.aggregations.species)==1 }">

                            </c:if>
                        </c:if>
                    </td>

                    <td class="${hit.getSourceAsMap().species}" >
                        <c:if test="${hit.getSourceAsMap().species!='All' && hit.getSourceAsMap().species!=null}">
                            <c:if test="${model.searchBean.species=='' && fn:length(model.aggregations.species)!=1}">
                                 ${hit.getSourceAsMap().species}
                            </c:if>
                            <c:if test="${model.searchBean.species!='' || fn:length(model.aggregations.species)==1 }">

                            </c:if>
                            <c:if test="${model.searchBean.species=='' && fn:length(model.aggregations.species)==1 }">

                            </c:if>
                        </c:if>
                    </td>


                    <td><span class="${hit.getSourceAsMap().category}">
                        <c:if test="${hit.getSourceAsMap().category.equalsIgnoreCase('ontology')}">
                            <c:if test="${model.searchBean.category.equalsIgnoreCase('General') }">
                                 ${hit.getSourceAsMap().subcat}
                            </c:if>
                            <c:if test="${!model.searchBean.category.equalsIgnoreCase('General') }">
                                <c:if test="${model.searchBean.subCat==''}">
                                     ${hit.getSourceAsMap().subcat}
                                </c:if>
                            </c:if>

                        </c:if>



                         <c:if test="${!hit.getSourceAsMap().category.equalsIgnoreCase('ontology') }">
                             <c:if test="${model.searchBean.category.equalsIgnoreCase('General')}">
                                  ${hit.getSourceAsMap().category}
                             </c:if>
                             <c:if test="${!model.searchBean.category.equalsIgnoreCase('General')}">

                             </c:if>
                         </c:if>
                        </span>
                    </td>

                    <td>
                        <c:set var="symbl" value="${hit.getSourceAsMap().symbol}"/>
                        <c:set var="t" value="${model.term}"/>
                       ${f:format(symbl, t)}
                        <c:if test="${hit.getSourceAsMap().sampleExists==1}">
                            <span style="color:red;font-size:20px;font-weight:bold" title='Can be analyzed in Variant Visulizer tool'>
                                <img src="/rgdweb/images/VV_small.gif" >
                            </span></c:if>
                        <c:if test="${hit.getSourceAsMap().experimentRecordCount>0}">
                            <span style="color:blue;font-size:20px;font-weight:bold" title='Phenominer Data Available'>
                                <img src="/rgdweb/images/PM_small.gif" ></span></c:if>
                    </td>

                    <td  onmouseover="link=false;" onmouseout="link=true;" style="cursor: auto;">
                        <a href="${url}" target="_blank">
                            <c:set var="str" value="${hit.getSourceAsMap().name}${hit.getSourceAsMap().title}${hit.getSourceAsMap().term}"/>
                       ${f:format(str,t )}
                        </a>
                        <c:if test="${hit.getSourceAsMap().category!='SSLP'&& hit.getSourceAsMap().category!='Gene' && hit.getSourceAsMap().category!='Strain' && hit.getSourceAsMap().category!='QTL' && hit.getSourceAsMap().category!='Variant' && hit.getSourceAsMap().category!='Reference'  && hit.getSourceAsMap().category!='Promoter'  && hit.getSourceAsMap().category!='Cell line'}">
                            <a href="/rgdweb/ontology/view.html?acc_id=${hit.getSourceAsMap().term_acc}" title="click to browse the term" alt="browse term" target="_blank">
                                <img border="0" src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser"></a>
                            <c:if test="${hit.getSourceAsMap().annotationsCount>0}">
                                &nbsp;<a href="${url}" target="_blank"><img border="0" src="/rgdweb/images/icon-a.gif" title="Show ${hit.getSourceAsMap().annotationsCount} annotated objects"></a>
                            </c:if>
                            <c:if test="${hit.getSourceAsMap().pathwayDiagUrl!=null}">
                                &nbsp;<a href="${hit.getSourceAsMap().pathwayDiagUrl}" target="_blank"><img border="0" src="/rgdweb/images/icon-d.gif" title="Pathway Diagram"></a>
                            </c:if>
                        </c:if>
                    </td>

                    <td>
                        <c:choose>
                            <c:when test="${model.defaultAssembly!=null}">
                                <c:forEach items="${hit.getSourceAsMap().mapDataList}" var="chrMap">
                                    <c:if test="${chrMap.map.equalsIgnoreCase(model.defaultAssembly)}">
                                         ${chrMap.chromosome}<br>

                                    </c:if>

                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${hit.getSourceAsMap().mapDataList}" var="item">

                                    <c:if test="${item.map.equalsIgnoreCase('RGSC Genome Assembly v6.0')}">
                                          ${item.chromosome}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Human Genome Assembly GRCh38')}">
                                         ${item.chromosome}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Dog CanFam3.1 Assembly')}">
                                         ${item.chromosome}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Bonobo panpan1.1 Assembly')}">
                                        ${item.chromosome}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Squirrel SpeTri2.0 Assembly')}">
                                        ${item.chromosome}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('ChiLan1.0')}">
                                          ${item.chromosome}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Mouse Genome Assembly GRCm38')}">
                                         ${item.chromosome}
                                    </c:if>

                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                        <c:if test="${!model.searchBean.category.equalsIgnoreCase('general')}">

                           ${f:format(hit.getSourceAsMap().citation,t )} </span>
                        </c:if>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${model.defaultAssembly!=null}">
                                <c:forEach items="${hit.getSourceAsMap().mapDataList}" var="startPosMap">
                                    <c:if test="${startPosMap.map.equalsIgnoreCase(model.defaultAssembly)}">
                                        ${startPosMap.startPos}<br>
                                    </c:if>

                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${hit.getSourceAsMap().mapDataList}" var="item">

                                    <c:if test="${item.map.equalsIgnoreCase('RGSC Genome Assembly v6.0')}">
                                        ${item.startPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Human Genome Assembly GRCh38')}">
                                         ${item.startPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Dog CanFam3.1 Assembly')}">
                                         ${item.startPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Bonobo panpan1.1 Assembly')}">
                                        ${item.startPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Squirrel SpeTri2.0 Assembly')}">
                                         ${item.startPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('ChiLan1.0')}">
                                         ${item.startPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Mouse Genome Assembly GRCm38')}">
                                         ${item.startPos}
                                    </c:if>

                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                        <c:if test="${!model.searchBean.category.equalsIgnoreCase('general')}">
                            ${f:format(hit.getSourceAsMap().author, t )}
                        </c:if>

                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${model.defaultAssembly!=null}">
                                <c:forEach items="${hit.getSourceAsMap().mapDataList}" var="stopPosMap">
                                    <c:if test="${stopPosMap.map.equalsIgnoreCase(model.defaultAssembly)}">
                                       ${stopPosMap.stopPos}<br>
                                    </c:if>

                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${hit.getSourceAsMap().mapDataList}" var="item">
                                    <c:if test="${item.map.equalsIgnoreCase('RGSC Genome Assembly v6.0')}">
                                       ${item.stopPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Human Genome Assembly GRCh38')}">
                                       ${item.stopPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Dog CanFam3.1 Assembly')}">
                                       ${item.stopPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Bonobo panpan1.1 Assembly')}">
                                        ${item.stopPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Squirrel SpeTri2.0 Assembly')}">
                                        ${item.stopPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('ChiLan1.0')}">
                                        ${item.stopPos}
                                    </c:if>
                                    <c:if test="${item.map.equalsIgnoreCase('Mouse Genome Assembly GRCm38')}">
                                        ${item.stopPos}
                                    </c:if>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>


                    </td>
                    <!--td>$--{hit.getSourceAsMap().type}</td-->

                    <td>
                        <c:if test="${model.searchBean.category!='Ontology' && model.searchBean.category!='Reference'}">
                            ${hit.getSourceAsMap().annotationsCount}
                        </c:if>
                        <c:if test="${model.searchBean.category=='Ontology'}">
                            <div class="tooltips"><!--a href="search/annotGraph.html?id=$--{hit.getSourceAsMap().term_acc}&rootTerm=$--{hit.getSourceAsMap().term}" target="_blank">AnnotCount</a-->
                                <c:if test="${hit.getSourceAsMap().annotationsCount>0}">
                                    Term  (${hit.getSourceAsMap().termAnnotsCount}) + Child Term  (${hit.getSourceAsMap().childTermsAnnotsCount})
                                    <div class="scoreBoard tooltiptext" style="font-size: x-small;width:400px">

                                        <table width="100%">
                                            <caption style="font-size: x-small;color:white">Associated Objects:</caption>
                                            <thead>
                                            <tr>
                                                <td  style="color: white;padding-left:10px"></td>
                                                <td style="color: white">Rat</td>
                                                <td style="color: white">Human</td>
                                                <td style="color: white">Mouse</td>
                                                <td style="color: white">Chinchilla</td>
                                                <td style="color: white">Dog</td>
                                                <td style="color: white">Bonobo</td>
                                                <td style="color: white;padding-right:10px">Squirrel</td>
                                            </tr>
                                            <c:set var="i" value="0"/>
                                            <c:forEach items="${hit.getSourceAsMap().annotationsMatrix}" var="row">
                                                <tr>

                                                    <td style="color: white">
                                                        <c:if test="${i==0}">
                                                            Gene
                                                        </c:if>
                                                        <c:if test="${i==1}">
                                                            Strain
                                                        </c:if>
                                                        <c:if test="${i==2}">
                                                            QTL
                                                        </c:if>
                                                        <c:if test="${i==3}">
                                                            Variant
                                                        </c:if>
                                                    </td>
                                                    <c:forEach items="${row}" var="column" varStatus="loop">

                                                        <td class="matrix" style="color: white">${column}</td>

                                                    </c:forEach>

                                                </tr>
                                                <c:set var="i" value="${i + 1}"/>
                                            </c:forEach>

                                            </thead>

                                        </table>

                                    </div>
                                </c:if>

                            </div>
                        </c:if>
                    </td>

                    <td class="id">${hit.getSourceAsMap().id}${hit.getSourceAsMap().term_acc}</td>
                    <td id="highlight">
                        <c:set value="true" var="first"/>
                        <c:set value="false" var="synonymExists"/>
                        <c:set value="false" var="symbolExists"/>
                        <c:set value="false" var="nameExists"/>
                        <c:set value="false" var="descripExists"/>
                        <c:set value="false" var="originExists"/>
                        <c:set value="false" var="srcExists"/>
                        <c:set value="false" var="titleExists"/>
                        <c:set value="false" var="termExists"/>
                        <c:set value="false" var="termDefExists"/>
                        <c:set value="false" var="citationExists"/>
                        <c:set value="false" var="authorExists"/>

                        <c:forEach items="${hit.getHighlightFields()}" var="hf">

                            <c:if test="${hf.key=='xdbIdentifiers'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >

                                        <span>External DB id</span>
                                        <c:set value="false" var="first"/>
                                    </c:when>
                                    <c:otherwise>
                                        , <span >External DB id</span>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>


                            <c:if test="${fn:containsIgnoreCase(hf.key, 'xdata')}">

                                <c:choose>
                                    <c:when test="${first=='true'}" >

                                        <span >Experimental Data</span>
                                        <c:set value="false" var="first"/>
                                    </c:when>
                                    <c:otherwise>
                                        , <span >Experimental Data</span>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='symbol' || hf.key=='symbol.symbol' || hf.key=='symbol.keyword' || hf.key=='symbol.ngram' || hf.key=='htmlStrippedSymbol.ngram'}">
                                <c:if test="${symbolExists=='false'}">
                                    <c:choose>
                                        <c:when test="${first=='true'}">
                                            <span>Symbol</span>
                                            <c:set value="true" var="symbolExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:when>
                                        <c:otherwise>
                                            <span>, Symbol</span>
                                            <c:set value="true" var="symbolExists"/>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </c:if>

                            <c:if test="${hf.key=='synonyms' || hf.key=='synonyms.synonyms' }">
                                <c:if test="${synonymExists=='false'}">
                                    <c:choose>
                                        <c:when test="${first=='true'}">
                                            <span>Synonym/Alias</span>
                                            <c:set value="true" var="synonymExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:when>
                                        <c:otherwise>
                                            <span>, Synonym/Alias</span>
                                            <c:set value="true" var="synonymExists"/>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </c:if>

                            <c:if test="${hf.key=='name' || hf.key=='name.name'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >
                                        <c:if test="${nameExists==false}">
                                            <span>Name</span>
                                            <c:set value="true" var="nameExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${nameExists==false}">
                                            <span>, Name</span>
                                            <c:set value="true" var="nameExists"/>

                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='description' || hf.key=='description.description'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >
                                        <c:if test="${descripExists==false}">
                                            <span>Description</span>
                                            <c:set value="true" var="descripExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${descripExists==false}">
                                            <span>, Description</span>
                                            <c:set value="true" var="descripExists"/>

                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='origin' || hf.key=='origin.origin'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >
                                        <c:if test="${originExists==false}">
                                            <span>Origin</span>
                                            <c:set value="true" var="originExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${originExists==false}">
                                            <span>, Origin</span>
                                            <c:set value="true" var="originExists"/>

                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='source' || hf.key=='source.source'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >
                                        <c:if test="${srcExists==false}">
                                            <span>Source</span>
                                            <c:set value="true" var="srcExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${srcExists==false}">
                                            <span>, Source</span>
                                            <c:set value="true" var="srcExists"/>

                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>

                            <c:if test="${hf.key=='title' || hf.key=='title.title'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >
                                        <c:if test="${titleExists==false}">
                                            <span>Title</span>
                                            <c:set value="true" var="titleExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${titleExists==false}">
                                            <span>, Title</span>
                                            <c:set value="true" var="titleExists"/>

                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='author' || hf.key=='author.author'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >
                                        <c:if test="${authorExists==false}">
                                            <span>Author</span>
                                            <c:set value="true" var="authorExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${authorExists==false}">
                                            <span>, Author</span>
                                            <c:set value="true" var="authorExists"/>

                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='citation' || hf.key=='citation.citation'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >
                                        <c:if test="${citationExists==false}">
                                            <span>Citation</span>
                                            <c:set value="true" var="citationExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${citationExists==false}">
                                            <span>, Citation</span>
                                            <c:set value="true" var="citationExists"/>

                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='term' || hf.key=='term.term'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >
                                        <c:if test="${termExists==false}">
                                            <span>Term</span>
                                            <c:set value="true" var="termExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${termExists==false}">
                                            <span>, Term</span>
                                            <c:set value="true" var="termExists"/>

                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='term_def' || hf.key=='term_def.term'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >
                                        <c:if test="${termDefExists==false}">
                                            <span>Term_Def</span>
                                            <c:set value="true" var="termDefExists"/>
                                            <c:set value="false" var="first"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${termDefExists==false}">
                                            <span>, Term_Def</span>
                                            <c:set value="true" var="termDefExists"/>

                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='trait' ||  hf.key=='promoters' || hf.key=='type' || hf.key=='protein_acc_ids' ||
                            hf.key=='transcript_ids' || hf.key=='annotated_objects' || hf.key=='annotation_synonyms'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >

                                        <span>${hf.key}</span>

                                        <c:set value="false" var="first"/>

                                    </c:when>
                                    <c:otherwise>
                                        <span>, ${hf.key}</span>

                                    </c:otherwise>
                                </c:choose>
                            </c:if>

                            <c:if test="${hf.key=='subTrait'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >

                                        <span>Measurement</span>

                                        <c:set value="false" var="first"/>

                                    </c:when>
                                    <c:otherwise>
                                        <span>, Measurement</span>

                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='refAbstract' || hf.key=='refAbstract.refAbstract'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >

                                        <span>Abstract</span>

                                        <c:set value="false" var="first"/>

                                    </c:when>
                                    <c:otherwise>
                                        <span>, Abstract</span>

                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='associations'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >

                                        <span>Related Genes</span>

                                        <c:set value="false" var="first"/>

                                    </c:when>
                                    <c:otherwise>
                                        <span>, Related Genes</span>

                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${hf.key=='genomicAlteration'}">
                                <c:choose>
                                    <c:when test="${first=='true'}" >

                                        <span>Genomic Alteration</span>

                                        <c:set value="false" var="first"/>

                                    </c:when>
                                    <c:otherwise>
                                        <span>, Genomic Alteration</span>

                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </c:forEach>
                        <!--a href="#" class="moreLink" style="color:dodgerblue" title="Matched fragments">Show Matches...</a>
                        <div  class="more hideContent" style="overflow-y: auto">
                            <!--c:set value="true" var="first"/>
                            <!--c:forEach items="$--{hit.getHighlightFields()}" var="hf">

                                <!--c:forEach items="$-{hf.value.getFragments()}" var="f">
                                    $-{f} ;
                                <!--/c:forEach>
                            <!--/c:forEach>
                        </div-->
                    </td>
                    <!--td class="" >$-{hit.getScore()}</td-->

                </tr>
            </c:forEach>
        </c:forEach>


        </tbody>
    </table>
    <input type="hidden" id="sampleExists" value="${sampleExists}"/>
   </div>
    </td></tr>
</table>
