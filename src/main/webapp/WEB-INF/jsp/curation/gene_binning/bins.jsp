<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<link href="/rgdweb/css/geneBin/bins.css" rel="stylesheet" type="text/css"/>
<%
    String pageTitle = "Gene Binning";
    String headContent = "";
    String pageDescription = "Contents of all the bin Categories and their assignee details.";
%>
<script>
    //Function To Display Popup
    function div_show() {
        document.getElementById('abc').style.display = "block";
    }

    // Validating Empty Field
    function check_empty() {
        if (document.getElementById('assigneeName').value != "") {
            document.getElementById('form').submit();
        }
    }

    //Function To Display Popup
    function div_show() {
        document.getElementById('changeCurator').style.display = "flex";
    }

    //Function to Hide Popup
    function div_hide(){
        document.getElementById('assigneeName').value = "${model.assignee.getAssignee()}"
        document.getElementById('changeCurator').style.display = "none";
    }
</script>
<style>
    .clear-all-button {
        padding: 6px 8px;
        border: none;
        border-radius: 4px;
        background-color: #FF0000;
        color: white;
        font-size: 13px;
        cursor: pointer;
        width: 100px;
        transition: background-color 0.2s;
    }
    .clear-all-button:hover {
        background-color: #CC0000;
    }
</style>

<%--Header of the page--%>
<%@ include file="../../../../common/headerarea.jsp" %>

<%--Main Body--%>
<div class="main_body">

<%--    Sidebar for displaying all the bin categories--%>
    <div class="sidebar">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h3>Bin Categories</h3>
            <button class="clear-all-button" onclick="clearAllBins()">
                Clear All
            </button>
        </div>
        <ul class="tree">
            <c:forEach var="term" items="${model.assignees}">
                <c:choose>

<%--                Create Tree structure if the number of genes > 15 count --%>
                    <c:when test="${term.getTotalGenes() > 15 && term.getTermAcc() != 'NA' && term.getTermAcc() == model.termAccString && term.getIsParent()==1}">
                        <div>
                            <details open>
                                    <summary>
                                        <a>
                                            <c:if test="${term.getTerm() == 'not annotated'}">
                                                <hr>
                                            </c:if>
                                                ${term.getTerm()}- ${term.getTermAcc()}
                                            <br>
                                            [
                                            <b>Genes: </b>(${term.getTotalGenes()})
                                            ]
                                        </a>
                                    </summary>
<%--                                Store the children of the bin categories here --%>
                                    <ul>
                                        <c:forEach var="child" items="${model.binChildren.get(term.getTermAcc())}">
                                            <div class="sidebar-row-nested">
                                                <li>
                                                    <a href="/rgdweb/curation/geneBinning/bins.html?accessToken=${model.accessToken}&termAcc=<c:out value="${term.getTermAcc()}"/>&term=<c:out value="${term.getTerm()}"/>&childTermAcc=<c:out value="${child.getTermAcc()}"/>&childTerm=<c:out value="${child.getTerm()}"/>&parent=0&username=${model.username}"
                                                       style='<c:if test="${child.getCompleted() == 1}">color:red; text-decoration: line-through;</c:if>'>
                                                            ${child.getTerm()} - ${child.getTermAcc()}
                                                                <br>
                                                                <c:choose>
                                                                    <c:when test="${child.getAssignee() != null}">
                                                                        <b>Assigned to: </b> ${child.getAssignee()},
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <b>Unassigned</b>,
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <b>Genes: </b>- (${model.childBinCountMap.get(child.getTermAcc())})
                                                    </a>
                                                </li>
                                            </div>
                                        </c:forEach>
                                    </ul>
                                </details>
                        </div>
                    </c:when>
                    <c:when test="${term.getTotalGenes() > 15 && term.getTermAcc() != 'NA' && term.getTermAcc() != model.termAccString  && term.getIsParent()==1}">
                        <div>
                            <details close>
                                <summary>
                                    <a>
                                        <c:if test="${term.getTerm() == 'not annotated'}">
                                            <hr>
                                        </c:if>
                                            ${term.getTerm()}- ${term.getTermAcc()}
                                        <br>
                                        <b>Genes: </b>(${term.getTotalGenes()})

                                    </a>
                                </summary>
