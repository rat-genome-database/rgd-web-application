<%@ page import="com.google.gson.Gson" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<script>

        selectedCmo= "${selectedFilters.cmoTerm}";
        selectedRs ="${selectedFilters.rsTerm}";
        selectedMmo= "${selectedFilters.mmoTerm}";
        selectedXco ="${selectedFilters.xcoTerm}";
        selectedSex ="${selectedFilters.sex}";
        selectedUnits="${selectedFilters.units}";
        selectedExperimentName="${selectedFilters.experimentName}";

        selectAllRsCheckbox="${selectAllCheckBox.rsAll}";
        selectAllCmoCheckbox="${selectAllCheckBox.cmoAll}";
        selectAllMmoCheckbox="${selectAllCheckBox.mmoAll}";
        selectAllXcoCheckbox="${selectAllCheckBox.xcoAll}";
        selectAllSexCheckbox="${selectAllCheckBox.sexAll}";
        selectAllUnitsCheckbox="${selectAllCheckBox.unitsAll}";


</script>
<style>
    body {
        font-family: "Lato", sans-serif;
    }

    .sidenav {
        height: 100%;
        width: 0;
        position: fixed;
        z-index: 1;
        top: 0;
        left: 0;
        background-color: #111;
        overflow-x: hidden;
        transition: 0.5s;
        padding-top: 60px;
        opacity: 0.8;
    }

    .sidenav a {
        padding: 8px 8px 8px 8px;
        text-decoration: none;
        font-size: 25px;
        color: #818181;
        display: block;
        transition: 0.3s;
    }

    .sidenav td {
        adding: 8px 8px 8px 30px;
        text-decoration: none;
        font-size: 14px;
        color: white;
        display: block;
        transition: 0.3s;
        opacity:1;
    }

    .sidenav a:hover {
        color: #f1f1f1;
    }

    .sidenav .closebtn {
        position: absolute;
        top: 0px;
        left:0px;
        z-index: 100;
        right: 25px;
        font-size: 36px;
        margin-left: 50px;
        color:orange;
    }
    .filterOptions {
        padding:5px;
        position:fixed;
        top:400px;
        left:5px;
        z-index:100;
        color:orange;
        -webkit-transform: rotate(-90deg);
        -moz-transform: rotate(-90deg);
        transform:rotate(-90deg);
        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
        background-color:#1A80B6;
        margin-left: -50px;
        visibility:hidden;
    }

    @media screen and (max-height: 450px) {
        .sidenav {padding-top: 15px;}
        .sidenav a {font-size: 18px;}
    }
</style>

<!--
<div id="mySidenav" class="sidenav">
<a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
<a href="#">About</a>
<a href="#">Services</a>
<a href="#">Clients</a>
<a href="#">Contact</a>
</div>
-->
<!--
<span style="font-size:30px;cursor:pointer" onclick="openNav()">&#9776; open</span>
-->
<script>
    function openNav() {
        if (document.getElementById("mySidenav").style.width == "300px") {
            //document.getElementById("recordTableContent").style.left="0px";
            //document.getElementById("recordTableContent").style.width="100%";
            document.getElementById("site-wrapper").style.left="0px";
            document.getElementById("site-wrapper").style.width="100%";
            document.getElementById("filterOpen").style.visibility="visible";
            document.getElementById("filterClose").style.visibility="hidden";
            closeNav();
        }else {
            document.getElementById("mySidenav").style.width = "300px";
            //document.getElementById("recordTableContent").style.left="300px";
            //document.getElementById("recordTableContent").style.width="75%";
            document.getElementById("site-wrapper").style.left="300px";
            document.getElementById("site-wrapper").style.width="75%";
            document.getElementById("filterClose").style.visibility="visible";
            document.getElementById("filterOpen").style.visibility="hidden";
        }
    }

    function closeNav() {
        document.getElementById("mySidenav").style.width = "0";
        //document.getElementById("filterButton").innerHTML="&#9776; Filter Options";

    }
</script>



<style>
    .recordFilterBlock {
        max-height:250px;
        width: 200px;
        border: 1px solid #4A4A4A;
        padding-left:5px;
        padding-right:5px;
        padding-top:7px;
        padding-bottom:6px;
        overflow-y:auto;

    }
    .recordFilterTitle {
        padding-top:6px;
        font-size:20px;
        ackground-color:#818181;
        color:#818181;



    }
