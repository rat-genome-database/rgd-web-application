let tableArray = Array.from(
    document.getElementsByClassName("annotationTable"));

iterateOverAndAppendNewTables(tableArray);
removeOldAnnotationTables(tableArray);
//in region tables
addHeadAndIdToTable("qtlAssociationTableDiv", 1);
addHeadAndIdToTable("geneAssociationTableDiv", 1);
addHeadAndIdToTable("mark2AssociationTableDiv", 1);

//annotation detail view tables
addHeadAndIdToTable("manualAnnotationsTableDiv", 0);
addHeadAndIdToTable("importedAnnotationsClinVarTableDiv", 0);
addHeadAndIdToTable("importedAnnotationsCTDTableDiv", 0);
addHeadAndIdToTable("importedAnnotationsGADTableDiv", 0);
addHeadAndIdToTable("importedAnnotationsMGITableDiv", 0);
addHeadAndIdToTable("importedAnnotationsOMIATableDiv", 0);
addHeadAndIdToTable("importedAnnotationsOMIMTableDiv", 0);
addHeadAndIdToTable("geneChemicalInteractionAnnotationsTableDiv", 0);
addHeadAndIdToTable("biologicalProcessAnnotationsTableDiv", 0);
addHeadAndIdToTable("cellularComponentAnnotationsTableDiv", 0);
addHeadAndIdToTable("molecularFunctionAnnotationsTableDiv", 0);
addHeadAndIdToTable("molecularPathwayManualAnnotationsTableDiv", 0);
addHeadAndIdToTable("importedAnnotationsSMPDBTableDiv", 0);
addHeadAndIdToTable("importedAnnotationsKEGGTableDiv", 0);
addHeadAndIdToTable("importedAnnotationsPIDTableDiv", 0);
addHeadAndIdToTable("importedAnnotationsOtherTableDiv", 0);
addHeadAndIdToTable("mammalianPhenotypeAnnotationsTableDiv", 0);
addHeadAndIdToTable("humanPhenotypeAnnotationsTableDiv", 0);
addHeadAndIdToTable("cellOntologyTableDiv", 0);
addHeadAndIdToTable("mouseAnatomyTableDiv", 0);
addHeadAndIdToTable("ratStrainTableDiv", 0);

//phenominer values table
addHeadAndIdToTable("phenominerAssociationTableDiv", 0);



let nucleotideRefTable = buildNucleotideReferenceSequencesTable();
addClassAndId(nucleotideRefTable, 'tablesorter' ,'nucleotideReferenceSequencesTable');
appendTableToDiv(nucleotideRefTable, 'nucleotideReferenceSequencesTableDiv');

removeBreaks('nucleotideReferenceSequencesTableDiv');


let proteinRefTable = buildProteinReferenceSequencesTable();
addClassAndId(proteinRefTable, 'tablesorter' ,'proteinReferenceSequencesTable');
appendTableToDiv(proteinRefTable, 'proteinReferenceSequencesTableDiv');
removeBreaks('proteinReferenceSequencesTableDiv');

let sidebar = document.getElementById("reportMainSidebar");


window.addEventListener("scroll", (event) =>{
    stickifySideBar(sidebar);
    let domRect = sidebar.getBoundingClientRect();
    let top = domRect.top + document.body.scrollTop;
});

checkForAnnotations();
addItemsToSideBar();

sidebar.addEventListener("mouseover", (event) => {
    sidebar.style.overflowY = "auto";
});

sidebar.addEventListener("mouseout", (event) => {
    sidebar.style.overflowY = "hidden";
});

let toggle = document.getElementById("associationsToggle");
if(toggle != null){
    toggle.addEventListener("click",(event) =>{
        addItemsToSideBar();
    });
}

moveAGRLink();

function removeBreaks(divId){
    let div = document.getElementById(divId);
    if(div != null){
        let breaks = div.getElementsByTagName('br');
        for (let i = 0; i < breaks.length; i++) {
            breaks[i].parentNode.removeChild(breaks[i]);
        }
    }


}

function addClassAndId(table, className, idName){
    table.className = className;
    table.id = idName;
}


function appendTableToDiv(table, divId){
    let div = document.getElementById(divId);
    if(div != null){
        div.append(table);
    }
}