<%--                            Store the children of the bin categories here --%>
                                <ul>
                                    <c:forEach var="child" items="${model.binChildren.get(term.getTermAcc())}">
                                        <div class="sidebar-row-nested">
                                            <li>
                                                <a href="/rgdweb/curation/geneBinning/bins.html?accessToken=${model.accessToken}&termAcc=<c:out value="${term.getTermAcc()}"/>&term=<c:out value="${term.getTerm()}"/>&childTermAcc=<c:out value="${child.getTermAcc()}"/>&childTerm=<c:out value="${child.getTerm()}"/>&parent=0&username=${model.username}"
                                                   style='<c:if test="${child.getCompleted() == 1}">color:red; text-decoration: line-through;</c:if>'>
                                                        ${child.getTerm()} - ${child.getTermAcc()}
                                                            <br>
                                                            <c:choose>
                                                                <c:when test="${child.getAssignee() != null}">
                                                                    <b>Assigned to: </b> ${child.getAssignee()},
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <b>Unassigned</b>,
                                                                </c:otherwise>
                                                            </c:choose>
                                                            <b>Genes: </b>- (${model.childBinCountMap.get(child.getTermAcc())})

                                                </a>
                                            </li>
                                        </div>
                                    </c:forEach>
                                </ul>
                            </details>
                        </div>
                    </c:when>
                    <c:when test="${term.getIsParent()==1}">
                        <a href="/rgdweb/curation/geneBinning/bins.html?accessToken=${model.accessToken}&termAcc=<c:out value="${term.getTermAcc()}"/>&term=<c:out value="${term.getTerm()}"/>&parent=1&username=${model.username}"
                               style='<c:if test="${term.getCompleted() == 1}">color:red; text-decoration: line-through;</c:if>'>
                                <div class="sidebar-row">
                                    <c:if test="${term.getTerm() == 'not annotated'}">
                                        <hr>
                                    </c:if>
                                        ${term.getTerm()}- ${term.getTermAcc()}
                                    <br>
                                    <c:choose>
                                        <c:when test="${term.getAssignee() != null}">
                                            <b>Assigned to: </b> ${term.getAssignee()},
                                        </c:when>
                                        <c:otherwise>
                                            <b>Unassigned</b>,
                                        </c:otherwise>
                                      </c:choose>
                                    <b>Genes: </b>(${term.getTotalGenes()})
                                </div>
                            </a>
                    </c:when>
                </c:choose>
            </c:forEach>
        </ul>
    </div>

<%--    Header, Details about the curator and bin table --%>
    <div class="gene_bin_content">
        <div class="gene_bin_header">
            <h3 id="binCategory" style="text-decoration:underline;"><c:out value="${model.termString}"/> (<c:out value="${model.termAccString}"/>)</h3>
            <a href="/rgdweb/curation/geneBinning/index.html?accessToken=${model.accessToken}" class="btn btn-info btn-md" style="text-decoration: none; border: none; background-color:#FF7B23; color: white; width: 100px"> << Back</a>
        </div>
        <c:if test="${model.childTermString != null}">
            <h5><b>Sub Category:</b> <span  id="subBinCategory" style="text-decoration:underline;">
                <c:out value="${model.childTermString}"/> (<c:out value="${model.childTermAccString}"/>)
            </span></h5>
        </c:if>
        <br>
        <br>

        <c:choose>
            <c:when test="${model.assignee.getAssignee() != null}">
                <div class="assignee_change_form">
                    <div class="curator_info">
                        <h5><b>Curator:</b> <c:out value="${model.assignee.getAssignee()}"/></h5>
                    </div>
                    <div class="user_buttons">
                        <c:if test="${model.username == model.assignee.getAssignee()}">
                            <div>
                                <form action="/rgdweb/curation/geneBinning/bins.html">
                                    <input type="hidden" name="termAcc" value="${model.termAccString}" />
                                    <input type="hidden" name="term" value="${model.termString}" />
                                    <input type="hidden" name="parent" value="${model.parent}">
                                    <input type="hidden" name="username" value="${model.username}"/>
                                    <input type="hidden" name="accessToken" value="${model.accessToken}"/>
                                    <c:if test="${model.childTermAccString != null}">
                                        <input type="hidden" name="childTermAcc" value="${model.childTermAccString}" />
                                        <input type="hidden" name="childTerm" value="${model.childTermString}" />
                                    </c:if>
                                    <input type="hidden" name="unassignFlag" value="1"/>
                                    <input class="btn btn-info btn-md" style="background-color:#FF7B23; width: 100px; color: white" type="submit" value="Unassign">
                                </form>
                            </div>
                            <%--                    <button class="btn btn-info btn-md" style="background-color:#FF7B23; color: white" onclick="div_show()">Change Assignee</button>--%>
                            <div>
                                <a href="/rgdweb/curation/geneBinning/bins.html?accessToken=${model.accessToken}&username=${model.username}&termAcc=<c:out value="${model.termAccString}"/>&term=<c:out value="${model.termString}"/>&completed=1&parent=<c:out value="${model.parent}"/><c:if test="${model.childTermAccString != null}">&childTermAcc=${model.childTermAccString}&childTerm=${model.childTermString}</c:if>">
                                    <button class="btn btn-info btn-md" style="background-color:#FF7B23; width: 100px; color: white">Completed</button>
                                </a>
                            </div>
                        </c:if>
                    </div>
                </div>

