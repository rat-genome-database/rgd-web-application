$(function () {

  

    $('#viewAllBtn').on('click', function () {
        var $content=$('#results');
        var cat1=$('#cat1').val();
        var sp1=$('#sp1').val();
        var term=$('#searchTerm').val();
        var start=$('#start').val();
        var stop= $('#stop').val();
        var chr= $('#chr').val();
        var assembly=$('#assembly').val();
        var $url="/rgdweb/elasticResults.html?term="+term+"&category="+cat1+"&species="+sp1+"&page=true"+ "&start="+start+"&stop="+stop+"&chr="+chr+"&assembly="+assembly;

    
        $.get($url, function (data, status) {

            $content.html(data);
            $('#viewAllBtn').hide();
            $('#species').val("");
            $('#searchCategory').val(cat1);
            $('#toolsBar').html("");
        })

    });
   /* $('#viewAll').on('click', function () {

        $('#viewAll').hide();
        $('#viewAllForm').submit();

    });*/

    $('#assembly').on('change', function (e) {

                $('#objectAssembly').val($(this).val());
                $('#assemblyForm').submit();
           });


    $('.filter').on('click', function () {
        var $content = $("#mainBody");
        $content.html('<div style="margin-left:50%"><i class="fa fa-spinner fa-spin" style="font-size:24px;color:dodgerblue"></i></div>');
    });
    var cat=$('#category').val();
    $('#category').on('change', function () {
        cat=$('#category').val();
       
    });



});
function getParameters() {
    $content = $('#results');
    tmp = $content.html();

    $assembly = $('#assembly').val();
    if (typeof  $assembly == "undefined") {
        $assembly = "";
    }

    sortBy = $('#sortBy').val();
    if(typeof sortBy=="undefined"){
        sortBy=0;
    }
    $currentPage = $('#currentPage');
    $totalPages = $('#totalPages');
    currentPage = parseInt($currentPage.text());
    totalPages = parseInt($totalPages.text());

    $species= $("#species");
    $category= $("#searchCategory");
    category = $category.val();
    species = $species.val();
    term = $('#searchTerm').val();
    $type = $("#type").val();
    $filterType=$('#filter').val();
    $subCat=$('#subCat').val();
    $$url = "";
    totalHitsText = $("#totalHits").text();
    pageSize = $('#pageSize').val();
    totalHits = parseInt(totalHitsText);
    $toolsDiv=$('#toolsBar');

    $start=$('#start').val();
    if($start=='undefined'){
        $start="";
    }
    $stop=$('#stop').val();
    if($stop=='undefined'){
        $stop="";
    }

    $chr=$("#chr").val();
    if($chr=='undefined'){
        $chr="";
    }
    objectSearch=$('#objectSearch');
    if(objectSearch!='undefined'){
        $objectSearch= objectSearch.val();
    }
   /* $objectAssembly= $('#objectAssembly').val()*/
  //  if(typeof $('#assembly').val()!='undefined')
    $objectAssembly= $('#assembly').val()
    console.log("assembly:"+$objectAssembly)
    mapKey=$('#mapKey').val();

}
function setParameters(){
    $('#pageNumber').val(currentPage);
    $('#currentPage').text(currentPage);
    $('#totalPages').text(totalPages);
    $('#sortBy').val(sortBy);
    $('#pageSize').val(pageSize);
  //  $('#assembly').val($assembly);
    $('#filter').val($filterType);
    $('#subCat').val($subCat);
    $('#assembly').val($objectAssembly);
}
function prevFunction(e, id) {
    getParameters();
    var showFromId=$('#showResultsFrom'),
        showToId=$('#showResultsTo'),
        showfromVal= Number(showFromId.text()),
        showToVal= Number(showToId.text()),
        displayFrom, displayTo;
    if(showfromVal>1)
    displayFrom=showfromVal-pageSize;

    if(showToVal==totalHits){
      var diff=  totalHits%pageSize;
        displayTo=showToVal-diff;
    }else{
        displayTo= showToVal-pageSize;
    }

    $content.html('<div style="margin-left:50%"><i class="fa fa-spinner fa-spin" style="font-size:24px;color:dodgerblue"></i></div>');
    if(currentPage>1) {
        currentPage = currentPage - 1;
        if(typeof $assembly=='undefined') {
            $url = "elasticResults.html?category=" + category + "&term=" + term + "&species=" + species + "&currentPage=" + currentPage + "&size=" + pageSize+ "&page=true&sortBy=" + sortBy+"&"+$filterType+"="+$type+"&subCat=" +$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr;
        }else{
            $url = "elasticResults.html?category=" + category + "&term=" + term + "&species=" + species + "&currentPage=" + currentPage + "&size=" + pageSize + "&page=true&sortBy=" + sortBy+"&assembly="+$assembly+"&"+$filterType+"="+$type+"&subCat=" +$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr;
        }
        if($objectSearch == "true") {
            $url =  "elasticResults.html?category=" + category + "&term=" + term + "&species=" + species + "&currentPage=" + currentPage + "&size=" + pageSize + "&page=true&sortBy=" + sortBy+"&"+$filterType+"="+$type+"&subCat=" +$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr+"&objectSearch=" + $objectSearch + "&assembly=" + $objectAssembly;
        }
        $.get($url, function (data, status) {
            $content.html(data);
            $('#showResultsFrom').text(displayFrom);
            if(totalHits<pageSize || displayTo>totalHits){
                $('#showResultsTo').text(totalHits);
            }else{
                $('#showResultsTo').text(displayTo);
            }

           setParameters();
        })
    }
    else if(currentPage==1){
        $content.html(tmp);
       setParameters();
    }
}
function nextFunction(e, id) {
   getParameters();


   $content.html('<div style="margin-left:50%"><i class="fa fa-spinner fa-spin" style="font-size:24px;color:dodgerblue"></i></div>');
   if((currentPage) < (totalPages)) {
        currentPage = currentPage + 1;

            $url="elasticResults.html?category=" + category + "&term=" + term +"&species=" + species + "&currentPage=" +currentPage +"&size=" +pageSize +"&page=true&sortBy=" +sortBy+"&assembly="+$assembly +"&"+$filterType+"="+$type +"&subCat=" +$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr;
       if($objectSearch == "true") {
           $url ="elasticResults.html?category=" + category + "&term=" + term +"&species=" + species + "&currentPage=" +currentPage +"&size=" +pageSize +"&page=true&sortBy=" +sortBy +"&"+$filterType+"="+$type +"&subCat=" +$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr+"&objectSearch=" + $objectSearch + "&assembly=" + $objectAssembly;
       }

        $.get($url, function (data, status) {
            $content.html(data);
            var displayFrom=((currentPage-1)* Number(pageSize) +1);
            $('#showResultsFrom').text(displayFrom);
            var displayTo= Number(pageSize) * Number(currentPage);
            if(totalHits<pageSize || displayTo>totalHits){
                $('#showResultsTo').text(totalHits);
            }else {
                $('#showResultsTo').text(displayTo);
            }
           setParameters();
        })
    }
    else if(currentPage== totalPages){
        $content.html(tmp);
       setParameters();
    }
}

