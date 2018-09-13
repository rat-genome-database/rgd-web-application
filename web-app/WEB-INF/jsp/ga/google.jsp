<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Identifiable" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermBucket" %>

<script type="text/javascript" src="https://www.google.com/jsapi"></script>

<%

    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req,  new java.util.ArrayList());
    FormUtility fu = new FormUtility();

    AnnotationDAO adao = new AnnotationDAO();

    GeneDAO gdao = new GeneDAO();
    int speciesTypeKey = Integer.parseInt(req.getParameter("species"));
    List symbols= Utils.symbolSplit(req.getParameter("genes"));
    ObjectMapper om = new ObjectMapper();
    List mapped = om.mapSymbols(symbols, speciesTypeKey );

        if (req.isSet("chr") && req.isSet("start") && req.isSet("stop") && req.isSet("mapKey")) {
            mapped.addAll(gdao.getGenesByPosition(req.getParameter("chr"), Integer.parseInt(req.getParameter("start")), Integer.parseInt(req.getParameter("stop")), Integer.parseInt(req.getParameter("mapKey"))));
        }

        List mappedRGDIds = new ArrayList();

        Iterator mappedIt = mapped.iterator();
        while (mappedIt.hasNext()) {
            Object next = mappedIt.next();

            if (next instanceof Identifiable) {
                Identifiable ided = (Identifiable) next;
                mappedRGDIds.add(ided.getRgdId());
            }
        }

%>
<br>
<span style="font-size:24; font-weight:700;">Total Genes: <%=mappedRGDIds.size()%> </span>
<br>

The following charts represent the percentage genes in the set annotated to each term.

<%
    HashMap aspects = new HashMap();
    aspects.put("GO: Biological Process", "P");
    aspects.put("GO: Molecular Function", "F");
    aspects.put("GO: Cellular Component", "C");
    aspects.put("CTD: Disease Ontology", "D");
    aspects.put("MP: Mammalian Phenotype ", "N");
    aspects.put("PW: Pathway Ontology", "W");

    Iterator it = aspects.keySet().iterator();

    while (it.hasNext()) {
        String ontology=(String ) it.next();
        String aspect = (String) aspects.get(ontology);

    HashMap lst = adao.getCommonAnnotationTermCounts(mappedRGDIds,aspect);




     if (lst.size()==0) continue;


    %>

    <!--Load the AJAX API-->
    <script type="text/javascript">

      // Load the Visualization API and the piechart package.
      google.load('visualization', '1.0', {'packages':['corechart']});

      // Set a callback to run when the Google Visualization API is loaded.
      google.setOnLoadCallback(drawChart);

      // Callback that creates and populates a data table,
      // instantiates the pie chart, passes in the data and
      // draws it.
      function drawChart() {

      // Create the data table.
      var data = new google.visualization.DataTable();
      data.addColumn('string', 'Term');
      data.addColumn('number', 'Genes Annotated');
      data.addRows([
      <%
          Iterator mapIt = lst.keySet().iterator();
          int termCount=0;
          while (mapIt.hasNext()) {
              String term = (String) mapIt.next();
              Integer count = (Integer) lst.get(term);

              if (count > 1) {

                if (termCount !=0) {
                    out.print(",");
                }

              termCount++;

      %>
                  ['<%=term%>', <%=count%> ]
          <%
              }
          }

          %>


      ]);

      var chartArea=new Object();
      chartArea.height='95%';
      chartArea.width='50%';

      var legend=new Object();
      legend.textStyle = new Object();
      legend.textStyle.color="orange";


      // Set chart options
      var options = {'title':'<%=ontology%>',
                     'width':1100,
                     'height':<%=termCount * 20%>,
                     'is3D': true,
                      backgroundColor: '#ece9d8',
                      chartArea:chartArea,
                      legend:legend
                      };
                      //vAxis: {title: "Year", width:300},
                      //hAxis: {title: "Cups", width:300},

      // Instantiate and draw our chart, passing in some options.
      //var chart = new google.visualization.PieChart(document.getElementById('chart_div<%=aspect%>'));
      var chart = new google.visualization.BarChart(document.getElementById('chart_div<%=aspect%>'));
      chart.draw(data, options);
    }
    </script>

    <!--Div that will hold the pie chart-->
    <div id="chart_div<%=aspect%>" style=""></div>

<% }%>