<%--            A pop up form for changing the assignee details --%>
                <div id="changeCurator">
                    <div id="popupChangeCurator">
                        <form id="form" action="/rgdweb/curation/geneBinning/bins.html" method="post" id="form">
                            <h2>Change Curator</h2>
                            <hr>
                            <input type="hidden" name="termAcc" value="${model.termAccString}" />
                            <input type="hidden" name="term" value="${model.termString}" />
                            <input type="hidden" name="childTermAcc" value="${model.childTermAccString}" />
                            <input type="hidden" name="childTerm" value="${model.childTermString}" />
                            <input type="hidden" name="parent" value="${model.parent}"/>
                            <h4><b>Curator Name:</b></h4>
                            <input type="text" style="border: 1px solid black; width: 50%;" id="assigneeName" name="assigneeName"/>
                            <div class="popupChangeCuratorButtons">
                                <input type="submit" value="Submit" style="background-color:#FF7B23;" class="btn btn-info btn-lg"/>
                                <button id="closeForm" onclick ="div_hide()" style="background-color:#FF7B23;" class="btn btn-info btn-lg">Close</button>
                            </div>
                        </form>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="assignee_form">
                    <form action="/rgdweb/curation/geneBinning/bins.html">
                        <input type="hidden" name="termAcc" value="${model.termAccString}" />
                        <input type="hidden" name="term" value="${model.termString}" />
                        <input type="hidden" name="parent" value="${model.parent}">
                        <input type="hidden" name="username" value="${model.username}"/>
                        <input type="hidden" name="accessToken" value="${model.accessToken}"/>
                        <c:if test="${model.childTermAccString != null}">
                            <input type="hidden" name="childTermAcc" value="${model.childTermAccString}" />
                            <input type="hidden" name="childTerm" value="${model.childTermString}" />
                        </c:if>
                        <input type="hidden" name="assigneeName" value="${model.username}"/>
                        <input class="btn btn-info btn-md" style="background-color:#FF7B23; color: white" type="submit" value="Assign to me">
                    </form>
                </div>
            </c:otherwise>
        </c:choose>
        <br>

        <script type="text/javascript">
            function tableToCSV() {

                // Variable to store the final csv data
                let csv_data = [];

                // Get each row data
                let rows = document.getElementsByClassName('geneBinTableRow');
                for (let i = 0; i < rows.length; i++) {

                    // Get each column data
                    let cols = rows[i].querySelectorAll('td');

                    // Stores each csv row data
                    let csvrow = [];
                    if((cols[0].innerHTML != "&nbsp;") && (cols[0].innerHTML != "")){
                        let curData = cols[0].innerHTML;
                        curData = curData.replace(/\n/g, '').trim();
                        curData+="\n";
                        csvrow.push(curData);
                    }
                    csv_data.push(csvrow.join("\n"));
                }
                downloadCSVFile(csv_data);
            }

            function downloadCSVFile(csv_data) {

                // Create CSV file object and feed csv_data into it
                let CSVFile = new Blob([csv_data], {
                    type: "text/csv"
                });

                // Create to temporary link to initiate download process
                let temp_link = document.createElement('a');

                // Download csv file
                let csvFileName = document.getElementById("binCategory").innerHTML;
                if(document.getElementById("subBinCategory")){
                    csvFileName += document.getElementById("subBinCategory").innerHTML.trim();
                }
                temp_link.download = csvFileName + ".csv";
                let url = window.URL.createObjectURL(CSVFile);
                temp_link.href = url;

                // This link should not be displayed
                temp_link.style.display = "none";
                document.body.appendChild(temp_link);

                // Automatically click the link to trigger download
                temp_link.click();
                document.body.removeChild(temp_link);
            }
        </script>

        <div class="bin_content_tree">
            <div class="tableBodyDiv">
                <h4 style="display: flex;align-items: center;">
                    <span>
                        <b>Genes (${model.genes.size()})  </b>
                        <img  style="cursor:pointer;" height=33 width=35 onclick="tableToCSV()" src="https://rgd.mcw.edu/rgdweb/common/images/excel.png"/>
                    </span>
                </h4>
                <div style="overflow-y: auto">
                    <table class="geneBinTable">
                        <c:forEach var="gene" items="${model.genes}">
                            <tr class="geneBinTableRow">
                                <td class="geneBinTableData">
                                    <c:out value="${gene.getGeneSymbol()}"/>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${(15 - model.genes.size()) > 0}">
                            <c:forEach begin = "${1}" end="${15 - model.genes.size()}">
                                <tr class="geneBinTableRow">
                                    <td class="geneBinTableData">&nbsp</td>
                                </tr>
                            </c:forEach>
                        </c:if>
                    </table>
                </div>
            </div>

