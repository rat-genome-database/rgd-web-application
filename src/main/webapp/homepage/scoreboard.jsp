<%@ page import="edu.mcw.rgd.dao.impl.StatisticsDAO" %>
<%@ page import="java.time.temporal.TemporalAdjusters" %>
<%@ page import="java.time.*" %>
<%@ page import="edu.mcw.rgd.stats.ScoreBoardManager" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    StatisticsDAO sdao = new StatisticsDAO();
    ScoreBoardManager sbm = new ScoreBoardManager();
    List<String> pastDates = sdao.getStatArchiveDates();
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);

    Date date = formatter.parse(pastDates.get(0));
    Date date2 = formatter.parse(pastDates.get(1));
    String formattedDateString = formatter.format(date2);


    Map<String,String> map = sdao.getStatMap("Active Object",0,date);
    Map<String,String> map2 = sdao.getStatMap("Active Object",0,date2);
    Map<String, String> annotMap = sbm.getOntologyManualAnnotationCount(0, 0, date); // species, rgd obj, date - for all rgd objects and species
    int geneCur = Integer.parseInt(map.get("GENES"));
    int genePrev = Integer.parseInt(map2.get("GENES"));
    int geneDiff = geneCur - genePrev;
%>

<table class="publicScoreboard" width="270">
    <tr>
        <td>Genes (All Species)</td>
        <td class="scoreboardAmount"><%=map.get("GENES")%></td>
    </tr>
    <tr>
        <td>Rat Strains</td>
        <td class="scoreboardAmount"><%=map.get("STRAINS")%></td>
    </tr>
    <tr>
        <td>QTLs (All Species)</td>
        <td class="scoreboardAmount"><%=map.get("QTLS")%></td>
    </tr>
    <tr>
        <td></td>
        <td class="scoreboardAmount"></td>
    </tr>
    <tr>
        <td>New Genes added since <%=formattedDateString%></td>
        <td class="scoreboardAmount"><%=geneDiff <= 0 ? "N/A" : geneDiff%></td>
    </tr>
    <tr>
        <td>Manual Annotations</td>
        <td></td>
    </tr>
    <tr>
        <td>RDO: RGD Disease Ontology</td>
        <td class="scoreboardAmount"><%=annotMap.get("RDO: RGD Disease Ontology")%></td>
    </tr>
    <%
    for (String var : annotMap.keySet()){
        if (var.contains("NBO:") || var.contains("RDO"))
            continue;
    %>
    <tr>
        <td><%=var%></td>
        <td class="scoreboardAmount"><%=annotMap.get(var)%></td>
    </tr>
    <% } %>
</table>

<style>
    .publicScoreboard{
        font-size: larger;
        border: 1px solid black;
    }
    .scoreboardAmount{
        text-align: right;
    }
</style>