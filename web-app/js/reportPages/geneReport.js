
let tableArray = Array.from(
    document.getElementsByClassName("annotationTable"));


iterateOverAndAppendNewTables(tableArray);
addHeadAndIdToQtlTable();
removeOldAnnotationTables(tableArray);


let nucleotideRefTable = buildNucleotideReferenceSequencesTable();
addClassAndId(nucleotideRefTable, 'tablesorter' ,'nucleotideReferenceSequencesTable');
appendTableToDiv(nucleotideRefTable, 'nucleotideReferenceSequencesTableDiv');

removeBreaks('nucleotideReferenceSequencesTableDiv');


let proteinRefTable = buildProteinReferenceSequencesTable();
addClassAndId(proteinRefTable, 'tablesorter' ,'proteinReferenceSequencesTable');
appendTableToDiv(proteinRefTable, 'proteinReferenceSequencesTableDiv');
removeBreaks('proteinReferenceSequencesTableDiv');


function removeBreaks(divId){
    let div = document.getElementById(divId)
    let breaks = div.getElementsByTagName('br');

    for (let i = 0; i < breaks.length; i++) {
        breaks[i].parentNode.removeChild(breaks[i]);
    }
}

function addClassAndId(table, className, idName){
    table.className = className;
    table.id = idName;
}


function appendTableToDiv(table, divId){
    let div = document.getElementById(divId);
    div.append(table);
}


function addHeadAndIdToQtlTable(){
    let qtlDiv = document.getElementById('qtlAssociationTableDiv');
    if(qtlDiv !== null){
        let qtlTables = qtlDiv.getElementsByTagName('table');
        let table = qtlTables[1];
        let tHead = document.createElement('thead');
        let tBody = table.firstChild;
        let headerRow = table.rows[0];
        table.insertBefore(tHead, tBody );
        table.className = 'tablesorter';
        table.id = "qtlAssociationTable";
        table.firstChild.append(headerRow);
    }

}
function iterateOverAndAppendNewTables(tableArray){
    for(let i = 0; i < tableArray.length; i++){
        let table = tableArray[i];
        let pager = table.parentNode.getElementsByClassName('annotationPagerClass')[0];
        let parentIdString = table.parentNode.id;
        if(pager !== undefined){
            addIdToPagerDiv(pager, i + 1);
        };

        let newTable = tableBreakdownAndCreation(table);
        appendTable(addClassAndIdToAnnotationTable(newTable, i + 1), parentIdString);
    }
}

function removeOldAnnotationTables(tableArray){
    tableArray.forEach(table => {
        table.remove();
    })
}

function appendTable(table, parentIdString){
    document.getElementById(parentIdString)
        .appendChild(table);
}


function tableBreakdownAndCreation(table){
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
    return buildReferenceTable(rowArray);
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

function buildReferenceTable(rowArray){
    let newTable = document.createElement('table');
    let tHead = document.createElement('thead');
    let tBody = document.createElement('tbody');

    newTable.appendChild(tHead);
    newTable.appendChild(tBody);

    rowArray.forEach(row => {
        tBody.appendChild(row);
    });


    return newTable;
}


function buildAnnotationTable(rowArray){

    let newTable = document.createElement('table');
    let tHead = document.createElement('thead');
    let tBody = document.createElement('tbody');

    newTable.appendChild(tHead);
    newTable.appendChild(tBody);


    for(let i = 0; i < rowArray.length; i += 2){
        let tr = document.createElement('tr');
        tBody.appendChild(tr);
        tr.appendChild(rowArray[i].childNodes[0]);
        tr.appendChild(rowArray[i].childNodes[0]);
        if((i + 1) !== rowArray.length){
            tr.appendChild(rowArray[i + 1].childNodes[0]);
            tr.appendChild(rowArray[i + 1].childNodes[0]);
        }


    }
    return newTable;
}
//add classes and ids to that new table
function addClassAndIdToAnnotationTable(table, tableNumber){
    table.className = 'tablesorter';
    table.id = "annotationTable" + tableNumber.toString();
    return table;
}

function addIdToPagerDiv(pager, pagerNumber){
    pager.id = "annotationPager" + pagerNumber.toString();
    return pager;
}


$(function () {

    $('#annotationTable1')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#annotationPager1'),
            size: 10
        });

    $('#annotationTable2')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#annotationPager2'),
            size: 10
        });

    $('#annotationTable3')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#annotationPager3'),
            size: 10
        });

    $('#annotationTable4')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#annotationPager4'),
            size: 10
        });

    $('#annotationTable5')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#annotationPager5'),
            size: 10
        });

    $('#annotationTable6')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#annotationPager6'),
            size: 10
        });

    $('#annotationTable7')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#annotationPager7'),
            size: 10
        });

    $('#referencesCuratedTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#referencesCuratedPager'),
            size: 10
        });
    $('#pubMedReferencesTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#pubMedReferencesPager')
        });

    $('#comparativeMapDataTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#comparativeMapDataPager'),
            size: 3
        });

    $('#qtlAssociationTable')
        .tablesorter({
            theme: 'blue',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#qtlAssociationPager'),
            size: 10
        });

    $('#strainSequenceVariantsTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#strainSequenceVariantsPager'),
            size: 5
        });

    $('#positionMarkersTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#positionMarkersPager'),
            size: 3
        });

    $('#nucleotideReferenceSequencesTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#nucleotideReferenceSequencesPager'),
            size: 3
        });

    $('#proteinReferenceSequencesTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#proteinReferenceSequencesPager'),
            size: 3
        });

    $('#nucleotideSequencesTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#nucleotideSequencesPager'),
            size: 10
        });

    $('#proteinSequencesTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#proteinSequencesPager'),
            size: 10
        });

    $('#externalDatabaseLinksTable')
        .tablesorter({
            theme: 'dropbox',
            widget: ['zebra']
        })
        .tablesorterPager({
            container: $('#externalDatabaseLinksPager')
        });


});
