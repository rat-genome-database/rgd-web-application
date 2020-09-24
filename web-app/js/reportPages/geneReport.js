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


// sidebar.style.position = "relative";
window.addEventListener("scroll", (event) =>{
    stickifySideBar(sidebar);
    let domRect = sidebar.getBoundingClientRect();
    let top = domRect.top + document.body.scrollTop;
});
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

    newTable.appendChild(tHead);
    newTable.appendChild(tBody);

    return newTable;
}

//add classes and ids to that new table
function addClassAndIdToAnnotationTable(table, tableNumber){
    table.className = 'tablesorter';
    table.id = "annotationTable" + tableNumber.toString();
    return table;
}

function addClassToPagerDiv(pager, pagerNumber){
    let pagerClassName = "annotationPager" + pagerNumber.toString();
    pager.classList.add(pagerClassName);
    return pager;
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

        if(parent.style.display !== "none"){

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

$(function () {

    $('#annotationTable1')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.annotationPager1'),
            size: 20
        });

    $('#annotationTable2')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.annotationPager2'),
            size: 20
        });

    $('#annotationTable3')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.annotationPager3'),
            size: 20
        });

    $('#annotationTable4')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.annotationPager4'),
            size: 20
        });

    $('#annotationTable5')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.annotationPager5'),
            size: 20
        });

    $('#annotationTable6')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.annotationPager6'),
            size: 20
        });

    $('#annotationTable7')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.annotationPager7'),
            size: 20
        });


    $('#annotationTable8')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.annotationPager8'),
            size: 20
        });

    $('#annotationTable9')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.annotationPager9'),
            size: 20
        });
    //annotation detail view tables

    $('#manualAnnotationsTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.manualAnnotationsPager'),
            size: 20
        });

    $('#importedAnnotationsClinVarTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsClinVarPager'),
            size: 20
        });

    $('#importedAnnotationsCTDTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsCTDPager'),
            size: 20
        });
    $('#importedAnnotationsGADTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsGADPager'),
            size: 20
        });

    $('#importedAnnotationsMGITable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsMGIPager'),
            size: 20
        });
    $('#importedAnnotationsOMIATable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsOMIAPager'),
            size: 20
        });

    $('#importedAnnotationsOMIMTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsOMIMPager'),
            size: 20
        });

    $('#geneChemicalInteractionAnnotationsTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.geneChemicalInteractionAnnotationsPager'),
            size: 20
        });

    $('#biologicalProcessAnnotationsTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.biologicalProcessAnnotationsPager'),
            size: 20
        });

    $('#cellularComponentAnnotationsTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.cellularComponentAnnotationsPager'),
            size: 20
        });

    $('#molecularFunctionAnnotationsTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.molecularFunctionAnnotationsPager'),
            size: 20
        });

    $('#molecularPathwayManualAnnotationsTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.molecularPathwayManualAnnotationsPager'),
            size: 20
        });

    $('#importedAnnotationsSMPDBTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsSMPDBPager'),
            size: 20
        });
    $('#importedAnnotationsKEGGTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsKEGGPager'),
            size: 20
        });
    $('#importedAnnotationsPIDTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsPIDPager'),
            size: 20
        });
    $('#importedAnnotationsOtherTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.importedAnnotationsOtherPager'),
            size: 20
        });
    $('#mammalianPhenotypeAnnotationsTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.mammalianPhenotypeAnnotationsPager'),
            size: 20
        });
    $('#humanPhenotypeAnnotationsTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.humanPhenotypeAnnotationsPager'),
            size: 20
        });
    $('#cellOntologyTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.cellOntologyPager'),
            size: 20
        });
    $('#mouseAnatomyTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.mouseAnatomyPager'),
            size: 20
        });
    $('#ratStrainTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.ratStrainPager'),
            size: 20
        });

    $('#pubMedReferencesTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.pubMedReferencesPager'),
            size: 10
        });


    $('#referencesCuratedTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.referencesCuratedPager'),
            size: 20
        });


    $('#qtlAssociationTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.qtlAssociationPager'),
            size: 10
        });

    $('#geneAssociationTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.geneAssociationPager'),
            size: 20
        });

    $('#mark2AssociationTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.mark2AssociationPager'),
            size: 20
        });

    $('#strainSequenceVariantsTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.strainSequenceVariantsPager'),
            size: 5
        });
    

    $('#nucleotideReferenceSequencesTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.nucleotideReferenceSequencesPager'),
            size: 5
        });

    $('#proteinReferenceSequencesTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.proteinReferenceSequencesPager'),
            size: 5
        });

    $('#nucleotideSequencesTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.nucleotideSequencesPager'),
            size: 30
        });

    $('#proteinSequencesTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.proteinSequencesPager'),
            size: 30
        });


    $('#clinicalVariantsTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#clinicalVariantsPager')
        });

    $('#externalDatabaseLinksTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.externalDatabaseLinksPager'),
            size: 40
        });
    $('#strainQtlAssociationTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.strainQtlAssociationPager'),
            size: 20
        });
    $('#phenominerAssociationTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('.phenominerAssociationPager'),
            size: 30
        });


});