function sortFunction(e, value) {
    getParameters();
    var totalPages=getTotalPages(totalHits, pageSize);
    $totalPages.text(totalPages);
    $currentPage.text(1);
    currentPage=$currentPage.text();
    $("#pageNumber").val(1);
   $url="elasticResults.html?category=" + category + "&term=" + term +"&species=" + species + "&currentPage=1"  +"&size=" +pageSize +"&page=true&sortBy="+sortBy+"&assembly="+$assembly +"&"+$filterType+"="+ $type+"&subCat="+$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr;

    if($objectSearch == "true") {
        $url = "elasticResults.html?category=" + category + "&term=" + term +"&species=" + species + "&currentPage=1"  +"&size=" +pageSize +"&page=true&sortBy="+sortBy +"&"+$filterType+"="+ $type+"&subCat="+$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr+"&objectSearch=" + $objectSearch + "&assembly=" + $objectAssembly;
    }
    $.get($url, function (data, status) {

        $content.html(data);
        var displayFrom=((currentPage-1)* Number(pageSize) +1);
        $('#showResultsFrom').text(displayFrom);
        var displayTo= Number(pageSize) * Number(currentPage);
        if(totalHits<pageSize || displayTo>totalHits) {
            $('#showResultsTo').text(totalHits);
        }else {
            $('#showResultsTo').text(displayTo);
        }
        $('#sortBy').val(sortBy);
        $('#pageSize').val(pageSize)

    })
}

/*function assembly(){
   getParameters();
    var totalPages=getTotalPages(totalHits, pageSize);
    $totalPages.text(totalPages);

    $currentPage.text(1);
    $("#pageNumber").val(1);
    $url="elasticResults.html?category=" + category + "&term=" + term +"&species=" + species + "&currentPage=1"  +"&size=" +pageSize +"&page=true&sortBy="+sortBy +"&assembly="+$assembly+"&"+$filterType+"="+ $type+"&subCat=" +$subCat;

    $.get($url, function (data, status) {
        $content.html(data);
        var displayFrom=1;
        $('#showResultsFrom').text(displayFrom);
        var displayTo= Number(pageSize)
        if(totalHits<pageSize || displayTo>totalHits) {
            $('#showResultsTo').text(totalHits);
        }else {
            $('#showResultsTo').text(displayTo);
        }


        $('#sortBy').val(sortBy);
        $('#pageSize').val(pageSize)

    });
  }*/
