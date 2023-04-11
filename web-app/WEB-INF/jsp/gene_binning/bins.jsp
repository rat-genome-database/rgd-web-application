<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.*" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>
<script type="text/javascript" src="/rgdweb/js/dhtmlxTree/dhtmlxcommon.js"></script>
<script type="text/javascript" src="/rgdweb/js/dhtmlxTree/dhtmlxtree.js?1"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/js/dhtmlxTree/dhtmlxtree.css?3"/>
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
        if (document.getElementById('assigneeName').value == "") {
            // alert("Fill All Fields !");
        } else {
            document.getElementById('form').submit();
            // alert("Form Submitted Successfully...");
        }
    }

    //Function To Display Popup
    function div_show() {
        document.getElementById('changeCurator').style.display = "flex";
    }

    //Function to Hide Popup
    function div_hide(){
        document.getElementById('changeCurator').style.display = "none";
    }
</script>

<%--Header of the page--%>
<%@ include file="../../../common/headerarea.jsp" %>

<%--Main Body--%>

<div class="main_body">

<%--    Sidebar for displaying all the bin categories--%>
    <div class="sidebar">
        <h3>Bin Categories</h3>
        <c:forEach var="term" items="${model.assignees}">
            <a href="/rgdweb/geneBinning/bins.html?termAcc=<c:out value="${term.getTermAcc()}"/>&term=<c:out value="${term.getTerm()}"/>"
               style='<c:if test="${term.getCompleted() == 1}">color:red; text-decoration: line-through;</c:if>'>

                <c:if test="${term.getTerm() == 'not annotated'}">
                    <hr>
                </c:if>
                    ${term.getTerm()}- ${term.getTermAcc()}
                    <br>
                    [ <c:choose>
                        <c:when test="${term.getAssignee() != null}">
                            <b>Assigned to: </b> ${term.getCompleted()},
                        </c:when>
                        <c:otherwise>
                            <b>Unassigned</b>,
                        </c:otherwise>
                    </c:choose> <b>Genes: </b>() ]

            </a>
        </c:forEach>
    </div>

<%--    Header, Details about the curator and bin table --%>
    <div class="gene_bin_content">
        <div class="gene_bin_header">
            <h3 style="text-decoration:underline;"><c:out value="${model.termString}"/> (<c:out value="${model.termAccString}"/>)</h3>
            <button style="background-color:#FF7B23;" class="btn btn-info btn-lg">
                <a href="/rgdweb/geneBinning/index.html" style="text-decoration: none; border: none; background-color:#FF7B23; color: white"> << Back</a>
            </button>
        </div>
        <br>
        <c:choose>
            <c:when test="${model.assignee.getAssignee() != null}">
                <div class="assignee_change_form">
                    <h5><b>Curator:</b> <c:out value="${model.assignee.getAssignee()}"/></h5>
                    <button class="change_btn" onclick="div_show()">Change Assignee</button>
                    <a href="/rgdweb/geneBinning/bins.html?termAcc=<c:out value="${model.termAccString}"/>&term=<c:out value="${model.termString}"/>&completed=1">
                        <button class="change_btn">Completed</button>
                    </a>
                </div>