</style>

<div class="filterOptions" id="filterClose">
    <a href="javascript:void(0)" style="color:white;" lass="closebtn" onclick="openNav()">&#9776; Close Options</a>
</div>
<div class="filterOptions" id="filterOpen">
    <a href="javascript:void(0)" style="color:white;" lass="closebtn" onclick="openNav()">&#9776; Open Options</a>
</div>
<div id="mySidenav" class="sidenav">
    <form id="phenominerReportForm" action="/rgdweb/phenominer/table.html?species=3" method="get" >
        <input type="hidden" name="terms" value="${terms}"/>
        <input type="hidden" name="facetSearch" value="true"/>
        <input type="hidden" name="legendJson" value='${legendJson}'/>

        <table align="center" border="0" style="margin-left:35px;">
            <!--tr>
                <td valign="top">
                    <table>
                        <tr>
                            <td ><div class="recordFilterTitle">

                                <input  id="cmoAll" name="cmoAll" type="checkbox"  >&nbsp;

                                Measurement</div></td>
                        </tr>
                        <tr>
                            <td>
                                <div class="recordFilterBlock">
                                    <table>
                                        <c:forEach items="${aggregations.cmoTermBkts}" var="cmoBkt" >
                                            <tr>
                                                <td>
                                                    <input class="formCheckInput" name="cmoTerm"  type="checkbox" value="${cmoBkt.key}" >&nbsp;${cmoBkt.key}&nbsp;(${cmoBkt.docCount})
                                                </td>
                                            </tr>
                                        </c:forEach>

                                    </table>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr-->

        <!--tr>
            <td valign="top">
                <table>
                    <tr>
                        <td ><div class="recordFilterTitle">

                            <input  id="cmoAll" name="cmoAll" type="checkbox"  >&nbsp;

                            Measurement</div></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="recordFilterBlock">
                                <table>
                                    <c:forEach items="${aggregations.cmoTermBkts}" var="cmoBkt" >
                                        <tr>
                                            <td>
                                                <input class="formCheckInput" name="cmoTerm"  type="checkbox" value="${cmoBkt.key}" >&nbsp;${cmoBkt.key}&nbsp;(${cmoBkt.docCount})
                                            </td>
                                        </tr>
                                    </c:forEach>

                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr-->

            <tr>
                <td valign="top">
                    <table>
                        <tr>
                            <td  ><div class="recordFilterTitle">

                                <input  id="unitsAll" name="unitsAll" type="checkbox"  >&nbsp;

                                Measurements</div></td>
                        </tr>
                        <tr>
                            <td>
                                <div class="recordFilterBlock">
                                    <table>

                                        <c:forEach items="${aggregations.unitBkts}" var="unitBkt" >
                                            <tr>
                                                <td>
                                            <c:forEach items="${unitBkt.aggregations.get('experimentName').buckets}" var="xNameBkt" >
                                                <!--input class="formCheckInput" name="experimentName"  type="checkbox" onchange="updateSelection('${xNameBkt.key}')" value="${xNameBkt.key}">&nbsp;${xNameBkt.key}&nbsp;(${unitBkt.key})&nbsp;($-{unitBkt.docCount})-->
                                                <p style="color:navajowhite">&nbsp;${fn:toUpperCase( xNameBkt.key)}&nbsp;(${unitBkt.key})&nbsp;<!--($-{unitBkt.docCount})-->

                                                <c:set var="className" value="${fn:replace(xNameBkt.key,' ', '')}"/>
                                                <table style="border:1px solid lightgrey;margin-left: 10%">
                                                    <c:forEach items="${xNameBkt.aggregations.get('cmoTerm').buckets}" var="bkt">
                                                        <tr><td><input class='formCheckInput ${className}' name="cmoTerm"  type="checkbox" value="${bkt.key}" >&nbsp;${bkt.key}&nbsp;(${bkt.docCount})</td></tr>

                                                        </c:forEach>
                                                    </table>
                                            </c:forEach>
                                                </td>
                                            </tr>
                                        </c:forEach>

                                    </table>
                                </div></td>
                        </tr>
                    </table>

                </td>
            </tr>


        <tr>
            <td valign="top">
                <table>
                    <tr>
                        <td  ><div class="recordFilterTitle">
                            <input  id="rsAll" name="rsAll"  type="checkbox" >&nbsp;
                            Strains</div></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="recordFilterBlock">
                                <table>

                                    <c:forEach items="${aggregations.rsTermBkts}" var="rsBkt" >
                                        <tr>
                                            <td>
                                                <input class="formCheckInput" name="rsTerm"  type="checkbox" onchange="updateSelection('${rsBkt.key}')" value="${rsBkt.key}">&nbsp;${rsBkt.key}&nbsp;<!--($-{rsBkt.docCount})-->
                                                <c:set var="rsClassName" value="${fn:replace(rsBkt.key,'/', '')}"/>
                                                <table style="border:1px solid lightgrey;margin-left: 10%">
                                                <c:forEach items="${rsBkt.aggregations.get('rsTerm').buckets}" var="rsTermBkt" >
                                                <tr><td>
                                                    <input class="formCheckInput ${rsClassName}" name="rsTerm"  type="checkbox" value="${rsTermBkt.key}">&nbsp;${rsTermBkt.key}&nbsp;(${rsBkt.docCount})
                                                </td></tr>
                                                    </c:forEach>
                                                </table>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </table>
                            </div>
                        </td>
                    </tr>
                </table>

            </td>
        </tr>



        <tr>
            <td valign="top">
                <table>
                    <tr>
                        <td  ><div class="recordFilterTitle">

                            <input  id="mmoAll"  name="mmoAll" type="checkbox" >&nbsp;

                            Methods</div></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="recordFilterBlock">
                                <table>

                                    <c:forEach items="${aggregations.mmoTermBkts}" var="mmoBkt" >
                                        <tr>
                                            <td>
                                                <input class="formCheckInput" name="mmoTerm"  type="checkbox" value="${mmoBkt.key}" >&nbsp;${mmoBkt.key}&nbsp;(${mmoBkt.docCount})
                                            </td>
                                        </tr>
                                    </c:forEach>

                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>


        <tr>
            <td valign="top">
                <table>
                    <tr>
                        <td  ><div class="recordFilterTitle">

                            <input  id="xcoAll" name= "xcoAll" type="checkbox" >&nbsp;

                            Conditions
                        </div></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="recordFilterBlock">
                                <table>

                                    <c:forEach items="${aggregations.xcoTermBkts}" var="xcoBkt" >
                                        <c:if test="${xcoBkt.key!=''}">
                                        <tr>
                                            <td>
                                                <input class="formCheckInput" name="xcoTerm"  type="checkbox" value="${xcoBkt.key}" >&nbsp;${xcoBkt.key}&nbsp;&nbsp;(${xcoBkt.docCount})
                                            </td>
                                        </tr>
                                        </c:if>
                                    </c:forEach>

                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>



        <!--tr>
            <td valign="top">
                <table>
                    <tr>
                        <td><div class="recordFilterTitle">

                            <input id="ageAll" name="ageAll" type="checkbox" >&nbsp;

                            Age</div></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="recordFilterBlock">
                                <table>

                                    <tr>
                                        <td>
                                            <input class="formCheckInput" name="age" type="checkbox" >age1
                                        </td>
                                    </tr>

                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr-->


        <tr>
            <td valign="top">
                <table>
                    <tr>
                        <td  ><div class="recordFilterTitle">

                            <input  id="sexAll" name="sexAll" type="checkbox"  >&nbsp;

                            Sex</div></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="recordFilterBlock">
                                <table>

                                    <c:forEach items="${aggregations.sexBkts}" var="cmoBkt" >
                                        <tr>
                                            <td>
                                                <input class="formCheckInput" name="sex"  type="checkbox" value="${cmoBkt.key}" >&nbsp;${cmoBkt.key}&nbsp;(${cmoBkt.docCount})
                                            </td>
                                        </tr>
                                    </c:forEach>

                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>





    </table>
    </form>
</div>
<script>
    setTimeout(openNav,1000);
    $(".formCheckInput").on("change",function () {
        $('#phenominerReportForm').submit();
    })
</script>

<script src="/rgdweb/js/phenominer/facet.js"></script>