function pagesizeFunction(e, id){
    getParameters();
    $content.html('<div style="margin-left:50%"><i class="fa fa-spinner fa-spin" style="font-size:24px;color:dodgerblue"></i></div>');
   var totalPages=getTotalPages(totalHits, pageSize)
    $totalPages.text(totalPages);
    $currentPage.text(1);
    currentPage=$currentPage.text();
    $url="elasticResults.html?category=" + category + "&term=" + term +"&species=" + species + "&currentPage=1"  +"&size=" +pageSize +"&page=true&sortBy=" +sortBy +"&assembly="+$assembly +"&"+$filterType+"="+$type+"&subCat=" +$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr;
    if($objectSearch == "true") {
        $url ="elasticResults.html?category=" + category + "&term=" + term +"&species=" + species + "&currentPage=1"  +"&size=" +pageSize +"&page=true&sortBy=" +sortBy  +"&"+$filterType+"="+$type+"&subCat=" +$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr+"&objectSearch=" + $objectSearch + "&assembly=" + $objectAssembly;
    }
    console.log($url);
    $.get($url, function (data, status) {
        $content.html(data);
        var displayFrom=((currentPage-1)* Number(pageSize) +1);
        $('#showResultsFrom').text(displayFrom);
        var displayTo= Number(pageSize) * Number(currentPage);
        if(totalHits<pageSize || displayTo>totalHits){
            $('#showResultsTo').text(totalHits);
        }else {
            $('#showResultsTo').text(displayTo);
        }
        $('#pageSize').val(pageSize);
        $('#sortBy').val(sortBy);
    })

}
function getTotalPages(totalHits, pageSize){
    var $totalPages;
    if(totalHits>pageSize){

        if((totalHits%pageSize)!=0){
            $totalPages=(Math.floor(totalHits/pageSize)) +1;
        }else{
            $totalPages=(Math.floor(totalHits/pageSize)) ;
        }
    }else{
        $totalPages=1;
        pageSize=totalHits;
    }
    return $totalPages
}
function submitFunction(e) {
    getParameters();
    currentPage=$('#pageNumber').val();
   
    if(currentPage>totalPages){
        return 0;
    }else{
        $currentPage.val(currentPage);
        $content.html('<div style="margin-left:50%"><i class="fa fa-spinner fa-spin" style="font-size:24px;color:dodgerblue"></i></div>');
        $url="elasticResults.html?category=" + category + "&term=" + term +"&species=" + species + "&currentPage=" + currentPage  +"&size=" +pageSize +"&page=true&sortBy=" +sortBy+"&assembly="+$assembly+"&"+$filterType+"="+ $type+"&subCat=" +$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr;
        if($objectSearch == "true") {
            $url = "elasticResults.html?category=" + category + "&term=" + term +"&species=" + species + "&currentPage=" + currentPage  +"&size=" +pageSize +"&page=true&sortBy=" +sortBy+"&"+$filterType+"="+ $type+"&subCat=" +$subCat+ "&start="+$start+"&stop="+$stop+"&chr="+$chr+"&objectSearch=" + $objectSearch + "&assembly=" + $objectAssembly;
        }
        $.get($url, function (data, status) {
            $content.html(data);
            var displayFrom=((currentPage-1)* Number(pageSize) +1);
            $('#showResultsFrom').text(displayFrom);
            var displayTo= Number(pageSize) * Number(currentPage);
            if(totalHits<pageSize || displayTo>totalHits){
                $('#showResultsTo').text(totalHits);
            }else{
                $('#showResultsTo').text(displayTo);
            }

            setParameters();
        })
    }

}

