
run();



function run() {
    rebuildAnnotationTables();
//in region tables
    addHeadAndIdToTable("qtlAssociationTableDiv", 1);
    addHeadAndIdToTable("geneAssociationTableDiv", 1);
    addHeadAndIdToTable("mark2AssociationTableDiv", 1);

//annotation detail view tables

    let annotDetailTables = document.getElementsByClassName('annotation-detail');

    for(let i = 0; i < annotDetailTables.length; i++){
        addHeadAndIdToTable(annotDetailTables[i].id, 0);
    }

//phenominer values table
    addHeadAndIdToTable("phenominerAssociationTableDiv", 0);

    rebuildReferenceSequenceTables();
    checkForRegionTables();
    checkForAdditionalInfoTables();
    addEventsToSidebar();



    moveAGRLink();

    togglePagersAndSearchBar();

    autoChangeNavHeight();
}

function rebuildAnnotationTables() {
    let tableArray = Array.from(
        document.getElementsByClassName("annotationTable"));

    iterateOverAndAppendNewTables(tableArray);
    removeOldAnnotationTables(tableArray);
}

function rebuildReferenceSequenceTables() {
    let nucleotideRefTable = buildNucleotideReferenceSequencesTable();
    addClassAndId(nucleotideRefTable, 'tablesorter', 'nucleotideReferenceSequencesTable');
    appendTableToDiv(nucleotideRefTable, 'nucleotideReferenceSequencesTableDiv');

    removeBreaks('nucleotideReferenceSequencesTableDiv');


    let proteinRefTable = buildProteinReferenceSequencesTable();
    addClassAndId(proteinRefTable, 'tablesorter', 'proteinReferenceSequencesTable');
    appendTableToDiv(proteinRefTable, 'proteinReferenceSequencesTableDiv');
    removeBreaks('proteinReferenceSequencesTableDiv');
}

function addEventsToSidebar() {
    let sidebar = document.getElementById("reportMainSidebar");

    window.addEventListener("scroll", (event) => {
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

    let toggles = Array.from(document.getElementsByClassName("associationsToggle"));
    toggles.forEach( toggle => {
        if (toggle) {
            toggle.addEventListener("click", (event) => {
                addItemsToSideBar();
            });
        }
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
        if(rows){
            rowArray.push(...rows);

        }
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
    let newTable = buildEmptyTable(false);

    rowArray.forEach(row => {
        newTable.tBodies[0].appendChild(row);
    });

    return newTable;
}

function buildAnnotationTable(rowArray) {

    let newTable = buildEmptyTable(true);
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

function buildEmptyTable(isAnnotationTable){
    let newTable = document.createElement('table');
    let tHead = document.createElement('thead');
    let tBody = document.createElement('tbody');
    //add hidden header rows for the filter to work
    if(isAnnotationTable){
        let tr =document.createElement('tr');
        tHead.append(tr);
        for(let i = 0; i < 3; i++){
            let th = document.createElement('th');
            tr.append(th);
        }
        tr.style.display = 'none';
    }

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
    let scrollPosition = window.pageYOffset;
    let percentScrolled = calculateScrollPercentage(scrollPosition);
    let footer = document.getElementById('footer');
    let footerHeight = footer.offsetHeight;
    let sidebarRect = sidebar.getBoundingClientRect();
    let footerRect = footer.getBoundingClientRect();
    let timeToStop = footerRect.top <= sidebarRect.height;


    if(scrollPosition >= 275){
        sidebar.style.position = "fixed";
        sidebar.style.top = '0';

    }else{
        sidebar.style.position = "relative";
    }

    if(timeToStop){
        // sidebar.style.top = "-15vh";

        sidebar.style.position = "absolute";
        sidebar.style.bottom = footerHeight;
        sidebar.style.top = 'auto';

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
        if(annotationDiv){
            annotationDiv.style.display = 'none';
        }
    }

}
//to remove headers if there are no table displaying
function checkForRegionTables(){
    let regionDiv = document.getElementById('region');
    if(regionDiv){
        let element = regionDiv.nextElementSibling;
        while(element.tagName === "BR"){
            element = element.nextElementSibling;
        }
        if(element.id === "additionalInformation"){
            regionDiv.style.display = 'none';
        }
    }

}
//to remove headers if there are no table displaying
function checkForAdditionalInfoTables(){
    let additionalInfoDiv = document.getElementById('additionalInformation');

    if(additionalInfoDiv){
        let element = additionalInfoDiv.nextElementSibling;

        while(element && element.tagName === "BR"){
            element = element.nextElementSibling;
        }

        if(!element){
            additionalInfoDiv.style.display = 'none';
        }
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

function togglePagersAndSearchBar(){
    let tables = Array.from(document.getElementsByClassName('tablesorter'));
    tables.forEach(table => {
        if(table.rows.length < 10){
            let pagers = findPagers(table);
            let searchBar = findSearchBar(table);
            if(pagers.length > 0){
                changePagerDisplay(pagers);
            }

            if(searchBar){
                searchBar.style.display = 'none';
            }

        }

    });
}

function findPagers(table){
    let wrapperDiv = table.parentElement;
    let pagers = wrapperDiv.getElementsByClassName('modelsViewContent');

    if(pagers.length === 0){
        wrapperDiv = table.parentElement.parentElement;
        if(wrapperDiv.tagName !== "TD"){
            pagers = wrapperDiv.getElementsByClassName('modelsViewContent');

        }

    }
    return pagers;
}

function changePagerDisplay(pagers){
    for(let i = 0; i < pagers.length; i++){
        pagers[i].style.display = "none";
    }
}


function findSearchBar(table){
    let wrapperDiv = table.parentElement;
    let searchBar = wrapperDiv.getElementsByClassName('table-search')[0];

    if(!searchBar){
        wrapperDiv = table.parentElement.parentElement;
        if(wrapperDiv.tagName !== "TD"){
            searchBar = wrapperDiv.getElementsByClassName('table-search')[0];

        }
    }
    return searchBar;
}

function autoChangeNavHeight(){
    let navUl = document.getElementById('navbarUlId');
    let nav = navUl.parentElement;
    let navItems = navUl.children;

    if(navItems.length < 18){
        nav.style.height = 'auto';
    }
}

function filterAnnotations() {
    let input, filter, table, rows, td, i, txtValue;
    table = document.getElementById("annotationTable1");

    input = findSearchBar(table);
    filter = input.value.toUpperCase();
    rows = table.getElementsByTagName("tr");

    // Loop through all table rows, and hide those who don't match the search query
    for (i = 0; i < rows.length; i++) {
        td = rows[i].getElementsByTagName("td")[0];
        if (td) {
            txtValue = td.textContent || td.innerText;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                rows[i].style.display = "";
            } else {
                rows[i].style.display = "none";
            }
        }
    }
}