function addHeadAndIdToTable(tableDivId, tableNumber){
    let div = document.getElementById(tableDivId);
    if(div !== null){
        let tables = div.getElementsByTagName('table');
        let table = tables[tableNumber];
        let tHead = document.createElement('thead');
        let tBody = table.firstChild;
        let headerRow = table.rows[0];
        let tableId = tableDivId.substring(0, tableDivId.length-3);
        table.insertBefore(tHead, tBody );
        addClassAndId(table, 'tablesorter', tableId);
        table.firstChild.append(headerRow);
    }

}

function addClassAndId(table, className, idName){
    table.className = className;
    table.id = idName;
}

function iterateOverAndAppendNewTables(tableArray){
    for(let i = 0; i < tableArray.length; i++){
        let table = tableArray[i];
        let parentIdString = table.parentNode.id;
        linkTableWithPager(table, i + 1);
        linkTableWithSearchBar(table, i + 1);
        let newTable = extractRowsAndBuildAnnotationTable(table);
        appendTableToDiv(addClassAndIdToAnnotationTable(newTable, i + 1), parentIdString);
    }
}

function linkTableWithPager(table, pagerNumber){
    let pagers = table.parentNode.parentNode.getElementsByClassName('annotationPagerClass')
    let pager1 = pagers[0];
    let pager2 = pagers[1];

    if(pager1 !== undefined){
        addClassToPagerDiv(pager1, pagerNumber);
    }

    if(pager2 !== undefined){
        addClassToPagerDiv(pager2, pagerNumber);
    }
}

//turn into linkTableWithSeachBar
function linkTableWithSearchBar(table, searchBarNumber){
    let searchBar = table.parentNode.parentNode.getElementsByClassName('search')[0];

    if(searchBar){
        addIdToSearchBar(searchBar, searchBarNumber);
    }

}


function removeOldAnnotationTables(tableArray){
    tableArray.forEach(table => {
        table.remove();
    })
}


function extractRowsAndBuildAnnotationTable(table){
    let rowArray = extractRows(table);
    return buildAnnotationTable(rowArray);
}

function extractRows(parentTable){

    let rowArray = [];
    let tableArray = [];
    let tableCells = parentTable.rows[0].cells;
    for(let i =0; i < tableCells.length; i++){
        tableArray.push(tableCells[i].childNodes[0])

    }
    tableArray.forEach(table => {
        let rows = table.rows;
        rowArray.push(...rows);
    });

    return rowArray;
}

function buildRowArrayFromTableArray(tableArray){
    let rowArray = [];

    //iterate over tables
    tableArray.forEach(table => {
        let tr = document.createElement('tr');
        let td = document.createElement('td');
        td.append(table);
        tr.append(td);
        rowArray.push(tr);
    });
    return rowArray;
}

function buildProteinReferenceSequencesTable(){
    let tableArray = Array.from(
        document.getElementsByClassName('proteinReferenceSequencesInnerTable'));
    let rowArray = buildRowArrayFromTableArray(tableArray);
    return buildReferenceTable(rowArray);
}

function buildNucleotideReferenceSequencesTable(){
    let tableArray = Array.from(
        document.getElementsByClassName('nucleotideReferenceSequencesInnerTable')
    );
    let rowArray = buildRowArrayFromTableArray(tableArray);
    if(tableArray[0] !== undefined){
        tableArray[0].remove();
    }

    return buildReferenceTable(rowArray);
}

function buildReferenceTable(rowArray){
    let newTable = buildEmptyTable();

    rowArray.forEach(row => {
        newTable.tBodies[0].appendChild(row);
    });

    return newTable;
}

function buildAnnotationTable(rowArray) {

    let newTable = buildEmptyTable();
    let tr = document.createElement('tr');
    newTable.tBodies[0].appendChild(tr);

    for (let i = 0; i < rowArray.length; i++) {

        if (rowArray[i].hasChildNodes()) {

            if (tr.children.length >= 3) {
                tr = document.createElement('tr');
                newTable.tBodies[0].appendChild(tr);
            }

            let tableData = rowArray[i].children;
            let td = document.createElement('td');
            tr.appendChild(td);
            for (let j = 0; j < tableData.length; j++) {
                td.innerHTML += tableData[j].innerHTML + " ";
            }
        }
    }

    return newTable;


}