<%--                A pop up form for changing the assignee details --%>
                <div id="changeCurator">
                    <div id="popupChangeCurator">
                        <form id="form" action="/rgdweb/geneBinning/bins.html" method="post" id="form">
                            <h2>Change Curator</h2>
                            <hr>
                            <input type="hidden" name="termAcc" value="${model.termAccString}" />
                            <input type="hidden" name="term" value="${model.termString}" />
                            <h4><b>Curator Name:</b></h4>
                            <input type="text" style="border: 1px solid black; width: 50%;" id="assigneeName" name="assigneeName"/>
                            <div class="popupChangeCuratorButtons">
                                <input type="submit" value="Submit" style="background-color:#FF7B23;" class="btn btn-info btn-lg">
                                <button id="closeForm" onclick ="div_hide()" style="background-color:#FF7B23;" class="btn btn-info btn-lg">Close</button>
                            </div>
                        </form>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="assignee_form">
                    <form action="/rgdweb/geneBinning/bins.html">
                        <input type="hidden" name="termAcc" value="${model.termAccString}" />
                        <input type="hidden" name="term" value="${model.termString}" />
                        <label><b>Assign Bin to Curator:</b></label>
                        <input type="text" name="assigneeName"/>
                        <input type="submit" value="Submit">
                    </form>
                </div>
            </c:otherwise>
        </c:choose>
        <br>

        <script type="text/javascript">
            function tableToCSV() {

                // Variable to store the final csv data
                var csv_data = [];

                // Get each row data
                var rows = document.getElementsByClassName('geneBinTableRow');
                for (var i = 0; i < rows.length; i++) {

                    // Get each column data
                    var cols = rows[i].querySelectorAll('td');

                    // Stores each csv row data
                    var csvrow = [];
                    for (var j = 0; j < 1; j++) {
                        if((cols[j].innerHTML != "&nbsp;") && (cols[j].innerHTML != "")){
                            let curData = cols[j].innerHTML;
                            curData = curData.replace(/\n/g, '').trim();
                            curData+="\n";
                            csvrow.push(curData);
                        }
                    }
                    csv_data.push(csvrow.join(","));
                }
                downloadCSVFile(csv_data);
            }

            function downloadCSVFile(csv_data) {

                // Create CSV file object and feed
                // our csv_data into it
                CSVFile = new Blob([csv_data], {
                    type: "text/csv"
                });

                // Create to temporary link to initiate
                // download process
                var temp_link = document.createElement('a');

                // Download csv file
                temp_link.download = "GeneList.csv";
                var url = window.URL.createObjectURL(CSVFile);
                temp_link.href = url;

                // This link should not be displayed
                temp_link.style.display = "none";
                document.body.appendChild(temp_link);

                // Automatically click the link to
                // trigger download
                temp_link.click();
                document.body.removeChild(temp_link);
            }
        </script>

        <h4><b>Genes (${model.genes.size()})</b>
            <img  style="cursor:pointer;" height=33 width=35 onclick="tableToCSV()" src="https://rgd.mcw.edu/rgdweb/common/images/excel.png"/>
        </h4>



        <div class="bin_content_tree">
            <div class="tableBodyDiv">
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

            <%--        Tree structure--%>

            <div class="dhtmlxTree"
                 id="treeboxbox_tree">
            </div>
<%--            <script>--%>
<%--                var myTree = new dhtmlXTreeObject("treeboxbox_tree","100%","100%",0);--%>
<%--                myTree.setImagePath("/rgdweb/js/dhtmlxTree/imgs/");--%>
<%--                myTree.enableCheckBoxes(true);--%>
<%--                myTree.enableDragAndDrop(true);--%>
<%--                myTree.enableThreeStateCheckboxes(true);--%>
<%--                myTree.loadXMLString('<?xml version="1.0" encoding="iso-8859-1"?><tree id="0"><item text="Lawrence Block" id="t2_lb"><item text="All the Flowers Are Dying" id="lb_1"/><item text="The Burglar on the Prowl" id="lb_2"/><item text="The Plot Thickens" id="lb_3"/><item text="Grifter Game" id="lb_4"/><item text="The Burglar Who Thought He Was Bogart" id="lb_5"/></item><item text="Robert Crais" id="t2_rc" open="1"><item text="The Forgotten Man" id="rc_1"/><item text="Stalking the Angel" id="rc_2"/><item text="Free Fall" id="rc_3"/><item text="Sunset Express" id="rc_4"/> <item text="Hostage" id="rc_5"/></item><item text="Dan Brown" id="t2_db"><item text="Angels &amp; Demons" id="db_1"/><item text="Deception Point" id="db_2"/><item text="Digital Fortress" id="db_3"/><item text="The Da Vinci Code" id="db_4"/><item text="Deception Point" id="db_5"/></item><item  text="Joss Whedon" id="t2_jw"><item text="Astonishing X-Men" id="jw_1"/><item text="Joss Whedon: The Genius Behind Buffy" id="jw_2"/><item text="Fray" id="jw_3"/><item text="Tales Of The Vampires" id="jw_4"/><item text="The Harvest" id="jw_5"/></item></tree>');--%>
<%--            </script>--%>

        </div>

    </div>
</div>

<%--Footer of the Page--%>
<%@ include file="../../../common/footerarea.jsp" %>