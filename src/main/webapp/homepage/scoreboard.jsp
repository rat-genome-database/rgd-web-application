<%@ page import="edu.mcw.rgd.dao.impl.StatisticsDAO" %>
<%@ page import="java.time.temporal.TemporalAdjusters" %>
<%@ page import="java.time.*" %>
<%@ page import="edu.mcw.rgd.stats.ScoreBoardManager" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<div id="publicScoreboardHeader" class="" style="border-color: transparent;margin-top:20px;">
    <h5 class="card-title">Scoreboard</h5>
</div>
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
    Map<String, String> annotMap = sdao.getStatMap("Ontology Annotations", 0, date); // species, rgd obj, date - for all rgd objects and species
    int geneCur = Integer.parseInt(map.get("GENES"));
    int genePrev = Integer.parseInt(map2.get("GENES"));
    int geneDiff = geneCur - genePrev;
//    Map<String, Integer> mapInt = new HashMap<>();
    for (String key : map.keySet()){
        int val = Integer.parseInt(map.get(key));
        map.put(key,String.format("%,d",val));
    }
    for (String key : annotMap.keySet()){
        int val = Integer.parseInt(annotMap.get(key));
        annotMap.put(key,String.format("%,d",val));
    }
%>

<table id="publicScoreboard" class="publicScoreboard">
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
        <td>Variants (All Species)</td>
        <td class="scoreboardAmount"><%=map.get("CLINVAR")%></td>
    </tr>
    <tr>
        <td>References</td>
        <td class="scoreboardAmount"><%=map.get("REFERENCES")%></td>
    </tr>
    <tr>
        <td>New Genes added since <%=formattedDateString%></td>
        <td class="scoreboardAmount"><%=geneDiff <= 0 ? "N/A" : String.format("%,d",geneDiff)%></td>
    </tr>
    <tr>
        <td colspan="2">Ontology Annotations</td>
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
        font-family: 'Arial', 'Helvetica', sans-serif;
        font-size: 14px;
        border: 2px solid #2865A3;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(40, 101, 163, 0.15);
        background: linear-gradient(135deg, #ffffff 0%, #f8fbff 100%);
        margin: 0 auto;
        overflow: hidden;
        width: inherit;
    }
    
    .publicScoreboard tr:nth-child(odd) {
        background-color: rgba(40, 101, 163, 0.05);
    }
    
    .publicScoreboard tr:hover {
        background-color: rgba(40, 101, 163, 0.1);
        transition: background-color 0.3s ease;
    }
    
    .publicScoreboard td {
        padding: 12px 16px;
        border-bottom: 1px solid rgba(40, 101, 163, 0.1);
        color: #2c3e50;
        font-weight: 500;
    }
    
    .publicScoreboard td:first-child {
        color: #2865A3;
        font-weight: 600;
        border-right: 1px solid rgba(40, 101, 163, 0.1);
    }
    
    .scoreboardAmount{
        text-align: right;
        font-weight: 700;
        color: #27ae60;
        font-size: 16px;
    }
    
    .publicScoreboard tr:first-child td {
        border-top: none;
    }
    
    .publicScoreboard tr:last-child td {
        border-bottom: none;
    }
    
    /*!* Empty row styling *!*/
    /*.publicScoreboard tr:nth-child(4) {*/
    /*    height: 8px;*/
    /*    background: transparent;*/
    /*}*/
    
    /*.publicScoreboard tr:nth-child(4) td {*/
    /*    border: none;*/
    /*    padding: 4px;*/
    /*}*/
    
    /* Manual annotations section header */
    .publicScoreboard tr:nth-child(7) td{
        font-weight: 700;
        color: #8b4513;
        font-size: 15px;
        background: linear-gradient(90deg, rgba(139, 69, 19, 0.1) 0%, transparent 100%);
        border-top: 2px solid rgba(139, 69, 19, 0.2);
    }
</style>