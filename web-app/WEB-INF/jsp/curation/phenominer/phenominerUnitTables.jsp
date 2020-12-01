<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%
    String pageTitle = "Phenominer Unit Tables";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="editHeader.jsp"%>

<link rel="stylesheet" type="text/css" href="/rgdweb/css/pheno.css">
<html>
<body>
<style>
    /* Create two equal columns that floats next to each other */
    .columnTbll {
        float: left;
        width: 49%;
        padding: 10px;
        max-height: 600px;
    }

    .columnTblr {
        float: right;
        width: 47%;
        padding: 10px;
        max-height: 600px;
    }

    .rowTbl {
        border-style: outset;
    }

    .resetButton {
        text-align: center;
        display: inline-block;
        background-color: lightskyblue;
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
    .fixedWidth
    {
        width:100px;
        max-width:100px;
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
<script type="text/javascript" src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>

<div style="width:100%;background:#EEEEEE">
    <h2 style="text-align: center;color:#24609c">Phenominer Unit-Enum Tables</h2>
</div>
<hr>

<form id="phenominerUnitEnumTablesForm" name="phenominerUnitEnumTablesForm" action="phenominerUnitTables.html" method="Get">
    <div class="rowTbl">
        <div class="columnTbll">
            <form name="phenoSearchForm1" action="" >
                <input type="hidden" name="act" value="unitSearch" />
                <div style="display: inline-block">
                <table>
                    <tr>
                        <td class="fixedWidth">CMO ID: </td>
                        <td>
                            <input id="cmoIdField" name="cmoIdField" size="11" width="11" type="text" value="CMO:000"/>
                        </td>
                        <td class="fixedWidth">Standard Unit: </td>
                        <td>
                            <input id="stdUnitField" name="stdUnitField" size="20" width="20" type="text"/>
                        </td>
                        <td class="fixedWidth">Unit From: </td>
                        <td>
                            <input id="unitFromField" name="unitFromField" size="20" width="20" type="text"/>
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
                            <button type="submit" onClick="resetPage('phenominerUnitTables.html')" class = "resetButton"> Reset </button>
                        </td>
                    </tr>
                </table>
                </div>
            </form>
            <hr>
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
                        <td style="width:50px;max-width:50px;">Type: </td>
                        <td>
                            <input id="typeField" name= "typeField" size="1" width="1" type="number" min="1" max="6"/>
                        </td>
                        <td style="width:50px;max-width:50px;">Label: </td>
                        <td>
                            <input id="labelField" name="labelField" size="30" width="30" type="text"/>
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
                            <button type="submit" onClick="resetPage('phenominerUnitTables.html')" class = "resetButton"> Reset </button>
                        </td>
                    </tr>
                </table>
                </div>
            </form>
            <hr>
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
</form>

<%@ include file="/common/footerarea.jsp"%>
</body>
</html>