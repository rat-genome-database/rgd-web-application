<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%
    String pageTitle = "Phenominer Unit Tables";
    String headContent = "";
    String pageDescription = "";
%>

<link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

<style>
    /* Create two equal columns that floats next to each other */
    .columnTbll {
        width: 49%;
        padding: 10px;
        max-height: 600px;
        overflow: auto;
    }

    .columnTblr {
        width: 47%;
        padding: 10px;
        max-height: 600px;
        overflow: auto;
    }

    .rowTbl {
        border-style: none;
        display:flex;
        flex-direction:row;
        overflow: auto;
        width : 100%
    }

    .tableFixHead {
        width: 100%;
        overflow-y: auto;
        height: 500px;
    }
    .tableFixHead thead tr td {
        position: sticky;
        top: 0;
    }
    table {
        border-collapse: collapse;
        width: 100%;
    }

    div.wrapper{ /*overwrite header css to accomodate floating divs(all 3 tables inside the border)*/
        height: 1500px;
    }
</style>
<script  type="text/javascript">
    function submitPage(actionValue) {
        document.phenominerUnitEnumTablesForm.action = actionValue;
        document.phenominerUnitEnumTablesForm.submit();
    }

    function resetPage(actionValue){
        document.phenominerUnitEnumTablesForm.action = actionValue;
        document.phenominerUnitEnumTablesForm.submit();
    }
</script>

<%@ include file="editHeader.jsp"%>
<span class="phenominerPageHeader">Phenominer Unit-Enum Tables</span>
<div class="phenoNavBar"></div>

<form id="phenominerUnitEnumTablesForm" name="phenominerUnitEnumTablesForm" action="phenominerUnitTables.html" method="Get">
    <div class="rowTbl">
        <div class="columnTbll">
            <form name="phenoSearchForm1" action="" >
                <input type="hidden" name="act" value="unitSearch" />
                <div style="display: inline-block">
                <table>
                    <tr>
                        <td>CMO ID: </td>
                        <td>
                            <input id="cmoIdField" name="cmoIdField" size="11" type="text" value="CMO:000"/>
                        </td>
                        <td>Standard Unit: </td>
                        <td>
                            <input id="stdUnitField" name="stdUnitField" size="20" type="text"/>
                        </td>
                        <td>Unit From: </td>
                        <td>
                            <input id="unitFromField" name="unitFromField" size="20" type="text"/>
                        </td>
                        <td>
                            <div class="input-group-append">
                                <button class="btn btn-primary" type="submit" onClick="submitPage('phenominerUnitTables.html')" >
                                    <i class="fa fa-search" ></i>
                                </button>&nbsp;&nbsp;
                            </div>
                        </td>
                        <td>
                            <input type="hidden" name="act" value="reset" />
                            <button type="submit" onClick="resetPage('phenominerUnitTables.html')" class="btn btn-primary reset"> Reset </button>
                        </td>
                    </tr>
                </table>
                </div>
            </form>
            <br>
            <hr>
            <script type="text/javascript" src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>
            <div class="tableFixHead">
                <%
                    Report unitReport = (Report) request.getAttribute("unitReport");
                    HTMLTableReportStrategy strat1 = new HTMLTableReportStrategy();
                    strat1.setTableProperties("class='sortable' , width=100%");
                    String[] tdProps1 = new String[1];
                    tdProps1[0] = "width = 25%";
                    strat1.setTdProperties(tdProps1);
                    out.print(unitReport.format(strat1));
                %>
            </div>
        </div>
        <div class="columnTblr" >
            <form name="phenoSearchForm2" action="" >
                <input type="hidden" name="act" value="enumSearch" />
                <div style="display: inline-block">
                <table>
                    <tr>
                        <td>Type: </td>
                        <td>
                            <input id="typeField" name= "typeField" size="1" type="number" min="1" max="6"/>
                        </td>
                        <td>Label: </td>
                        <td>
                            <input id="labelField" name="labelField" size="30" type="text"/>
                        </td>
                        <td>
                            <div class="input-group-append">
                                <button class="btn btn-primary" type="submit" onClick="submitPage('phenominerUnitTables.html')" >
                                    <i class="fa fa-search"></i>
                                </button>&nbsp;&nbsp;
                            </div>
                        </td>
                        <td>
                            <input type="hidden" name="act" value="reset" />
                            <button type="submit" onClick="resetPage('phenominerUnitTables.html')" class="btn btn-primary reset"> Reset </button>
                        </td>
                    </tr>
                </table>
                </div>
            </form>
            <hr>
            <script type="text/javascript" src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>
            <div class="tableFixHead">
            <%
                Report enumReport = (Report) request.getAttribute("enumReport");
                HTMLTableReportStrategy strat2 = new HTMLTableReportStrategy();
                strat2.setTableProperties("class='sortable' , width=100%");
                strat2.setTdProperties(new String[]{
                        "width = 25%"
                });
                out.print(enumReport.format(strat2));
            %>
            </div>
        </div>
    </div>
    <span class="phenominerPageHeader">Without Standard Units</span>
    <div class="phenoNavBar"></div>
    <div class="rowTbl">
        <div class="columnTbll">
            <form name="phenoSearchForm3" action="" >
                <input type="hidden" name="act" value="noStdUnitSearch" />
            </form>
            <script type="text/javascript" src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>
            <div class="tableFixHead">
                <%
                    Report noStdUnitReport = (Report) request.getAttribute("noStdUnitReport");
                    HTMLTableReportStrategy strat3 = new HTMLTableReportStrategy();
                    strat3.setTableProperties("class='sortable' , width=100%");
                    String[] tdProps3 = new String[1];
                    tdProps3[0] = "width = 25%";
                    strat3.setTdProperties(tdProps3);
                    out.print(noStdUnitReport.format(strat3));
                %>
            </div>
        </div>
        <div class="columnTblr">
        </div>
    </div>
    <hr>
</form>

<%@ include file="editFooter.jsp"%>

