<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 4/1/2016
  Time: 11:59 AM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>

<head>
    <title>InterViewer- Cytoscape Graph Visuals</title>
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
    <!--link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css" type="text/css">
    <link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.min.css" type="text/css"-->


    <script src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
    <script src="/rgdweb/common/cytoscape.min.js"></script>
    <!--script src="/rgdweb/common/bootstrap/js/bootstrap.min.js"></script-->
    <link href="/rgdweb/common/jquery-ui/jquery-ui.css" rel="stylesheet" type="text/css">
    <script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>
    <link href="/rgdweb/common/qtip/jquery.qtip.min.css" rel="stylesheet" type="text/css">
    <link href="/rgdweb/common/plugins/panZoom/jquery.cytoscape.js-panzoom.css" rel="stylesheet" type="text/css">
    <link href= "/rgdweb/common/plugins/panZoom/font-awesome-4.0.3/css/font-awesome.css" rel="stylesheet" type="text/css" >
    <link href= "/rgdweb/common/plugins/panZoom/font-awesome-4.0.3/css/font-awesome.min.css" rel="stylesheet" type="text/css" >
    <script src="/rgdweb/common/plugins/panZoom/jquery.cytoscape.js-panzoom.js"></script>
    <link href="/rgdweb/css/cyStyle.css" rel="stylesheet" type="text/css">
    <!--script src="/rgdweb/common/plugins/cyNavigator/jquery.cytoscape.js-navigator.js"></script>
    <link href="/rgdweb/common/plugins/cyNavigator/jquery.cytoscape.js-navigator.css" rel="stylesheet" type="text/css"-->

    <script src="/rgdweb/common/plugins/cyNavigator/cytoscape-navigator.js"></script>
    <link href="/rgdweb/common/plugins/cyNavigator/cytoscape-navigator.css" rel="stylesheet" type="text/css">

    <script src="/rgdweb/common/qtip/jquery.qtip.min.js"></script>
    <script src="/rgdweb/common/plugins/cytoscape-qtip.js"></script>
    <script src="/rgdweb/js/cola1.js"></script>
    <script src="/rgdweb/js/cola.js"></script>
    <script src="/rgdweb/js/download.js"></script>
    <script src="/rgdweb/js/cyTabSearch.js"></script>
    <style type="text/css">

        #cy {

            width: 79%;
          /*  width:70%;*/
             height: 57.1%;

         /*   display: block;
           /* border: 1px solid #ddd;*/
            float:left;
        background-color:white;
        }

        .cytoscape-navigator{
            width: 20%;
            height:25%;
        }

        #cy.fullscreen{
            z-index: 9999;
            width: 100%;
            height: 100%;
            position: fixed;
            top: 0;
            left: 0;
        }
    </style>
    <script>
        var nodesList= ${model.nodes};
        var edgesList= ${model.edges};
    </script>
    <script>

    </script>
    <%@ include file="rgdHeader.jsp"%>
</head>
<body>
<script>
    var typeMapJson=${model.typeMapJson}
</script>
<script>
    var terms=[];
    <c:forEach items="${model.matched}" var="term">
    terms.push("<c:out value="${term}"/>");
    </c:forEach>

    var logItems=[];
    <c:forEach items="${model.log}" var="log">
    logItems.push("<c:out value="${log}"/>");
    </c:forEach>
</script>