function filterClick(category, species,subCat, type, filter, objectAssembly) {

    getParameters();
    if(typeof objectAssembly=='undefined' || objectAssembly=='' )
    objectAssembly= $objectAssembly;

    var $sampleExists;
    var filterType=null;
    if ((typeof filter != 'undefined') && filter!=''){
        filterType=filter;
    }else{
        filterType='type';
    }

    $('#subCat').val(subCat);
    var objectType;

    if(category=="Reference" ){
        objectType="reference"
    }else{
        if(category == "Ontology"){
            objectType="ontology"
        }else{
            objectType=category.toLowerCase()+ "s";
        }

    }

    var toolHeader="<p style='font-weight: bold'>RGD Tools</p><p style='font-size: x-small'>Analyze selected <strong style='color:blue'>"+category +"s"+"</strong> with RGD Tools.</p>";
    var annotationDistribution="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,\'"+species+"\',\'annotDistribution\', \'"+objectType+"\',$('#mapKey').val())\"   style=\"cursor: pointer\"><img class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/gaTool_small.png\" alt=\"Annotation Distribution\" ></a>&nbsp;<span class=\"tooltiptext\" style=\"font-size: x-small\">Send list of genes to find out what percentage of the those genes are annotated to terms from any or all of the ontologies used at RGD. </span><a onclick=\"toolSubmit(this,\'"+species+"\',\'annotDistribution\', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer;font-size: 11px\">Annotation Distribution</a></div></p>";
    var functionalAnnot="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'functionalAnnot', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/functionalAnnotation_small.png\"></a>&nbsp;<span class=\"tooltiptext\" style=\"font-size: x-small\">Send list of genes to view annotations from any or all ontologies used at RGD for those genes and their orthologs</span><a onclick=\"toolSubmit(this,$('#species').val(),'functionalAnnot', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Functional Annotation</a></div></p>";
    var olga= "<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(), 'olga', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/olga_small.png\" ></a>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(), 'olga', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">OLGA</a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send selected list to Object List Generator and Analyzer tool where you combine(i.e., union, intersect or subtract) that list with the results of one or more additional queries.</span></div></p>"
  
    var interviewer="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'interviewer', \'"+objectType+"\',$('#mapKey').val())\"   style=\"cursor: pointer\"><img class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/icon2.png\" ></a>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'interviewer', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">InterViewer</a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send selected list of genes to InterViewer to visualize complex networks of protein-protein binary interactions associated with those genes with associated attribute data and to analyze these networks.</span></div></p>"
    var vv= "<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'vv', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/variantVisualizer_small.png\"></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send your list of genes to the Variant Visualizer tool to view all of the strain-specific variants in those genes (SNVs and indels).</span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'vv', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Variant Visualizer</a></div></p>";
  
    var gviewer="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'gviewer', \'"+objectType+"\', $('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/gviewer_small.png\" ></a><span class=\"tooltiptext\" style=\"font-size: x-small\">See a genome-wide view, i.e. positions relative to the chromosomes, of the objects in your list. </span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'gviewer', \'"+objectType+"\', $('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Genome Viewer</a></div></p>";
    var damage="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'damage', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/damaging_small.png\"></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send your list of genes to view the strain-specific variants in those genes (SNVs and indels) that are predicted to be possibly or probably damaging.</span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'damage', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Damaging Variants</a></div></p>";

    var moet="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'moet', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/images/MOET.png\"></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send your list of genes to multi ontology enrichment tool.</span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'moet', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">MOET</a></div></p>";
 
    var phenominer= "<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'phenominer',\'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/PhenoMinerSmType.png\"></a>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'phenominer',\'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Phenominer</a><span class=\"tooltiptext\" style=\"font-size: x-small\"> Send selected list of strains to the PhenoMiner tool to explore quantitative phenotype measurement data for those strains.</span></div></p>";
    var annotComparison="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'annotComparison',\'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/annotCompare_small.png\" ></a>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'annotComparison',\'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Annotation Comparison</a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send selected list of genes to explore which of those genes are annotated to terms from any <strong>two</strong> of the ontologies used at RGD (Disease, Pathway, Phenotype, Biological Process, Cellular Component, Molecular Function and ChEBI), for example which genes are annotated to both a disease category and a pathway category.</span></div></p>";
    var excel="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'excel', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/excel_small.png\" ></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Allows user to download the selected objects in EXCEL. </span>&nbsp;<a  onclick=\"toolSubmit(this,$('#species').val(),'excel', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Excel Download</a></div></p>";
  //  var   tab="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'tab', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><i class='fa fa-file' aria-hidden='true' style='font-size:30px;color:lightsteelblue'></i></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Allows user to download the selected objects in TAB seperated format. </span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'tab', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Download Tab</a></div></p>";
  //  var csv="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'csv', \'"+objectType+"\')\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/csv.png\" ></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Allows user to download the selected objects in CSV format. </span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'csv')\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">CSV Download</a></div></p>";
    $toolsDiv.html("");
    $category.val(category);
    $species.val(species);

    $content.html('<div style="margin-left:50%"><i class="fa fa-spinner fa-spin" style="font-size:24px;color:dodgerblue"></i></div>');
    var $type=null;
    if(typeof type!="undefined"){
        $type=type;
    }
    var term=$('#searchTerm').val();

   if($objectSearch == "true"){
      $url = "elasticResults.html?term=" + term + "&species=" + species + "&category=" + category+"&page=true&subCat=" + subCat + "&" + filterType + "=" + $type + "&start=" + $start + "&stop=" + $stop + "&chr=" + $chr + "&objectSearch=" + $objectSearch + "&assembly=" +objectAssembly ;
    } if($objectSearch != "true"){
        $url="elasticResults.html?term="+ term+"&species="+species+"&category="+category+"&page=true&subCat=" +subCat+"&"+filterType+"="+$type+ "&start="+$start+"&stop="+$stop+"&chr="+$chr + "&assembly=" +objectAssembly ;
    }
    console.log($url);

    $('.subcategories').css('display', 'block');
    $('#type').val($type);
    $.get($url, function (data, status) {

        $content.html(data);
        $("#filter").val(filterType);
        $('#objectSearch').val($objectSearch);
        $('assembly').val($objectAssembly)
     //   $('#objectSearchAssembly').val($objectSearchAssembly);
        // $('#viewAllBtn').show();
        mapKey=$('#mapKey').val();

        $("body").scrollTop(0);
        $('#viewAll').show();
        $sampleExists=$('#sampleExists').val();
        if(category=="Gene"){
            var html=toolHeader+annotationDistribution+functionalAnnot + olga+annotComparison+excel ; //+csv;

            if(species!='Chinchilla' && species!='Squirrel' && species!='Bonobo'  && species!='Pig'){
                html=html+interviewer+gviewer+moet;

            }
            if(species!='Squirrel' && species!='Bonobo'  && species!='Pig'){
                html=html+moet;

            }
            if(species=='Human' || species=='Rat'){
                html=html+damage+vv;
            }
            $toolsDiv.html(html);
        }
        if(category=="Strain"){
            var htmlStr=toolHeader+phenominer+gviewer+excel; // + csv;
            if($sampleExists>0){
                htmlStr=htmlStr+vv;
            }
            htmlStr= htmlStr+"<p><strong>Legend</strong></p>"+
                "<P><img src='/rgdweb/images/VV_small.gif' >&nbsp;<span style='font-size: x-small'>Inidcates sample data exists in Variant Visualizer</span></P>"+
                "<p> <img src='/rgdweb/images/PM_small.gif' >&nbsp;<span style='font-size: x-small'>Indicates Phenominer data is available</span></p>";
            $toolsDiv.html(htmlStr);
        }
        if(category=="Variant" && species=="Human"){
            $toolsDiv.html(toolHeader+gviewer+excel+vv ); // add csv for next release
        }
        if(category=="QTL"){
            $toolsDiv.html(toolHeader+gviewer+excel );
        }
        if(category=="SSLP"){
            $toolsDiv.html(toolHeader+gviewer+excel );
        }
        if(category=="Reference"){
            $toolsDiv.html(toolHeader+excel);
        }
        if(category=="Ontology" || category=="Cell line" || category=="Promoter"){
            $toolsDiv.html(toolHeader+excel ) ;
        }

    })
}