function buildEmptyTable(){
    let newTable = document.createElement('table');
    let tHead = document.createElement('thead');
    let tBody = document.createElement('tbody');
    let tr =document.createElement('tr');
    tHead.append(tr);
    for(let i = 0; i < 3; i++){
        let th = document.createElement('th');
        tr.append(th);
    }

    tr.style.display = 'none';
    newTable.appendChild(tHead);
    newTable.appendChild(tBody);

    return newTable;
}

//add classes and ids to that new table
function addClassAndIdToAnnotationTable(table, tableNumber){
    table.classList.add('tablesorter');
    table.classList.add('annotationTable');
    table.id = "annotationTable" + tableNumber.toString();
    return table;
}

function addClassToPagerDiv(pager, pagerNumber){
    let pagerClassName = "annotationPager" + pagerNumber.toString();
    pager.classList.add(pagerClassName);
    return pager;
}

function addIdToSearchBar(searchBar, searchBarNumber){
    searchBar.id = "annotationSearch" + searchBarNumber.toString();
    return searchBar;
}

function stickifySideBar(sidebar){
    //get element
    let scrollPosition = window.pageYOffset;
    let percentScrolled = calculateScrollPercentage(scrollPosition);

    if(scrollPosition >= 275){
        sidebar.style.position = "fixed";
        sidebar.style.top = "0";
    }else{
        sidebar.style.position = "relative";
    }

    if(percentScrolled >= 99){
        sidebar.style.top = "-15vh";
    }

}

function calculateScrollPercentage(currentPosition){
    let documentHeight = $( document ).height();
    let windowHeight = window.innerHeight;

    let scrollableHeight = documentHeight - windowHeight;
    let percentScrolled = Math.floor((currentPosition * 100) / scrollableHeight);
    return percentScrolled;
}

function addItemsToSideBar(){
    $('.subTitle').addClass("sidebar-item");
    $('.sectionHeading').addClass("sidebar-item");
    let sidebar = document.getElementById('navbarUlId');
    removeAllChildNodes(sidebar);
    $('.sidebar-item').each(function(index, value){
        let parent;
        let curator = document.getElementById('associationsCurator');
        let standard = document.getElementById('associationsStandard');

        if(checkIfParent(curator, value)){
            parent = document.getElementById('associationsCurator');
        }else if(checkIfParent(standard, value)){
            parent = document.getElementById('associationsStandard');
        } else {
            parent = value.parentNode;
        }

        if(parent.style.display !== "none" && value.style.display !== "none"){

            let text = value.childNodes[0].textContent;

            if(text === "Gene-Chemical Interaction Annotations"){
                text = "Gene-Chemical Interaction";
            }

            if(text === "Molecular Pathway Annotations"){
                text = "Molecular Pathway";
            }

            if(text === "QTLs in Region (Rnor_6.0)"){
                text = "QTLs in Region";
            }

            if(text === "Strain Sequence Variants (Rnor 6.0)"){
                text = "Strain Sequence Variants";
            }


            let li = document.createElement('li');
            let a  = document.createElement('a');
            li.classList.add('nav-item');
            if(value.classList.contains('sectionHeading')) {
                li.classList.add('sub-nav-item');
            }
            a.classList.add('nav-link');
            a.setAttribute('href', '#' + value.id);
            a.innerText = text;
            li.appendChild(a);

            sidebar.append(li);
        }


    });
}

function checkForAnnotations(){
    //get all the tables with annotationTable class
    let annotationTables = Array.from(document.getElementsByClassName('annotationTable'));

    //if list == 0,
    if(annotationTables.length === 0){
        //make Annotations div display == none
        let annotationDiv = document.getElementById('annotation');
        annotationDiv.style.display = 'none';
    }

}

function removeAllChildNodes(parent) {
    while (parent.lastElementChild){
        if(parent.lastElementChild.isEqualNode(document.getElementById('summary'))){
            break;
        }
        parent.removeChild(parent.lastElementChild);
    }
}

