<%@ page import="edu.mcw.rgd.dao.impl.StatisticsDAO" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.temporal.TemporalAdjusters" %>
<%@ page import="java.time.*" %>
<%@ page import="edu.mcw.rgd.stats.ScoreBoardManager" %>
<%
    StatisticsDAO sdao = new StatisticsDAO();
    ScoreBoardManager sbm = new ScoreBoardManager();
    LocalDate ld = LocalDate.now();
    ZoneId z = ZoneId.of( "America/Chicago" );
    ZonedDateTime zdt = ld.with(TemporalAdjusters.previous(DayOfWeek.THURSDAY)).atStartOfDay( z );
    LocalDate ld2 = LocalDate.now().minusDays(7);
    ZonedDateTime zdt2 = ld2.with(TemporalAdjusters.previous(DayOfWeek.THURSDAY)).atStartOfDay(z);
    Instant instant = zdt.toInstant();
    Instant instant2 = zdt2.toInstant();
    Date d = Date.from(instant);
    Date d2 = Date.from(instant2);

    Map<String,String> map = sdao.getStatMap("Active Object",0,d);
    Map<String,String> map2 = sdao.getStatMap("Active Object",0,d2);
    Map<String, String> annotMap = sbm.getOntologyManualAnnotationCount(3, 1, d); // for rat genes
    int geneCur = Integer.parseInt(map.get("GENES"));
    int genePrev = Integer.parseInt(map2.get("GENES"));
    int geneDiff = geneCur - genePrev;
%>

<table class="publicScoreboard" width="270">
    <tr>
        <td>Total Genes</td>
        <td class="scoreboardAmount"><%=map.get("GENES")%></td>
    </tr>
    <tr>
        <td>Rat Strains</td>
        <td class="scoreboardAmount"><%=map.get("STRAINS")%></td>
    </tr>
    <tr>
        <td>Total QTLs</td>
        <td class="scoreboardAmount"><%=map.get("QTLS")%></td>
    </tr>
    <tr>
        <td></td>
        <td class="scoreboardAmount"></td>
    </tr>
    <tr>
        <td>New Genes(since last week)</td>
        <td class="scoreboardAmount"><%=geneDiff%></td>
    </tr>
    <tr>
        <td>Manual Rat Gene Annotations</td>
        <td></td>
    </tr>
    <%
    for (String var : annotMap.keySet()){
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
        margin-left: auto;
        margin-right: 0;
    }
</style>