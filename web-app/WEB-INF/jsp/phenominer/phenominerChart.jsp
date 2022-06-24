
<style>
    .conditionBox {
        overflow: auto;
        height: 100px;
        border: 2px solid gray;
    }

    .phenoBullet {
        height:10px;
        width:10px;
        background-color:#D7E4BD;

    }

    tr.oddRow td, tr.oddRow td {
        padding-top:1px;
        padding-left:5px;
        padding-bottom:1px;
    }

    tr.evenRow td, tr.evenRow td {
        background-color:#E2E2E2;
        padding-top:1px;
        padding-left:5px;
        padding-bottom:1px;
    }

    .hoverbox {
        background-color:white;
        width:95%;
        top:0%;
        left:0%;
        height:70px;
        margin-top:10px;
        margin-left:10px;
        padding-top:10px;
        background-color:#E2E2E2;
        padding-left:10px;
        padding-right:10px;
        position:fixed;
        z-index:1000;
        border: 2px solid black;
        display:none;
    }

    .styled-select select {
        background: transparent;
        border: none;
        font-size: 16px;
        padding: 5px; /* If you add too much padding here, the options won't show in IE */
        color:white;
    }

    .styled-select option {
        font-size:18px;
        color: black;
    }
    .green   { background-color: #255992; }

    .rounded {
        -webkit-border-radius: 5px;
        -moz-border-radius: 5px;
        border-radius: 5px;
        border:none;
    }



</style>

<%
    int format = 1;

    try {
        format = Integer.parseInt(request.getParameter("fmt"));
    }catch (Exception e) {
        //ignored
    }
%>


<div >



    <table cellpadding="0" cellspacing="0" border="0" style="padding-top:20px;">
        <tr>
            <td style = "color: #2865a3; font-size: 20px; font-weight:700;">PhenoMiner Database Result <a name="ViewChart">

            </a> </td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td><a href="#ViewDataTable">View data table</a></td>
            <td>&nbsp;|&nbsp;</td>
            <td><a href="<%=tableUrl%>&fmt=3">Download data table</a></td>
            <td>&nbsp;|&nbsp;</td>
            <% if (format==2) { %>
            <td><a href="<%=tableUrl%>&fmt=1">View compact data table</a></td>
            <% } else { %>
            <td><a href="<%=tableUrl%>&fmt=2">View expanded data table</a></td>
            <% } %>
            <td>&nbsp;&nbsp;&nbsp;</td>
            <td align="right" colspan="2"><input type="button" value="Edit Query" onClick="location.href='/rgdweb/phenominer/ontChoices.html?terms=<%=request.getParameter("terms")%>&species=<%=speciesTypeKey%>'"/></td>
            <td>&nbsp;&nbsp;&nbsp;</td>
            <td align="right" colspan="2"><input type="button" value="New Query" onClick="location.href='/rgdweb/phenominer/home.jsp?species=<%=speciesTypeKey%>'"/></td>
        </tr>
    </table>

    <hr>

    <br>



    <br>
    <table border="0" align="left">
        <tr>
            <td>
                Minimum Value: <input ng-model="minValue" ng-change="pheno.updateChart()" type="text"  size="5">
            </td>
            <td>&nbsp;&nbsp;</td>
            <td>
                Maximum Value: <input ng-model="maxValue" ng-change="pheno.updateChart()" type="text" size="5">
            </td>
            <td>&nbsp;&nbsp;</td>
            <td>
                Sex: <select ng-init="sex = sexOptions[0]"
                             ng-model="sex"
                             ng-options="sexOption for sexOption in sexOptions"
                             ng-change="pheno.updateChart()"
            >
            </select>
            </td>
        </tr>

    </table>

    <br><br>
    <!-- Plotly.js -->
    <div class="hoverbox"  id="hoverinfo">&nbsp;</div>

    <div style="overflow-x: auto">

    <div id="myDiv" style="width: 450px; height: 500px;"><!-- Plotly chart will be drawn inside this DIV --></div>

    </div>
    <div ng-init="pheno.load()"></div>

</div> <!-- end of angular block -->

<%@include file="phenominerRecordTable.jsp"%>