function checkIfParent(parent, value){
    if(parent != null){
        if(parent.contains(value)){
            return true;
        }else {
            return false;
        }
    }
    return false;
}

//removes row from xdbs table
function removeAGRLink(){
    let externalDbTable = document.getElementById('externalDatabaseLinksTable');
    let accId;
    if(externalDbTable !== null){
        let rows = externalDbTable.rows;
        for(let i = 0; i < rows.length; i++){
            let row = rows[i];
            let cells = row.cells;
            if(cells[0].innerText === "AGR Gene"){
                accId = cells[1].innerHTML;
                externalDbTable.deleteRow(i);
            }
        }
    }

    return accId;
}
//adds row to top summary
function addAGRLink(accId){
    if(accId){
        let summary = document.getElementById("info-table");
        let row = summary.insertRow(3);
        let cell1 = row.insertCell(0);
        let cell2 = row.insertCell(1);

        cell1.classList.add('label');
        cell1.innerText = "Alliance Gene:";
        cell2.innerHTML = accId;
    }
}

function moveAGRLink(){
    let accId = removeAGRLink();
    addAGRLink(accId);
}
// $(function () {
//
//     $('#annotationTable1')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#annotationSearch1',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.annotationPager1'),
//             size: 20
//         });
//
//     $('#annotationTable2')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#annotationSearch2',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.annotationPager2'),
//             size: 20
//         });
//
//     $('#annotationTable3')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#annotationSearch3',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.annotationPager3'),
//             size: 20
//         });
//
//     $('#annotationTable4')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#annotationSearch4',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.annotationPager4'),
//             size: 20
//         });
//
//     $('#annotationTable5')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#annotationSearch5',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.annotationPager5'),
//             size: 20
//         });
//
//     $('#annotationTable6')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#annotationSearch6',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.annotationPager6'),
//             size: 20
//         });
//
//     $('#annotationTable7')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#annotationSearch7',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.annotationPager7'),
//             size: 20
//         });
//
//
//     $('#annotationTable8')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#annotationSearch8',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.annotationPager8'),
//             size: 20
//         });
//
//     $('#annotationTable9')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#annotationSearch9',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.annotationPager9'),
//             size: 20
//         });
//     //annotation detail view tables
//
//     $('#manualAnnotationsTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#manualAnnotationsSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.manualAnnotationsPager'),
//             size: 20
//         });
//
//     $('#importedAnnotationsClinVarTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsClinVarSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsClinVarPager'),
//             size: 20
//         });
//
//     $('#importedAnnotationsCTDTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsCTDSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsCTDPager'),
//             size: 20
//         });
//     $('#importedAnnotationsGADTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsGADSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsGADPager'),
//             size: 20
//         });
//
//     $('#importedAnnotationsMGITable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: [ 'filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsMGISearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsMGIPager'),
//             size: 20
//         });
//     $('#importedAnnotationsOMIATable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsOMIASearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsOMIAPager'),
//             size: 20
//         });
//
//     $('#importedAnnotationsOMIMTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsOMIMSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsOMIMPager'),
//             size: 20
//         });
//
//     $('#geneChemicalInteractionAnnotationsTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#geneChemicalInteractionAnnotationsSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.geneChemicalInteractionAnnotationsPager'),
//             size: 20
//         });
//
//     $('#biologicalProcessAnnotationsTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#biologicalProcessAnnotationsSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.biologicalProcessAnnotationsPager'),
//             size: 20
//         });
//
//     $('#cellularComponentAnnotationsTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#cellularComponentAnnotationsSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.cellularComponentAnnotationsPager'),
//             size: 20
//         });
//
//     $('#molecularFunctionAnnotationsTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#molecularFunctionAnnotationsSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.molecularFunctionAnnotationsPager'),
//             size: 20
//         });
//
//     $('#molecularPathwayManualAnnotationsTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#molecularPathwayManualAnnotationsSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.molecularPathwayManualAnnotationsPager'),
//             size: 20
//         });
//
//     $('#importedAnnotationsSMPDBTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsSMPDBSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsSMPDBPager'),
//             size: 20
//         });
//     $('#importedAnnotationsKEGGTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsKEGGSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsKEGGPager'),
//             size: 20
//         });
//     $('#importedAnnotationsPIDTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsPIDSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsPIDPager'),
//             size: 20
//         });
//     $('#importedAnnotationsOtherTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#importedAnnotationsOtherSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.importedAnnotationsOtherPager'),
//             size: 20
//         });
//     $('#mammalianPhenotypeAnnotationsTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#mammalianPhenotypeAnnotationsSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.mammalianPhenotypeAnnotationsPager'),
//             size: 20
//         });
//     $('#humanPhenotypeAnnotationsTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#humanPhenotypeAnnotationsSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.humanPhenotypeAnnotationsPager'),
//             size: 20
//         });
//     $('#cellOntologyTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#cellOntologySearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.cellOntologyPager'),
//             size: 20
//         });
//     $('#mouseAnatomyTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: [, 'filter'],
//             widgetOptions : {
//                 filter_external : '#mouseAnatomySearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.mouseAnatomyPager'),
//             size: 20
//         });
//     $('#ratStrainTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['filter'],
//             widgetOptions : {
//                 filter_external : '#ratStrainSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.ratStrainPager'),
//             size: 20
//         });
//
//     $('#pubMedReferencesTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra']
//         })
//         .tablesorterPager({
//             container: $('.pubMedReferencesPager'),
//             size: 10
//         });
//
//
//     $('#referencesCuratedTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#referencesCuratedSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.referencesCuratedPager'),
//             size: 20
//         });
//
//
//     $('#qtlAssociationTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#qtlAssociationSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.qtlAssociationPager'),
//             size: 10
//         });
//
//
//     $('#geneAssociationTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#geneAssociationSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.geneAssociationPager'),
//             size: 20
//         });
//
//     $('#mark2AssociationTable')
//         .tablesorter({
//             theme: 'blue',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#mark2AssociationSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.mark2AssociationPager'),
//             size: 20
//         });
//
//     $('#strainSequenceVariantsTable')
//         .tablesorter({
//             theme: 'dropbox',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#strainSequenceVariantsSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.strainSequenceVariantsPager'),
//             size: 5
//         });
//
//
//     $('#nucleotideReferenceSequencesTable')
//         .tablesorter({
//             theme: 'dropbox',
//             widgets: ['zebra', 'filter']
//         })
//         .tablesorterPager({
//             container: $('.nucleotideReferenceSequencesPager'),
//             size: 5
//         });
//
//     $('#proteinReferenceSequencesTable')
//         .tablesorter({
//             theme: 'dropbox',
//             widgets: ['zebra', 'filter']
//         })
//         .tablesorterPager({
//             container: $('.proteinReferenceSequencesPager'),
//             size: 5
//         });
//
//     $('#nucleotideSequencesTable')
//         .tablesorter({
//             theme: 'dropbox',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#nucleotideSequencesSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.nucleotideSequencesPager'),
//             size: 30
//         });
//
//     $('#proteinSequencesTable')
//         .tablesorter({
//             theme: 'dropbox',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#proteinSequencesSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.proteinSequencesPager'),
//             size: 30
//         });
//
//
//     $('#clinicalVariantsTable')
//         .tablesorter({
//             theme: 'dropbox',
//             widget: ['zebra']
//         })
//         .tablesorterPager({
//             container: $('#clinicalVariantsPager')
//         });
//
//     $('#externalDatabaseLinksTable')
//         .tablesorter({
//             theme: 'dropbox',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#externalDatabaseLinksSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.externalDatabaseLinksPager'),
//             size: 40
//         });
//     $('#strainQtlAssociationTable')
//         .tablesorter({
//             theme: 'dropbox',
//             widgets: ['zebra', 'filter'],
//             widgetOptions : {
//                 filter_external : '#strainQtlAssociationSearch',
//                 filter_columnFilters: false
//             }
//         })
//         .tablesorterPager({
//             container: $('.strainQtlAssociationPager'),
//             size: 20
//         });
//     $('#phenominerAssociationTable')
//         .tablesorter({
//             theme: 'dropbox',
//             widget: ['zebra']
//         })
//         .tablesorterPager({
//             container: $('.phenominerAssociationPager'),
//             size: 30
//         });
//
//
// });