<%--        Incorrect Gene List--%>
            <div class="incorrectGeneAndYourBin">
                <c:if test="${model.incorrectGenesList.size() > 0}">
                    <div class="tableBodyDivIncorrectGene">
                        <h4 style="margin-left: auto;"><b>Incorrect Genes List: (${model.incorrectGenesList.size()})</b></h4>
                        <div style="overflow-y: auto">
                            <table class="geneBinTable">
                                <c:forEach var="incorrectGene" items="${model.incorrectGenesList}">
                                    <tr class="geneBinTableRow">
                                        <td class="geneBinTableData">
                                            <c:out value="${incorrectGene}"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </table>
                        </div>
                    </div>
                </c:if>
                <div class="tableBodyDivYourBins">
                    <h4 style="margin-left: auto;"><b>Your bins</b></h4>
                    <div style="overflow-y: auto">
                        <table class="geneBinTable">
                            <c:forEach var="bin" items="${model.assignees}">
                                <c:if test="${bin.getAssignee() == model.username}">
                                    <tr class="geneBinTableRow">
                                        <td class="geneBinTableData">
                                            <c:out value="${bin.getTerm()} - ${bin.getTermAcc()}"/>
                                        </td>
                                    </tr>
                                </c:if>
                            </c:forEach>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    function clearAllBins() {
        if(confirm('Are you sure you want to clear all genes from bins?')) {
            // Create a form dynamically and submit
            let form = document.createElement('form');
            form.method = 'post';
            form.action = '/rgdweb/curation/geneBinning/bins.html';
            // Add required hidden fields
            let fields = {
                'clearAll': 'delete',
                'termAcc': '${model.termAccString}',
                'term': '${model.termString}',
                'parent': '${model.parent}',
                'username': '${model.username}',
                'accessToken': '${model.accessToken}'
            };
            // Add child term fields if they exist
            if('${model.childTermAccString}' !== '') {
                fields['childTermAcc'] = '${model.childTermAccString}';
                fields['childTerm'] = '${model.childTermString}';
            }
            // Create and append hidden inputs
            for(let name in fields) {
                let input = document.createElement('input');
                input.type = 'hidden';
                input.name = name;
                input.value = fields[name];
                form.appendChild(input);
            }
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>

<%--Footer of the Page--%>
<%@ include file="../../../../common/footerarea.jsp" %>