function initTools(category, species, objectType,mapKey ,$sampleExists){

 var   toolHeader="<p style='font-weight: bold'>RGD Tools</p><p style='font-size: x-small'>Analyze selected <strong style='color:blue'>"+category +"s"+"</strong> with RGD Tools.</p>";
 var   annotationDistribution="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,\'"+species+"\',\'annotDistribution\', \'"+objectType+"\',$('#mapKey').val())\"   style=\"cursor: pointer\"><img class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/gaTool_small.png\" alt=\"Annotation Distribution\" ></a>&nbsp;<span class=\"tooltiptext\" style=\"font-size: x-small\">Send list of genes to find out what percentage of the those genes are annotated to terms from any or all of the ontologies used at RGD. </span><a onclick=\"toolSubmit(this,\'"+species+"\',\'annotDistribution\', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer;font-size: 11px\">Annotation Distribution</a></div></p>";
 var   functionalAnnot="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'functionalAnnot', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/functionalAnnotation_small.png\"></a>&nbsp;<span class=\"tooltiptext\" style=\"font-size: x-small\">Send list of genes to view annotations from any or all ontologies used at RGD for those genes and their orthologs</span><a onclick=\"toolSubmit(this,$('#species').val(),'functionalAnnot', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Functional Annotation</a></div></p>";
 var   olga= "<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(), 'olga', \'"+objectType+"\',$('#mapKey').val() )\"  style=\"cursor: pointer\"><img class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/olga_small.png\" ></a>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(), 'olga', \'"+objectType+"\',$('#mapKey').val() )\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">OLGA</a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send selected list to Object List Generator and Analyzer tool where you combine(i.e., union, intersect or subtract) that list with the results of one or more additional queries.</span></div></p>"
 var  interviewer="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'interviewer', \'"+objectType+"\',$('#mapKey').val())\"   style=\"cursor: pointer\"><img class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/icon2.png\" ></a>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'interviewer', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">InterViewer</a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send selected list of genes to InterViewer to visualize complex networks of protein-protein binary interactions associated with those genes with associated attribute data and to analyze these networks.</span></div></p>"
 var   vv= "<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'vv', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/variantVisualizer_small.png\"></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send your list of genes to the Variant Visualizer tool to view all of the strain-specific variants in those genes (SNVs and indels).</span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'vv', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Variant Visualizer</a></div></p>";
 var   gviewer="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'gviewer', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/gviewer_small.png\" ></a><span class=\"tooltiptext\" style=\"font-size: x-small\">See a genome-wide view, i.e. positions relative to the chromosomes, of the objects in your list. </span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'gviewer', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Genome Viewer</a></div></p>";
 var   damage="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'damage', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/damaging_small.png\"></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send your list of genes to view the strain-specific variants in those genes (SNVs and indels) that are predicted to be possibly or probably damaging.</span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'damage', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Damaging Variants</a></div></p>";

    var   moet="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'moet', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/images/MOET.png\"></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send your list of genes to multi ontology enrichment tool.</span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'moet', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">MOET</a></div></p>";
    
 var   phenominer= "<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'phenominer',\'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/PhenoMinerSmType.png\"></a>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'phenominer', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Phenominer</a><span class=\"tooltiptext\" style=\"font-size: x-small\"> Send selected list of strains to the PhenoMiner tool to explore quantitative phenotype measurement data for those strains.</span></div></p>";
 var   annotComparison="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'annotComparison',\'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/annotCompare_small.png\" ></a>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'annotComparison', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Annotation Comparison</a><span class=\"tooltiptext\" style=\"font-size: x-small\">Send selected list of genes to explore which of those genes are annotated to terms from any <strong>two</strong> of the ontologies used at RGD (Disease, Pathway, Phenotype, Biological Process, Cellular Component, Molecular Function and ChEBI), for example which genes are annotated to both a disease category and a pathway category.</span></div></p>";
 var   excel="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'excel', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/excel_small.png\" ></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Allows user to download the selected objects in EXCEL. </span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'excel', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Excel Download</a></div></p>";
// var   tab="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'tab', \'"+objectType+"\',$('#mapKey').val())\"  style=\"cursor: pointer\"><i class='fa fa-file' aria-hidden='true' style='font-size:30px;color:lightsteelblue'></i></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Allows user to download the selected objects in TAB seperated format. </span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'tab', \'"+objectType+"\',$('#mapKey').val())\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">Download Tab</a></div></p>";
// var   csv="<p><div class=\"tooltips\"><a onclick=\"toolSubmit(this,$('#species').val(),'csv', \'"+objectType+"\')\"  style=\"cursor: pointer\"><img  class=\"boxedTools toolicon\" src=\"/rgdweb/common/images/csv.png\" ></a><span class=\"tooltiptext\" style=\"font-size: x-small\">Allows user to download the selected objects in CSV format. </span>&nbsp;<a onclick=\"toolSubmit(this,$('#species').val(),'csv')\" target=\"_blank\" style=\"cursor: pointer; font-size: 11px\">CSV Download</a></div></p>";
    var html;
    if(category=="Gene"){
         html=toolHeader+annotationDistribution+functionalAnnot + olga+annotComparison+excel ; //+csv;

        if(species!='Chinchilla' && species!='Squirrel' && species!='Bonobo' && species!='Pig'){
            html=html+interviewer+gviewer+moet;
        }
        if(species=='Human' || species=='Rat'){
            html=html+damage+vv;
        }
        if (species=='Pig' || species=='Green Monkey' || species=='Mouse' || species=='Dog'){
            html=html+vv;
        }

    }
    if(category=="Strain"){
        html=toolHeader+phenominer+gviewer+excel ; // + csv;
        if($sampleExists>0){
            html =html+vv;
        }
       html= html+"<p><strong>Legend</strong></p>"+
            "<P><img src='/rgdweb/images/VV_small.gif' >&nbsp;<span style='font-size: x-small'>Inidcates sample data exists in Variant Visualizer</span></P>"+
            "<p> <img src='/rgdweb/images/PM_small.gif' >&nbsp;<span style='font-size: x-small'>Indicates Phenominer data is available</span></p>";

    }
    if(category=="Variant" && species=='Human'){
       html= toolHeader+gviewer+excel+vv ; // add csv for next release
    }
    if(category=="QTL"){
       html=toolHeader+gviewer+excel;
    }
    if(category=="SSLP"){
        html=toolHeader+gviewer+excel;
    }
    if(category=="Reference"){
       html=toolHeader+excel;
    }
    if(category=="Ontology" || category=="Cell line" || category=="Promoter"){
       html=toolHeader+excel ;
    }
    return html;
}

