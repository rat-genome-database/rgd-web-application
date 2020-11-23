<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String pageTitle = "Phenominer Unit Tables";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>

<link rel="stylesheet" type="text/css" href="/rgdweb/css/pheno.css">
<html>
<body>
<style>
    /* Create two equal columns that floats next to each other */
    .columnTbl {
        float: left;
        width: 50%;
        padding: 10px;
        overflow-y: auto;
        max-height: 600px;
    }

    .rowTbl {
        border-style: outset;
    }
</style>

<script  type="text/javascript">
    function submitPage(actionValue) {
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
        <div class="columnTbl" id="phenominerUnitSearchDivId">
            <form name="phenoSearchForm1" action="" >
                <input type="hidden" name="act" value="unitSearch" />
            <table>
                <tr>
                    <td>CMO ID: </td>
                    <td class="form-group">
                        <div class="input-group" >
                            <input class="searchgroup" id="cmoIdField" name="cmoIdField" size="11" type="text" value="CMO:000"/>
                        </div>
                    </td>
                    <td>Standard Unit: </td>
                    <td class="form-group">
                        <div class="input-group" >
                            <input class="searchgroup" id="stdUnitField" name="stdUnitField" size="30" type="text"/>
                        </div>
                    </td>
                    <td>Unit From: </td>
                    <td class="form-group">
                        <div class="input-group" >
                            <input class="searchgroup" id="unitFromField" name="unitFromField" size="30" type="text"/>
                        </div>
                    </td>
                    <td>
                        <div class="input-group-append">
                            <button class="btn btn-primary" type="submit" onClick="submitPage('phenominerUnitTables.html')" >
                                <i class="fa fa-search" ></i>
                            </button>&nbsp;&nbsp;
                        </div>
                    </td>
                </tr>
            </table>
            </form>
            <hr>
                <div id = "unitReportTableId">
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
        <div class="columnTbl" >
            <form name="phenoSearchForm2" action="" >
                <input type="hidden" name="act" value="enumSearch" />
                <table>
                    <tr>
                        <td>Type: </td>
                        <td class="form-group">
                            <div class="input-group" >
                                <input class="searchgroup" id="typeField" name= "typeField" size="1" type="number" min="1" max="6"/>
                            </div>
                        </td>
                        <td>Label: </td>
                        <td class="form-group">
                            <div class="input-group" >
                                <input class="searchgroup" id="labelField" name="labelField" size="30" type="text"/>
                            </div>
                        </td>
                        <td>
                            <div class="input-group-append">
                                <button class="btn btn-primary" type="submit" onClick="submitPage('phenominerUnitTables.html')" >
                                    <i class="fa fa-search"></i>
                                </button>&nbsp;&nbsp;
                            </div>
                        </td>
                    </tr>
                </table>
            </form>
            <hr>
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
</form>

<%@ include file="/common/footerarea.jsp"%>
</body>
</html>