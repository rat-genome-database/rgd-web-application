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
    String latest = formatter.format(date);


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
<div id="publicScoreboardHeader" class="" style="border-color: transparent;margin-top:20px;">
    <h5 class="card-title">RGD Data Snapshot <%=latest%></h5>
</div>
<div id="publicScoreboard" class="publicScoreboard">
    <div class="scoreboard-header">Data Objects</div>

    <div class="scoreboard-row">
        <div class="scoreboard-label">Genes (All Species)</div>
        <div class="scoreboardAmount"><%=map.get("GENES")%></div>
    </div>

    <div class="scoreboard-row">
        <div class="scoreboard-label">Rat Strains</div>
        <div class="scoreboardAmount"><%=map.get("STRAINS")%></div>
    </div>

    <div class="scoreboard-row">
        <div class="scoreboard-label">QTLs (All Species)</div>
        <div class="scoreboardAmount"><%=map.get("QTLS")%></div>
    </div>

    <div class="scoreboard-row">
        <div class="scoreboard-label">Variants (All Species)</div>
        <div class="scoreboardAmount"><%=map.get("CLINVAR")%></div>
    </div>

    <div class="scoreboard-row">
        <div class="scoreboard-label">References</div>
        <div class="scoreboardAmount"><%=map.get("REFERENCES")%></div>
    </div>

    <div class="scoreboard-row">
        <div class="scoreboard-label">New Genes added since <%=formattedDateString%></div>
        <div class="scoreboardAmount"><%=geneDiff <= 0 ? "N/A" : String.format("%,d",geneDiff)%></div>
    </div>

    <div class="scoreboard-header">Experimental Ontology Annotations (All Species)</div>

    <div class="scoreboard-row">
        <div class="scoreboard-label">RDO: RGD Disease Ontology</div>
        <div class="scoreboardAmount"><%=annotMap.get("RDO: RGD Disease Ontology")%></div>
    </div>

    <%
    for (String var : annotMap.keySet()){
        if (var.contains("NBO:") || var.contains("RDO"))
            continue;
    %>
    <div class="scoreboard-row">
        <div class="scoreboard-label"><%=var%></div>
        <div class="scoreboardAmount"><%=annotMap.get(var)%></div>
    </div>
    <% } %>
</div>

<style>
    .publicScoreboard {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', sans-serif;
        font-size: 15px;
        border-radius: 12px;
        box-shadow: 0 2px 12px rgba(40, 101, 163, 0.12), 0 1px 3px rgba(0, 0, 0, 0.08);
        background: #ffffff;
        overflow: hidden;
        width: 100%;
    }

    .scoreboard-header {
        font-weight: 700;
        color: #ffffff;
        font-size: 13px;
        background: linear-gradient(135deg, #2865A3 0%, #1e4f7f 100%);
        text-align: center;
        padding: 14px 16px;
        letter-spacing: 0.3px;
        text-transform: uppercase;
    }

    .scoreboard-header:first-child {
        border-top-left-radius: 12px;
        border-top-right-radius: 12px;
    }

    .scoreboard-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 16px;
        border-bottom: 1px solid rgba(40, 101, 163, 0.08);
        transition: all 0.2s ease;
    }

    .scoreboard-row:nth-child(odd):not(.scoreboard-header) {
        background-color: rgba(40, 101, 163, 0.03);
    }

    .scoreboard-row:hover {
        background-color: rgba(40, 101, 163, 0.08);
        transform: translateX(2px);
    }

    .scoreboard-row:last-child {
        border-bottom: none;
        border-bottom-left-radius: 12px;
        border-bottom-right-radius: 12px;
    }

    .scoreboard-label {
        color: #2865A3;
        font-weight: 600;
        font-size: 14px;
        line-height: 1.5;
        flex: 1;
        padding-right: 16px;
    }

    .scoreboardAmount {
        text-align: right;
        font-weight: 700;
        color: #059669;
        font-size: 15px;
        font-variant-numeric: tabular-nums;
        letter-spacing: -0.01em;
        white-space: nowrap;
        flex-shrink: 0;
    }

    /* Mobile-friendly responsive styles */
    @media screen and (max-width: 1024px) {
        .publicScoreboard {
            font-size: 14px;
        }

        .scoreboard-row {
            padding: 10px 12px;
        }

        .scoreboard-label {
            font-size: 13px;
        }

        .scoreboardAmount {
            font-size: 14px;
        }

        .scoreboard-header {
            padding: 12px 12px;
            font-size: 12px;
        }
    }

    @media screen and (max-width: 768px) {
        .publicScoreboard {
            font-size: 13px;
            border-radius: 10px;
        }

        .scoreboard-row {
            padding: 10px 12px;
        }

        .scoreboard-label {
            font-size: 12px;
            padding-right: 12px;
        }

        .scoreboardAmount {
            font-size: 13px;
        }

        .scoreboard-header {
            padding: 12px 10px;
            font-size: 11px;
            letter-spacing: 0.2px;
        }

        .scoreboard-row:hover {
            transform: translateX(1px);
        }
    }

    @media screen and (max-width: 640px) {
        #publicScoreboardHeader h5 {
            font-size: 17px !important;
        }

        .publicScoreboard {
            font-size: 12px;
            border-radius: 8px;
        }

        .scoreboard-row {
            padding: 8px 10px;
        }

        .scoreboard-label {
            font-size: 11px;
            line-height: 1.4;
            padding-right: 10px;
        }

        .scoreboardAmount {
            font-size: 12px;
        }

        .scoreboard-header {
            padding: 10px 8px;
            font-size: 10px;
            letter-spacing: 0.1px;
        }
    }

    @media screen and (max-width: 480px) {
        #publicScoreboardHeader {
            margin-top: 15px !important;
        }

        #publicScoreboardHeader h5 {
            font-size: 16px !important;
            line-height: 1.3;
        }

        .publicScoreboard {
            font-size: 11px;
        }

        .scoreboard-row {
            padding: 8px 8px;
        }

        .scoreboard-label {
            font-size: 10.5px;
            padding-right: 8px;
        }

        .scoreboardAmount {
            font-size: 11px;
        }

        .scoreboard-header {
            padding: 10px 6px;
            font-size: 9px;
        }

        .scoreboard-row:hover {
            transform: none;
        }
    }

    @media screen and (max-width: 360px) {
        #publicScoreboardHeader h5 {
            font-size: 14px !important;
        }

        .publicScoreboard {
            font-size: 10px;
        }

        .scoreboard-row {
            padding: 6px 6px;
        }

        .scoreboard-label {
            font-size: 10px;
            padding-right: 6px;
        }

        .scoreboardAmount {
            font-size: 10px;
        }

        .scoreboard-header {
            padding: 8px 5px;
            font-size: 8.5px;
        }
    }

    /* Touch device optimization */
    @media (hover: none) and (pointer: coarse) {
        .scoreboard-row {
            padding: 12px 10px;
        }

        .scoreboard-row:hover {
            transform: none;
        }
    }
</style>