function toolSubmit(_this, species,tool, objectType, mKey, $assembly) {

    var ortholog1, ortholog2, ortholog3, ortholog4,ortholog5, ortholog6, ortholog7, ortholog8,speciesTypeKey, mapKey, objectkey;
    objectkey=objectType=='genes'?1:objectType=='strains'?5:objectType=="qtls"?6:objectType=="sslps"?3:objectType=="variants"?7:objectType=="reference"?12:objectType=="ontology"?0:objectType=="cell lines"?11:objectType=="promoters"?16:"unknown";
    if(species=='Rat'){
        ortholog1=1;
        ortholog2=2;
        ortholog3=4;
        ortholog4=5;
        ortholog5=6;
        ortholog6=7;
        ortholog7=9;
        ortholog8=13;
        speciesTypeKey=3;
        mapKey=360;
    }
    else if(species=='Human'){
        ortholog1=2;
        ortholog2=3;
        ortholog3=4;
        ortholog4=5;
        ortholog5=6;
        ortholog6=7;
        ortholog7=9;
        ortholog8=13;
        speciesTypeKey=1;
       mapKey=38;
    }
    else if(species=='Mouse'){
        ortholog1=1;
        ortholog2=3;
        ortholog3=4;
        ortholog4=5;
        ortholog5=6;
        ortholog6=7;
        ortholog7=9;
        ortholog8=13;
        speciesTypeKey=2;
        mapKey=35;
    }
    else if(species=='Dog'){
        ortholog1=1;
        ortholog2=3;
        ortholog3=4;
        ortholog4=5;
        ortholog5=2;
        ortholog6=7;
        ortholog7=9;
        ortholog8=13;
        speciesTypeKey=6;
        mapKey=631;
    }
    else if(species=='Squirrel'){
        ortholog1=1;
        ortholog2=3;
        ortholog3=4;
        ortholog4=5;
        ortholog5=6;
        ortholog6=2;
        ortholog7=9;
        ortholog8=13;
        speciesTypeKey=7;
        mapKey=720;
    }
    else if(species=='Bonobo'){
        ortholog1=1;
        ortholog2=3;
        ortholog3=4;
        ortholog4=2;
        ortholog5=6;
        ortholog6=7;
        ortholog7=9;
        ortholog8=13;
        speciesTypeKey=5;
        mapKey=511;
    }
    else if(species=='Chinchilla'){
        ortholog1=1;
        ortholog2=3;
        ortholog3=2;
        ortholog4=5;
        ortholog5=6;
        ortholog6=7;
        ortholog7=9;
        ortholog8=13;
        speciesTypeKey=4;
        mapKey=44;}
    else if(species=='Pig'){
        ortholog1=1;
        ortholog2=3;
        ortholog3=2;
        ortholog4=5;
        ortholog5=6;
        ortholog6=7;
        ortholog7=4;
        ortholog8=13;
        speciesTypeKey=9;

        mapKey=911;
    }else if(species=='Green Monkey'){
        ortholog1=1;
        ortholog2=3;
        ortholog3=2;
        ortholog4=5;
        ortholog5=6;
        ortholog6=7;
        ortholog7=4;
        ortholog8=9;

        speciesTypeKey=13;
        mapKey=1311;
    }
    if(mKey!=0){
        mapKey=mKey;
    }

    var selected=   $('.checkedObjects:checked').map(function () {
        return this.value;
    }).get().join(',');
    if(selected!=""){
        var href;
        if(tool=='interviewer') {
            href = "/rgdweb/cytoscape/cy.html?browser=12&species="+speciesTypeKey+"&identifiers=" + selected;
            //_this.href = href;
            window.open(href);
        }
        if(tool=='functionalAnnot') {
            href=  "/rgdweb/ga/ui.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=56&x=36&x=52&x=40&x=31&x=45&x=29&x=32&x=48&x=23&x=33&x=50&x=17&x=2&x=20&x=54&x=57&x=27&x=41&x=35&x=49&x=5&x=55&x=42&x=10&x=38&x=3&x=6&x=15&x=1&x=53&x=37&x=7&x=34&x=43&x=39&x=30&x=4&x=21&x=44&x=14&x=22&x=51&x=16&x=24&ortholog="+
                ortholog1 +"&ortholog=" +ortholog2+"&ortholog=" +ortholog3+"&ortholog=" +ortholog4+"&ortholog=" +ortholog5+"&ortholog=" +ortholog6+"&ortholog=" +ortholog7+"&ortholog=" +ortholog8+
                "&species=" + speciesTypeKey + "&chr=&start=&stop=&mapKey="+mapKey+"&genes=" + selected;
            //_this.href=href;
            window.open(href);
        }
        if(tool=='annotDistribution') {

            href=  "/rgdweb/ga/analysis.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=56&x=36&x=52&x=40&x=31&x=45&x=29&x=32&x=48&x=23&x=33&x=50&x=17&x=2&x=20&x=54&x=57&x=27&x=41&x=35&x=49&x=5&x=55&x=42&x=10&x=38&x=3&x=6&x=15&x=1&x=53&x=37&x=7&x=34&x=43&x=39&x=30&x=4&x=21&x=44&x=14&x=22&x=51&x=16&x=24&ortholog="+ ortholog1 +"&ortholog=" +ortholog2+"&ortholog=" +ortholog3+"&ortholog=" +ortholog4+"&ortholog=" +ortholog5+"&ortholog=" +ortholog6+"&ortholog=" +ortholog7+
                "&species=" + speciesTypeKey +"&chr=&start=&stop=&mapKey="+mapKey+"&genes=" + selected;
           // _this.href=href;
            window.open(href);
        }
        if(tool=='olga') {
            var strainSymbols=   $('.checkedObjects:checked').map(function () {
                return this.getAttribute("data-symbol");
            }).get().join(',');

            if(strainSymbols!=""){
                href="/rgdweb/generator/list.html?mapKey="+ mapKey+"&oKey="+objectkey+"&vv=&ga=&act=&a="+"~lst:" + strainSymbols.replace(/\,/g, '[');
            }else {
                href = "/rgdweb/generator/list.html?mapKey=" + mapKey + "&oKey=" + objectkey + "&vv=&ga=&act=&a=" + "~lst:" + selected.replace(/\,/g, '[');
            }
 //           _this.href=href;
            window.open(href);
        }
        var sampleExists=0;
        $('.checkedObjects:checked').each(function () {

            sampleExists=sampleExists+Number(this.getAttribute("data-sampleExists"));
        });

        if(tool=='vv') {
            if (objectType == 'variants') {
               
                href="variantVisualizer.html?species="+species +"&assembly="+$assembly +"&mapKey="+mapKey +"&rgdIds=" +selected;

               // _this.href = href;
                window.open(href);
            } else {

                var strainSymbols = $('.checkedObjects:checked').map(function () {
                    return this.getAttribute("data-symbol");
                }).get().join(',');


                if (strainSymbols != "") {
                    if (sampleExists > 0) {
                        var f = document.createElement("form");
                        f.setAttribute('method', "post");
                        f.setAttribute('action', "/rgdweb/front/select.html");

                        var i = document.createElement("input"); //input element, text
                        i.setAttribute('type', "hidden");
                        i.setAttribute('name', "rgdIds");
                        i.setAttribute('value', selected);

                        var i2 = document.createElement("input"); //input element, text
                        i2.setAttribute('type', "hidden");
                        i2.setAttribute('name', "mapKey");
                        i2.setAttribute('value', mapKey);

                        f.appendChild(i);
                        f.appendChild(i2);
                        document.getElementsByTagName('body')[0].appendChild(f);
                        f.submit();

                    } else {
                        alert("No sample data available for selected strains ")
                    }
                }
                else {
                    if(species=='Human'){
                        href = "/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=&con=&depthLowBound=8&depthHighBound=&sample1=all&mapKey=" + mapKey + "&geneList=" + selected;
                    }else{
                        href = "/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=&sample1=all&mapKey=" + mapKey + "&geneList=" + selected;
                    }


                    //_this.href = href;
                    window.open(href);
                }
            }
        }
        if(tool=='gviewer') {
            /*   if(objectType=='sslps'){
             objectType='markers'
             }*/
            if (objectType == 'genes') {

                href = "/rgdweb/ga/genome.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=56&x=36&x=52&x=40&x=31&x=45&x=29&x=32&x=48&x=23&x=33&x=50&x=17&x=2&x=20&x=54&x=57&x=27&x=41&x=35&x=49&x=5&x=55&x=42&x=58&x=38&x=3&x=10&x=15&x=1&x=6&x=37&x=7&x=53&x=43&x=39&x=34&x=4&x=21&x=30&x=14&x=22&x=44&x=60&x=24&x=51&x=16&ortholog=" +
                    ortholog1 + "&ortholog=" + ortholog2 + "&ortholog=" + ortholog3 + "&ortholog=" + ortholog4 + "&ortholog=" + ortholog5 + "&ortholog=" + ortholog6 +"&ortholog=" +ortholog7+"&ortholog=" +ortholog8+
                    "&species=" + speciesTypeKey + "&chr=1&start=&stop=&mapKey=" + mapKey + "&genes=" + selected;
            }else{
                href="genomeViewer.html?oKey=" +objectkey +"&mapKey=" +mapKey +"&rgdIds="+ selected+"&species=" + speciesTypeKey;}
            //_this.href=href;
            window.open(href);
        }
        if(tool=='moet') {
            /*   if(objectType=='sslps'){
             objectType='markers'
             }*/
            if (objectType == 'genes') {

                href = "/rgdweb/enrichment/analysis.html"+"?genes=" + selected+ "&species=" + speciesTypeKey +"&o=RDO";
            }
           // _this.href=href;
            window.open(href);
        }
        if(tool=='damage') {
            if(species=='Human')
                href= "/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=&cs_pathogenic=true" + "&mapKey=" + mapKey + "&con=&sample1=all&geneList=" + selected;

            else
                href= "/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=" + "&mapKey=" + mapKey + "&con=&probably=true&possibly=true&depthLowBound=8&depthHighBound=&excludePossibleError=true&sample1=all&geneList=" + selected;
           // _this.href=href;
            window.open(href);
        }
        if(tool=='annotComparison') {
            href= "/rgdweb/ga/termCompare.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=40&x=36&x=52&x=29&x=31&x=45&x=23&x=32&x=48&x=17&x=33&x=50&x=54&x=2&x=20&x=41&x=57&x=27&x=5&x=35&x=49&x=58&x=55&x=42&x=10&x=38&x=3&x=6&x=15&x=1&x=53&x=37&x=7&x=34&x=43&x=39&x=46&x=4&x=21&x=30&x=14&x=22&x=44&x=60&x=24&x=51&x=16&x=56&ortholog="
                +ortholog1 +"&ortholog=" +ortholog2+"&ortholog=" +ortholog3+"&ortholog=" +ortholog4+"&ortholog=" +ortholog5+"&ortholog=" +ortholog6+"&ortholog=" +ortholog7+"&ortholog=" +ortholog8+
                "&species=" + speciesTypeKey+"&term1=RDO%3A0000001&term2=PW%3A0000001&chr=1&start=&stop=&mapKey=" + mapKey +"&genes=" + selected;

           // _this.href=href;
            window.open(href);
        }
        if(tool=='excel') {
            var strainSymbols=   $('.checkedObjects:checked').map(function () {
                return this.getAttribute("data-symbol");
            }).get().join(',');
            if(objectType!='genes' && objectType!='ontology') {

                href="search/excelDownload.html?rgdIds=" +selected +"&oKey=" +objectkey +"&mapKey=" + mapKey+"&format="+"excel";

            }else{
                if(objectType=='genes')
                    href="search/excelDownload.html?rgdIds=" +selected +"&oKey=" +objectkey +"&mapKey=" + mapKey+"&format="+"excel";
              //      href = "/rgdweb/generator/process.html?&mapKey=" + mapKey + "&oKey=" + objectkey + "&vv=&ga=&act=excel&a=" + "~lst:" + selected.replace(/\,/g, '[');
                if(objectType=='ontology')
                    href="search/excelDownload.html?rgdIds=" +selected +"&oKey=" +objectkey+"&format=excel" ;
            }
            //_this.href=href;
            window.open(href);
        }
        if(tool=='tab') {
            var strainSymbols=   $('.checkedObjects:checked').map(function () {
                return this.getAttribute("data-symbol");
            }).get().join(',');
            var rgdids=$('.checkedObjects:checked').map(function () {
                return this.getAttribute("data-rgdids");
            }).get().join(',');
           //     alert(rgdids);

                href="search/excelDownload.html?rgdIds=" +rgdids +"&oKey=" +objectkey +"&mapKey=" + mapKey+"&format=tab";

            //_this.href=href;
            window.open(href);
        }
        var count=0;
        $('.checkedObjects:checked').each(function () {

            count=count+Number(this.getAttribute("data-count"));
        })
        if(tool=='phenominer') {
            if(count>0){
                var f = document.createElement("form");
                f.setAttribute('method',"post");
                f.setAttribute('action',"phenominerLink.html");

                var i = document.createElement("input"); //input element, text
                i.setAttribute('type',"hidden");
                i.setAttribute('name',"rgdIds");
                i.setAttribute('value',selected);

                f.appendChild(i);
                document.getElementsByTagName('body')[0].appendChild(f);
                f.submit();

            }else{
                alert("No phenominer data is available for selected objects");
            }
        }
        if(tool=='JBrowse') {

            var dbJBrowser="data_hg38";
            var tracks="ARGD_curated_genes";
            href="/jbrowse/?data="+dbJBrowser+"&tracks="+tracks+"&highlight=&tracklist=1&nav=1&overview=1&loc="+"Chr"+12+"%3A"+9067708 +".."+9115962   ;
           // _this.href = href;
            window.open(href);
        }
    }
    else{
        alert("Please select one or more objects to analyze")
    }
    return false;
}

function toggle(_this){
    if(_this.checked)
        $('input:checkbox').not(this).prop("checked", true);
    else{
        $('input:checkbox').not(this).prop("checked", false);
    }
}

