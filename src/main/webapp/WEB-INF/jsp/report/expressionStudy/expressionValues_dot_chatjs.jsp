<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneExpressionDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.GeneExpression" %>
<%@ page import="java.util.List" %><%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/12/2026
  Time: 12:12 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  GeneExpressionDAO geneExpressionDAO=new GeneExpressionDAO();
  List<GeneExpression> highValues=geneExpressionDAO.getHighExpressionValuesByStudyId(obj.getId(), "high");

%>
<h4>Expression Values Level High: <%=highValues.size()%></h4>

<!-- Dot Plot for Gene Expression High Values -->
<div style="width: 100%; max-width: 900px; margin-bottom: 20px;">
  <h5>TPM Values Dot Plot</h5>
  <canvas id="expressionDotPlot" height="400"></canvas>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    var ctx = document.getElementById('expressionDotPlot').getContext('2d');

    // Prepare data for dot plot
    var genes = [];
    var tpmValues = [];
    var labels = [];
    var geneIndexMap = {};
    var geneIndex = 0;

    var conditionColorMap = {};
    var colorPalette = [
      'rgba(220, 53, 69, 0.7)',   // red
      'rgba(40, 167, 69, 0.7)',   // green
      'rgba(0, 123, 255, 0.7)',   // blue
      'rgba(255, 193, 7, 0.7)',   // yellow
      'rgba(111, 66, 193, 0.7)',  // purple
      'rgba(23, 162, 184, 0.7)',  // cyan
      'rgba(253, 126, 20, 0.7)',  // orange
      'rgba(108, 117, 125, 0.7)'  // gray
    ];
    var colorIndex = 0;

    <%
        int index = 0;
        for(GeneExpression x : highValues) {
            String gene = x.getGeneExpressionRecordValue().getExpressedGeneSymbol();
            String sample = x.getSample().getGeoSampleAcc();
            Double tpm = x.getGeneExpressionRecordValue().getTpmValue();
        //    String condition = x.getGeneExpressionRecord().getExperimentCondition();
    %>
    var gene = "<%=gene%>";
    var condition = "<%=sample%>";
    if (geneIndexMap[gene] === undefined) {
      geneIndexMap[gene] = geneIndex;
      genes.push(gene);
      geneIndex++;
    }
    if (conditionColorMap[condition] === undefined) {
      conditionColorMap[condition] = colorPalette[colorIndex % colorPalette.length];
      colorIndex++;
    }
    tpmValues.push({
      x: geneIndexMap[gene],
      y: <%=tpm%>,
      gene: gene,
      sample: "<%=sample%>",
      condition: condition
    });
    <%
        }
    %>

    // Group data by condition for separate datasets
    var datasetsByCondition = {};
    tpmValues.forEach(function(point) {
      if (!datasetsByCondition[point.condition]) {
        datasetsByCondition[point.condition] = [];
      }
      datasetsByCondition[point.condition].push(point);
    });

    // Create datasets array for Chart.js
    var datasets = [];
    Object.keys(datasetsByCondition).forEach(function(condition) {
      datasets.push({
        label: condition,
        data: datasetsByCondition[condition],
        backgroundColor: conditionColorMap[condition],
        borderColor: conditionColorMap[condition].replace('0.7', '1'),
        borderWidth: 1,
        pointRadius: 8,
        pointHoverRadius: 8
      });
    });

    var dotPlotChart = new Chart(ctx, {
      type: 'scatter',
      data: {
        datasets: datasets
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Gene Expression High Values - Dot Plot by Condition'
          },
          legend: {
            display: true,
            position: 'top',
            title: {
              display: true,
              text: 'Conditions'
            }
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                var point = context.raw;
                return ['Gene: ' + point.gene, 'Sample: ' + point.sample, 'Condition: ' + point.condition, 'TPM: ' + point.y.toFixed(2)];
              }
            }
          }
        },
        scales: {
          x: {
            title: {
              display: true,
              text: 'Gene'
            },
            ticks: {
              callback: function(value, index) {
                return genes[value] || '';
              },
              maxRotation: 45,
              minRotation: 45
            }
          },
          y: {
            title: {
              display: true,
              text: 'TPM Value'
            },
            beginAtZero: true
          }
        }
      }
    });
  });
</script>

<table>
  <thead>
  <tr><th>Sample</th><th>Gene</th><th>Condition</th><th>TPM Value</th></tr>
  </thead>
  <tbody>
  <%
    for(GeneExpression x:highValues){
      //    for(Condition c:x.getGeneExpressionRecord().getConditions()){
  %>
  <tr>
    <td><%=x.getSample().getGeoSampleAcc()%></td>
    <td><%=x.getGeneExpressionRecordValue().getExpressedGeneSymbol()%></td>
    <td><%=x.getGeneExpressionRecord().getExperimentCondition()%></td>
    <td><%=x.getGeneExpressionRecordValue().getTpmValue()%></td>
  </tr>
  <%
    // }
  %>

  <%}%>
  </tbody>
</table>