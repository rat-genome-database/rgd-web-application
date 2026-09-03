
run();



function run() {
    rebuildAnnotationTables();
//in region tables - index 0 now: the link strip above each of these used to be a <table>,
//  which made the data table the second one in the div
    addHeadAndIdToTable("qtlAssociationTableDiv", 0);
    addHeadAndIdToTable("geneAssociationTableDiv", 0);
    addHeadAndIdToTable("mark2AssociationTableDiv", 0);

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

    //marker and reference reports do not have the associationsCurator tables
    if(reportTitle !== "reference" && reportTitle !== "marker" ){
        checkForDetailView();
        addDetailTableNotesTitleInfo();
    }


    addFilterToAnnotationSummaryTables();
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
    insertTableBetweenPagers(nucleotideRefTable, 'nucleotideReferenceSequencesTableDiv');

    removeBreaks('nucleotideReferenceSequencesTableDiv');


    let proteinRefTable = buildProteinReferenceSequencesTable();
    addClassAndId(proteinRefTable, 'tablesorter', 'proteinReferenceSequencesTable');
    insertTableBetweenPagers(proteinRefTable, 'proteinReferenceSequencesTableDiv');
    removeBreaks('proteinReferenceSequencesTableDiv');
}

// These sections are written as: top pager, the source tables, bottom pager. Building the
// paged table MOVES those source tables out from between the pagers (buildRowArrayFromTableArray
// appends each one into a cell of the new table), so the table has to be put back where they
// were. Appending it to the div instead dropped it after the closing pager, which left the two
// pagers rendering back to back - the same "1 to 10 of 13 rows" twice - with the table below both.
function insertTableBetweenPagers(table, divId){
    let div = document.getElementById(divId);
    if(div == null){
        return;
    }

    let pagers = [];
    for(let i = 0; i < div.children.length; i++){
        if(div.children[i].classList.contains('modelsViewContent')){
            pagers.push(div.children[i]);
        }
    }

    if(pagers.length > 1){
        div.insertBefore(table, pagers[pagers.length - 1]);
    } else {
        div.append(table);
    }
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

    // the modern layout keeps the sidebar scrollable at all times
    if(!isModernReportLayout()){
        sidebar.addEventListener("mouseover", (event) => {
            sidebar.style.overflowY = "auto";
        });

        sidebar.addEventListener("mouseout", (event) => {
            sidebar.style.overflowY = "hidden";
        });
    }

    let toggles = Array.from(document.getElementsByClassName("associationsToggle"));
    toggles.forEach( toggle => {
        if (toggle) {
            toggle.addEventListener("click", (event) => {
                addItemsToSideBar();
                tableSorterReport();
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



// Picks the table by position, so it is sensitive to anything else in the div being a
// <table>. Without the guard a missing one throws on table.firstChild, and because run() calls
// this before everything else, the whole report's JS stops there - no sidebar, no pagers.
function addHeadAndIdToTable(tableDivId, tableNumber){
    let div = document.getElementById(tableDivId);
    if(div !== null){
        let tables = div.getElementsByTagName('table');
        let table = tables[tableNumber];
        if(table === undefined || table.rows.length === 0){
            return;
        }
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
    if (!table.className.startsWith(className))
        table.className = className + ' '+table.className;
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
    //this table should have one column
    if(table.parentElement.id === 'congenicAsscociationTableDiv'){
        return buildAnnotationTable(rowArray, 1);
    }

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

function buildAnnotationTable(rowArray, columns = 3) {
    let newTable = buildEmptyTable(true);
    let tr = document.createElement('tr');
    newTable.tBodies[0].appendChild(tr);

    for (let i = 0; i < rowArray.length; i++) {

        if (rowArray[i].hasChildNodes()) {

            if (tr.children.length >= columns) {
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

// reports on the modern layout pin the sidebar with CSS position:sticky, so the
// inline positioning below would only fight it
function isModernReportLayout(){
    let container = document.getElementById('page-container');
    return container !== null && container.classList.contains('rgd-modern-report');
}

function stickifySideBar(sidebar){
    if(isModernReportLayout()){
        return;
    }
    let scrollPosition = window.pageYOffset;
    let percentScrolled = calculateScrollPercentage(scrollPosition);
    let footer = document.getElementById('footer');
    let footerHeight = footer.offsetHeight;
    let sidebarRect = sidebar.getBoundingClientRect();
    let footerRect = footer.getBoundingClientRect();
    let timeToStop = footerRect.top <= sidebarRect.height;

        if(reportTitle.toLowerCase() === "reference"){
            // targets viewports at least 768px wide
            let minMediaQuery = window.matchMedia('(min-width: 768px)');

            // targets viewports at most 767px wide
            let maxMediaQuery = window.matchMedia('(max-width: 767px)');

            if(minMediaQuery.matches){
                if(scrollPosition >= 125){
                    sidebar.style.position = "fixed";
                    sidebar.style.top = '0';

                }else{
                    sidebar.style.position = "relative";
                }
            }

            if(maxMediaQuery.matches){
                if(scrollPosition >= 175){
                    sidebar.style.position = "fixed";
                    sidebar.style.top = '0';

                }else{
                    sidebar.style.position = "relative";
                }
            }

        } else {
        if(scrollPosition >= 275){
            sidebar.style.position = "fixed";
            sidebar.style.top = '0';

        }else{
            sidebar.style.position = "relative";
        }

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
            let text = value.childNodes[0].textContent.trim();


            if(text === "Additional References at PubMed"){
                text = "PubMed References";
            }

            if(text === "Phenotype Values via PhenoMiner"){
                text = "Phenotype Values";
            }

            if(text.includes("Annotations")){
                text = text.replace('Annotations', '').trim();
            }

            // the qualifier goes on an info marker rather than into the link text
            let note = headingNote(value, text);
            text = note.label;

            if(text.length > 27){
                let lastWhiteSpace = text.lastIndexOf(" ");
                text = text.substring(0, lastWhiteSpace);
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

            if(note.note){
                li.classList.add('has-toc-info');
                li.appendChild(buildInfoDot(note.note, 'rgd-toc-info'));
            }

            sidebar.append(li);
        }


    });
}

// A section heading can carry a qualifier the sidebar has no room for - the assembly a
// region was computed against, or a note that a data set is no longer maintained. The sidebar
// caps a label at 27 characters and cuts at the last space, so "miRNA Target Status (No longer
// updated)" used to render as "miRNA Target Status (No longer": truncated mid-bracket.
//
// The qualifier comes either from an explicit marker in the heading (miRnaTargets.jsp) or from
// a trailing "(...)" in its text. Doing the second generically retires the special cases that
// used to be listed here one assembly at a time - "(Rnor_6.0)", "(GRCm38)", "(Rnor 6.0)" -
// which is exactly why "(GRCr8)" leaked into the sidebar when the reference assembly changed.
function headingNote(heading, text){
    let marker = heading.querySelector('.rgdInfoDot');
    if(marker){
        return { label: text.trim(), note: marker.getAttribute('title') || '' };
    }

    let match = text.match(/^(.*[^\s(])\s*\(([^()]+)\)$/);
    if(match){
        return { label: match[1].trim(), note: match[2].trim() };
    }

    return { label: text.trim(), note: '' };
}

// A small "i" that shows its text on hover. Kept as a <span> with a title rather than a button:
// it carries no action, and inside the sidebar the whole row is already a link.
function buildInfoDot(note, className){
    let dot = document.createElement('span');
    dot.className = className;
    dot.setAttribute('title', note);
    dot.setAttribute('aria-label', note);
    dot.setAttribute('role', 'img');
    dot.textContent = 'i';
    return dot;
}

// Every report's main.jsp writes the Annotation heading unconditionally, so it has to be taken
// down when the includes underneath it turned out to produce nothing. Hiding the heading also
// drops it from the sidebar, because addItemsToSideBar skips display:none items.
//
// This used to count .annotationTable across the whole document, but that class is not unique to
// annotations: on strain reports the Substrains, Congenics and Mutants tables carry it too, and
// they sit ABOVE the heading, up in the summary. A strain with substrains and no annotations
// (RGD:68038, say) therefore kept an empty Annotation bar. Count only what is really inside the
// section - the run of siblings between the heading and the next .subTitle.
function checkForAnnotations(){
    let annotationDiv = document.getElementById('annotation');

    if(annotationDiv && !sectionHasContent(annotationDiv)){
        annotationDiv.style.display = 'none';
    }
}

// The report body is a flat list: a .subTitle, then the cards that belong to it, then the next
// .subTitle. A section counts as having something to show if any of those siblings holds a table
// or a card - including one in a hidden branch, since the annotation detail view is display:none
// until the reader asks for it, and its heading still has to be there to be toggled.
//
// Empty sections come through as nothing but <br>, <script> and <style>: the includes run either
// way, they just emit no markup when the object has no data.
function sectionHasContent(heading){
    let node = heading.nextElementSibling;

    while(node && !node.classList.contains('subTitle')){
        if(node.tagName === 'TABLE' || node.classList.contains('light-table-border') ||
           node.querySelector('table, .light-table-border')){
            return true;
        }
        node = node.nextElementSibling;
    }

    return false;
}
//to remove headers if there are no table displaying
function checkForRegionTables(){
    let regionDiv = document.getElementById('region');
    if(regionDiv){
        let element = regionDiv.nextElementSibling;
        // Region is the last thing on the page for some reports; without the null check the
        // loop walked off the end and threw, which aborted the rest of run()
        while(element && element.tagName === "BR"){
            element = element.nextElementSibling;
        }
        if(!element || element.id === "additionalInformation"){
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
    let link;
    if(externalDbTable !== null){
        let rows = externalDbTable.rows;
        // Backwards: deleteRow shifts every later row up, so a forward loop skips the
        // row after each one it removes. That did not show while the table blanked out
        // repeated database names and only one row could ever say "AGR Gene"; now every
        // AGR row carries the name, so more than one can match.
        for(let i = rows.length - 1; i >= 0; i--){
            let cells = rows[i].cells;
            if(cells.length > 1 && cells[0].innerText.trim() === "AGR Gene"){
                link = cells[1].getElementsByTagName('a')[0];
                externalDbTable.deleteRow(i);
            }
        }
    }

    return link;
}
//adds row to top summary
function addAGRLink(link){
    if(link){
        let summary = document.getElementById("info-table");
        let row = summary.insertRow(3);
        let cell1 = row.insertCell(0);
        let cell2 = row.insertCell(1);

        cell1.classList.add('label');
        cell1.innerText = "Alliance Gene:";
        link.removeChild(link.firstChild);
        link.insertAdjacentHTML("beforeend", "<img border='0' src='/rgdweb/common/images/alliance_logo_small.svg'/>" );
        cell2.appendChild(link);

    }
}

function moveAGRLink(){
    let link = removeAGRLink();
    // addAGRLink(link);
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

function manageLocalStorage(){
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const id = urlParams.get('id');
    let savedId = localStorage.getItem('id');
    if(savedId){
        if(id !== savedId){
            localStorage.removeItem('tablesorter-pager');
            localStorage.setItem('id', id);
        }
    }else{
        localStorage.setItem('id', id);
    }

}

function removePagerAutocomplete(){
    let pagerDivs = document.getElementsByClassName('modelsViewContent');
    for(let i = 0; i < pagerDivs.length; i++){
        let form = pagerDivs[i].getElementsByTagName('form')[0];
        form.setAttribute('autocomplete', 'off');
    }
}


function checkForDetailView(){
    let isDetail = assignDetail();
    let text;
    if(isDetail){
       document.getElementById("associationsCurator").style.display="block";
       document.getElementById("associationsStandard").style.display="none";
       text = "Click to see Annotation Summary View";
       updateToggleText(text);
       addItemsToSideBar();
    } else {
        document.getElementById("associationsCurator").style.display="none";
        document.getElementById("associationsStandard").style.display="block";
        text =  "Click to see Annotation Detail View";
        updateToggleText(text);
        addItemsToSideBar();
    }

}

function addFilterToAnnotationSummaryTables(){
    let div = document.getElementById("associationsStandard");
    if(div){
        let tables = Array.from(div.getElementsByClassName('tablesorter'));
        tables.forEach( table => {
            filterTableCells(table);
        })
    }

}

//custom filter that is used on the annotation summary tables
function filterTableCells(table) {
    let input = findSearchBar(table);
    let cells = [];
    let rows, i, txtValue, filter;

    input.addEventListener("input", (event) => {
        filter = input.value.toUpperCase();
        rows = Array.from(table.getElementsByTagName("tr"));
        rows.forEach(row => {
            cells.push(...row.getElementsByTagName("td"));
        });
        for (i = 0; i < cells.length; i++) {
            txtValue = cells[i].innerText;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                cells[i].style.display = "";
                cells[i].parentElement.style.display = "";
            } else {
                cells[i].style.display = "none";

            }

        }
        if(filter.trim() === ""){
            $("#" + table.id).trigger("update");
        }
        cells = [];
    });


}

//this function adds a title attribute to the "more..." links in the annotation detail tables' info section
function addDetailTableNotesTitleInfo(){
    //get all tables with class tablesorter that are within associationsCurator div
    let associationsCurator = document.getElementById("associationsCurator");
    let tableArray = Array.from(associationsCurator.getElementsByClassName("tablesorter"));
    //an array that contains all of the cells in the info column of the associationsCurator tables
    let infoCellArray = [];
    let title = "See all the information about this annotation and the notes for this " + reportTitle;

    //takes all of the cells in the info column in each table and adds them to the infoCellArray
    tableArray.forEach( table => {
        //for each table, access the rows
        let rowsArray = Array.from(table.getElementsByTagName("tr"));
        //for each row, access the td at index 5
        rowsArray.forEach( row => {
            let cells = row.getElementsByTagName("td");
            //add cells to infoCellArray
            infoCellArray.push(cells[5]);
        })
    });

    //finds all off the "more ..." links and adds a title attribute to the <a> element
    infoCellArray.forEach( cell => {
        if( cell !== undefined ) {
            let linksArray = Array.from(cell.getElementsByTagName("a"));
            linksArray.forEach(link => {
                if (link.innerText === "more ...") {
                    link.setAttribute("title", title);
                }
            })
        }
    })

}