<script src="/rgdweb/js/code1.js"></script>
<!--script src="/rgdweb/js/rgdJquery.js"></script-->
<div id="container">
  <form action="cy.html"> <div id="search" style="float:right"><input type="hidden" value="12" name="browser"><label style="font-weight: bold">Enter Search Terms: </label><!--input type="hidden" value="4" name="species"--><input type="text" name="identifiers"><label style="font-weight: bold">Species:</label> <select name="species" id="species" >
      <option value="0" SELECTED>ALL</option>
      <option value="3" >Rat</option>
      <option  value="2" >Mouse</option>
      <option  value="1" >Human</option>
      <option  value="6" >Dog</option>
      <option  value="9" >Pig</option>
      <option  value="14" >Naked Mole-rat</option>
      <option  value="13" >Green Monkey</option>
  </select><span><button value="submit">Search</button> </span></div></form>
    <h3><span style="color: #0066FF"><c:out value="${fn:length(model.edges)}"/></span> binary interactions found for Queried Objects
        <c:forEach items="${model.matched}" var="item">
            <span style="color: #0066FF"><c:out value="${fn:toUpperCase(item)}"/>,</span>
    </c:forEach></h3>


    <div class="panel-default cy-panel-default">
        <div class="panel-heading cy-panel-heading">
            <div class="panel-title cy-panel-title">InterViewer - Cytoscape Graph Visuals
                <div class="dropdown" style="float: right">
                    <a href="#" onclick="reportFunction()" title="Printable Report">Report</a><span>  ||  </span>
                    <a href="#" onclick="pngFunction()" id="myLink" title="Printable Graph Image">Graph PNG</a>
                 <!--button onclick="myFunction()" class="dropbtn">Options <!--img src="/rgdweb/images/drop_menu.png" style="width: 25px;height:25px"--><!--/button>
                <div id="myDropdown" class="dropdown-content" style="z-index: 9999">
                    <a href="#" onclick="reportFunction()">Report</a>
                    <a href="#" onclick="pngFunction()" id="myLink">Graph PNG</a>
                    <!--a href="cy.html?doc=helpDoc&browser=12" target="_blank">Help</a-->
                    <!--a href="#" onclick="jsonFunction()" id="jsonLink">Graph JSON</a-->
                <!--/div-->
           </div>
        </div>

        </div>
        <div id="menu">
        </div>
        <div class="panel-body cy-panel-body">
            <div  id="cy"></div>
            <div id="sidebar">
                <div class="panel-default cy-panel-default" style="height:95%">
                    <div class="panel-heading cy-panel-heading">
                        <div class="panel-title cy-panel-title">Details/Controls</div>
                    </div>
                    <div class="panel-body details cy-panel-body" style="overflow-y:auto">
                            <h4  style="padding-bottom:0">Selected Edge/Node Details</h4>
                            <div id="textDiv">
                                Click any <span style="color:steelblue; font-weight: bold">Node</span> or <span style="color:steelblue; font-weight: bold">  Edge</span> to see its details.
                            </div>

                            <h4>Layout</h4>
                            <div class="layout">

                            </div>
                            <h4>Interaction Type</h4>
                            <div class="grp1">
                                <!--div class="param"><ul></ul></div-->
                            </div>
                            <h4>Species</h4>
                            <div class="species">

                            </div>
                            <h4>Common Ineractors</h4>
                            <div class="commonint">

                            </div>
                            <h4>Queried Objects</h4>
                            <div class="q">

                            </div>
                        <h4>Queried Object IMEX Links</h4>
                        <div>
                            <p> <c:forEach items="${model.matched}" var="term">
                            <ul>
                                <li><a href="http://www.ebi.ac.uk/intact/imex/main.xhtml?query=<c:out value="${term}"/>" target="_blank" title="Click to lookup in IMEX">${fn:toUpperCase(term)}</a></li>
                            </ul>
                            </c:forEach>
                            </p>
                        </div>
                        <h4>Graph Controls</h4>
                        <div id="controls">

                        </div>

                    </div>
                </div>
            </div>
            <div id="legend">
                <div class="panel-default cy-panel-default" style="height:90%">
                    <div class="panel-heading cy-panel-heading">
                        <div class="panel-title cy-panel-title">Legend</div>
                    </div>
                    <div class="panel-body cy-panel-body" id="L" style="height:90%;overflow-y:auto">
                        <c:forEach items="${model.typeColorMap}" var="entry">
                            <div class="legend" style="background-color:<c:out value="${entry.value}"/> "></div> - <c:out value="${entry.key}"/><br>
                        </c:forEach>
                        <div class="legend" style="background-color:red "></div> - Rat<br>
                        <div class="legend" style="background-color:springgreen "></div> - Mouse<br>
                        <div class="legend" style="background-color:blue "></div> - Human<br>
                        <div class="legend" style="background-color:magenta "></div> - Dog<br>
                        <div class="legend" style="background-color:#d6a749 "></div> - Pig<br>
                        <div class="legend" style="background-color:yellow "></div> - Queried Objects<br>

                    </div>
                </div>
            </div>
            <div id="dataTable">
                <div class="panel-default cy-panel-default">
                    <div class="panel-heading cy-panel-heading">
                        <div class="panel-title">Data Tables</div>
                    </div>
                    <div class="panel-body cy-panel-body" id="tabsdiv">
                        <form action="cy.html?d=true" method="post">
                            <div style="float:right">
                                <button type="submit">Download</button>
                                <input type="hidden" name="identifiers" value='${model.query}'>
                                <input type="hidden" name="species" value='${model.species}'>
                                <input type="hidden" name="browser" value="12">
                            </div>
                        </form>
                        <ul class="tabs">
                            <li class ="tab-link current" data-tab="networktab" title="Edge Table">Network</li>
                            <li class="tab-link" data-tab="nodetab" title="Node Table">Node</li>
                            <li class="tab-link" data-tab="stattab" id="statistics" title="Network Statistics">Statistics</li>
                            <c:set var="logSize" value="${fn:length(model.log)}" scope="session"/>
                            <c:if test="${logSize>0}" >
                                <li class="tab-link" data-tab="log" style="color:red;font-weight: bold">WARNING</li>
                            </c:if>


                        </ul>

                        <div id="tabscontainer">
                            <div id="networktab" class="tab-content current"  > <!--tabContent 1-->
                                <div><span style="margin-left:1%"><label style="font-weight:bold">Filter by Search Term:</label><input type="text" name="searchTableNet"></span></div>

                                <!--div style="height:40px"--> <!--table header div-->
                                    <!--table class="cyTable"-->
                                        <!--thead-->
                                        <!--tr><th>Interactor A ProteinSymbol</th><th>Uniprot_ID A</th><th>Gene A</th><th>Interaction Type</th><th>Interactor B Protein Symbol</th><th>Uniprot_ID B</th><th>Gene B</th></tr-->

                                        <!--/thead-->
                                    <!--/table-->
                                <!--/div--> <!--End table Header div-->
                                <div style="height:92%; overflow: auto"> <!--table body div-->
                                    <table class="dTable" id="dTable">
                                        <thead>
                                        <tr style="height:20px;font-size:12px"><th>Interactor A ProteinSymbol</th><th>Uniprot_ID A</th><th>Gene A</th><th>Interaction Type</th><th>Interactor B Protein Symbol</th><th>Uniprot_ID B</th><th>Gene B</th></tr>
                                       </thead>
                                        <tbody>
                                        <c:forEach items="${model.interactions}" var="i">

                                                <tr class="netrow" title="Click to nteract with graph">
                                                    <td  class="tdef" title="Protein Symbol A">${i.srcSymbol}</td>
                                                    <td class="src" title="UniprotID A">${i.source} </td>
                                                    <td class="tdef" style="text-align: center" title="Genes A">
                                                    <c:set var="flag" value="true"/>
                                                    <c:forEach items="${i.srcGeneList}" var="symbol">
                                                        <c:choose>
                                                            <c:when test="${flag==true}">
                                                                <c:out value="${symbol}"/>
                                                                <c:set var="flag" value="false"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:out value=", "/><c:out value="${symbol}"/>
                                                            </c:otherwise>
                                                        </c:choose>

                                                    </c:forEach>
                                                  </td>

                                                    <td class="type" style="text-align: center" title="InteractionType">${i.description}</td>
                                                    <td class="tdef" title="Protein Symbol B">${i.tSymbol}</td>
                                                    <td class="t" title="UniprotID B">${i.target}</td>

                                                    <td class="tdef" title="Genes B">
                                                        <c:set var="first" value="true"/>
                                                    <c:forEach items="${i.targetGeneList}" var="tSymbol">
                                                        <c:choose>
                                                            <c:when test="${first==true}">
                                                                <c:out value="${tSymbol}"/>
                                                                <c:set var="first" value="false"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:out value=", "/><c:out value="${tSymbol}"/>
                                                            </c:otherwise>
                                                        </c:choose>
                                                  </c:forEach>
                                                    </td>
                                                </tr>


                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div><!--End Table Body div-->
                            </div><!--End tabcontent 1-->

                            <div id="nodetab" class="tab-content" > <!--tabcontent 2-->
                                <div><span style="padding-left:1%"><label style="font-weight:bold">Filter by Search Term:</label><input type="text" name="searchTableNode" ></span></div>

                                <div style="height:92%;background-color:white;overflow:auto" >

                                    <table class="ntable" id="ntable">
                                        <thead>
                                        <tr style="height:20px;font-size:12px"><th>Node UniprotId</th><th>Gene</th><th>Node Symbol</th><th>Species</th></tr>
                                        </thead>

                                        <tbody>
                                        <c:forEach items="${model.nodeList}" var="i">

                                            <tr class="noderow" style="width:20px;font-size:12px">
                                                <td  class="id" title="Uniprot ID">${i.id}</td>
                                                <td class="tdef" title="Genes">
                                                    <c:set var="flag" value="true"/>
                                                <c:forEach items="${i.geneSymbols}" var="g">
                                                    <c:choose>
                                                        <c:when test="${flag==true}">
                                                            <c:out value="${g}"/>
                                                            <c:set var="flag" value="false"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                        <c:out value=", "/><c:out value="${g}"/>
                                                        </c:otherwise>
                                                    </c:choose>

                                                </c:forEach>
                                               </td>
                                                <td class="tdef" title="Protein Symbol">${i.name}</td>
                                                <td class="src" title="Species">${i.species} </td>

                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div><!--End Table Body div-->


                            </div> <!--End tabcontent 2-->
                            <div id="stattab" class="tab-content" > <!--tabcontent 2-->
                                <div style="height:99%;background-color:white;overflow-y:auto" >

                                    <table class="stable">
                                        <thead>
                                        <tr style="height:20px;font-size:12px"><th>Network Statistics</th></tr>
                                        </thead>

                                        <tbody>

                                        <tr class="" style="width:20px;font-size:12px">
                                            <td  class="tdef">Number of Nodes [Participants]:</td>
                                            <c:set value="${fn:length(model.nodes)}" var="nodesSize"/>
                                            <c:set value="${fn:length(model.edges)}" var="edgesSize"/>
                                            <td class="tdef"><c:out value="${nodesSize}"/></td>

                                        </tr>
                                        <tr class="" style="width:20px;font-size:12px">
                                            <td  class="tdef">Number of Edges [Interactions]</td>
                                            <td class="tdef"><c:out value="${edgesSize}"/></td>

                                        </tr>

                                        </tbody>
                                    </table>
                                  <!--div id="nodeStat"></div-->
                                </div><!--End Table Body div-->


                            </div> <!--End tabcontent 2-->
                            <div id="log" class="tab-content">
                                <div class="panel-default cy-panel-default" style="height:95%" >
                                    <div class="panel-heading cy-panel-heading">
                                        <div class="panel-title cy-panel-title">Log</div>
                                    </div>
                                    <div class="panel-body cy-panel-body"style="height:99%; background-color:white;overflow: auto" >
                                        <table id="logTable" style="border: 0px">

                                            <c:forEach items="${model.log}" var="i">
                                                <tr style="border: 0px;">
                                                    <td  class="tdef">${i}</td>
                                                </tr>
                                            </c:forEach>

                                        </table>
                                    </div>
                                </div>
                            </div>

                        </div><!--tabs Container-->
                    </div><!--end panel body-->
                </div>
            </div>


        </div>
        <!--div class="panel panel-default"-->
        <div class="panel-footer">
            <p>&copy; <a href="http://www.mcw.edu/Graduate-School/Academic-Bulletin/Masters-Degree-Programs/Bioinformatics.htm">Bioinformatics Program, HMGC</a> at the <a href="http://www.mcw.edu/">Medical
                College of Wisconsin</a></p>

            <p align="center">RGD is funded by grant HL64541 from the National Heart, Lung, and Blood Institute on behalf of the NIH.<br><img src="/common/images/nhlbilogo.gif" alt="NHLBI Logo" title="National Heart Lung and Blood Institute logo">
        </div>
        <!--/div-->

    </div>
</div>
</body>
<script>
    function myFunction(){
        document.getElementById("myDropdown").classList.toggle("show");
    }

</script>

</html>
