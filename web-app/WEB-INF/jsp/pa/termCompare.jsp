<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>
<%@ page import="edu.mcw.rgd.web.UI" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Aspect" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.OverlapReport" %>
<%@ page import="java.util.*" %>

<link rel="stylesheet" href="/rgdweb/js/javascriptPopUpWindow/GAdhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/rgdweb/js/javascriptPopUpWindow/dhtmlwindow.js">

/***********************************************
* DHTML Window Widget- © Dynamic Drive (www.dynamicdrive.com)
* This notice must stay intact for legal use.
* Visit http://www.dynamicdrive.com/ for full source code
***********************************************/

</script>

<%@ include file="gaHeader.jsp" %>
<%@ include file="rgdHeader.jsp" %>

<% try { %>


<%@ include file="menuBar.jsp" %>

 <%

    OntologyXDAO xdao = new OntologyXDAO();
    int max = Integer.MIN_VALUE;

    Term xTerm = xdao.getTermByAccId(req.getParameter("term1"));
    Term yTerm = xdao.getTermByAccId(req.getParameter("term2"));


    List<TermWithStats> xTerms = xdao.getActiveChildTerms(xTerm.getAccId(),Integer.parseInt(req.getParameter("species")));
    List<TermWithStats> yTerms = xdao.getActiveChildTerms(yTerm.getAccId(),Integer.parseInt(req.getParameter("species")));

     // if chromosome altered
     if (xTerm.getAccId().equals("RS:0000271")) {
        Comparator<TermWithStats> comparator = new Comparator<TermWithStats>(){
             public int compare(final TermWithStats o1, final TermWithStats o2){
                // let your comparator look up your car's color in the custom order

                 String t1 = o1.getTerm().replace("chromosome","").trim();
                 System.out.println(t1);

                 String t2 = o2.getTerm().replace("chromosome","").trim();
                 System.out.println(t2);

                 try {
                     if (Integer.parseInt(t1) < Integer.parseInt(t2)) {
                        return -1;
                     }else {
                         return 1;
                     }
                 } catch (Exception e) {

                 }

                 return 1;
             }
        };

         System.out.println("sorting x");
         Collections.sort(xTerms,  comparator);
     }

     if (yTerm.getAccId().equals("RS:0000271")) {
         Comparator<TermWithStats> comparator = new Comparator<TermWithStats>(){
              public int compare(final TermWithStats o1, final TermWithStats o2){
                 // let your comparator look up your car's color in the custom order
                 return 1;
              }
         };

         System.out.println("sorting y");
          Collections.sort(yTerms,  comparator);
     }

    ArrayList xAspects = new ArrayList();
    ArrayList yAspects = new ArrayList();
    Ontology xOnt = null;
    Ontology yOnt = null;

    List xAccIds=new ArrayList();
    for (TermWithStats t: xTerms) {
        xAccIds.add(t.getAccId());
    }

     //figure out which ontology this is
     if (xAccIds.size()>0) {
         xOnt = xdao.getOntologyFromAccId((String) xAccIds.get(0));
         xAspects.add(xOnt.getAspect());
     }


     List yAccIds=new ArrayList();
     for (TermWithStats t: yTerms) {
         yAccIds.add(t.getAccId());
     }

     if (yAccIds.size()>0) {
         yOnt = xdao.getOntologyFromAccId((String) yAccIds.get(0));
         yAspects.add(yOnt.getAspect());
     }

     yAspects.addAll(xAspects);

     /*
     ArrayList combinedSet = new ArrayList();
     combinedSet.addAll(xAccIds);
     combinedSet.addAll(yAccIds);
     */

    java.util.HashMap overlap = null;


     String countType="rec";

     if (!req.getParameter("countType").equals("")) {
         countType=req.getParameter("countType");
     }

    // overlap = adao.getGeneCountOverlap(om.getMappedRgdIds(),xAccIds,yAccIds);

     PhenominerDAO pdao = new PhenominerDAO();

     String column = "experiment_record_id";
     if (countType.equals("exp")) {
           column="experiment_id";
     }else if (countType.equals("study")) {
           column="study_id";
     }

    int sid =0;

     try {
         sid = Integer.parseInt(req.getParameter("sid"));
     } catch (Exception e) {

     }

     OverlapReport or = pdao.getRecordCountOverlap(xAccIds,yAccIds, column, sid);

//     overlap = pdao.getRecordCountOverlap(xAccIds,yAccIds);



     //OntologyEnrichment oe3 = adao.getOntologyEnrichment(om.getMappedRgdIds(), combinedSet, yAspects);
    // OntologyEnrichment oe3 = new OntologyEnrichment();



     int[][] mapData = new int[yTerms.size()][xTerms.size()];
     Iterator it2 = yTerms.iterator();
     int yPos=0;
     while (it2.hasNext()) {
        TermWithStats yTermWs = (TermWithStats) it2.next();

        Iterator it = xTerms.iterator();
        int xPos=0;
        while (it.hasNext()) {
            TermWithStats xTermWs = (TermWithStats) it.next();

            //List intersection = oe3.getOverlap(yTermWs.getAccId(), xTermWs.getAccId());


            //Integer val =  (Integer) overlap.get(xTermWs.getTerm() + "_" + yTermWs.getTerm());

            Integer val =  (Integer) or.getRecordCountMap().get(xTermWs.getAccId() + "_" + yTermWs.getAccId());

            if (val == null) {
                val = 0;
            }

            mapData[yPos][xPos] = val;

            if (val > max) {
                max = val;
            }

            xPos++;
        }
        yPos++;
     }

     HashMap emptyX = new HashMap();
     HashMap emptyY= new HashMap();


     if (req.getParameter("limit").equals("true")) {
         for (int i=0; i< mapData.length; i++) {
                boolean empty=true;
                for (int j=0; j< mapData[i].length; j++) {
                    int value = mapData[i][j];
                    if (value !=0) {
                        empty=false;
                    }
                }
                if (empty==true) {
                    emptyY.put(i, null);
                }
         }
         for (int j=0; j< mapData[0].length;j++) {
             boolean empty=true;
             for (int i=0; i< mapData.length; i++) {
                 int value = mapData[i][j];
                 if (value !=0) {
                     empty=false;
                 }
             }
             if (empty==true) {
                  emptyX.put(j, null);
             }
         }
     }

    //fix browser variability with regard to the width
    String ua = request.getHeader( "User-Agent" );
    boolean isFirefox = ( ua != null && ua.indexOf( "Firefox/" ) != -1 );
    boolean isMSIE = ( ua != null && ua.indexOf( "MSIE" ) != -1 );

    int horizontalWidth=0;
    if (isMSIE) {
        horizontalWidth=26*xTerms.size() ;
    }else {
        horizontalWidth=25*xTerms.size() ;
    }

 %>

<!-- heat map styles -->
<style>

    * html .iewrap      {
        float: left;
        margin-left: <%=horizontalWidth%>px;
        display: inline;
        position: relative;
    }

    * html .container {
		float: left;
		margin-left: -<%=horizontalWidth%>px;
		position: relative;
		}

    .container {

        position: relative;
         /* this will give container dimension, because floated child nodes don't give any */
         /* if your child nodes are inline-blocked, then you don't have to set it */
         overflow: auto;

        min-width: <%=horizontalWidth%>px;

     }

     .container .head{

           /* float your elements or inline-block them to display side by side */
           float: left;
           /* these are height and width dimensions of your header */

            height: 300px;
            width: 24px;
            overflow: hidden;

            /* these are not relevant and are here to better see the elements */
            background: #eee;
            margin-right: 1px;
        }


            .container .head .vert

            {
                 *position: absolute;
                 *bottom: 0;
                 *left: 0;

                /* line height should be equal to header width so text will be middle aligned */
                line-height: 24px;

                /* setting background may yield better results in IE text clear type rendering */
                background: #eee;
                display: block;

                /* this will prevent it from wrapping too much text */
                white-space: nowrap;

                /* so it stays off the edge */
                padding-left: 3px;

                /* IE specific rotation code */
                *writing-mode: tb-rl;
                *filter: flipv fliph;

                /* CSS3 specific totation code */
                /* translate should have the same negative dimension as head height */
                transform: rotate(270deg) translate(-300px,0);
                transform-origin: 0 0;
                -moz-transform: rotate(270deg) translate(-300px,0);
                -moz-transform-origin: 0 0;
                -webkit-transform: rotate(270deg) translate(-300px,0);
                -webkit-transform-origin: 0 0;

            }

        .heatCell {
            position:relative;
            min-width: 24px;
            min-height: 24px;
            width:24px;
            height:24px;
            *width: 25px;
            *height: 25px;
            border-top: 1px solid white;
            border-left: 1px solid white;
            font-size: 9px;
            float:left;
            text-align:center;
        }

    .rotate{height:200px;width:200px;padding:10px;
 FILTER: progid:DXImageTransform.Microsoft.basicimage(grayscale=0, xray=0, mirror=0, invert=0, rotation=1, opacity=1);}

</style>


<%
    //if there are errors display them
    List error = (List) request.getAttribute("error");
    if (error.size() > 0) {
        Iterator eit = error.iterator();
        while (eit.hasNext()) {
            String emsg = (String) eit.next();
            out.println("<br><br><div style='color: red; ' >" + emsg + "</div>");

        }
        return;
    }

    String sColor = "#D7E4BD";
    String mmColor = "#FCD5B5";
    String cmColor = "#CCC1DA";
    String ecColor= "#B9CDE5";
    String xBoxColor = "";
    String yBoxColor = "";

//this is a hack since selected attr was not working in firefox
int xIndex=0;
if (xOnt.getAspect().equals(Aspect.RAT_STRAIN)) {
    xIndex=0;
    xBoxColor=sColor;
}else if (xOnt.getAspect().equals(Aspect.MEASUREMENT_METHOD)) {
    xIndex=1;
    xBoxColor=mmColor;
}else if (xOnt.getAspect().equals(Aspect.CLINICAL_MEASUREMENT)) {
    xIndex=2;
    xBoxColor=cmColor;
}else if (xOnt.getAspect().equals(Aspect.EXPERIMENTAL_CONDITION)) {
    xIndex=3;
    xBoxColor=ecColor;
}

int yIndex=0;
if (yOnt.getAspect().equals(Aspect.RAT_STRAIN)) {
    yIndex=0;
    yBoxColor=sColor;
}else if (yOnt.getAspect().equals(Aspect.MEASUREMENT_METHOD)) {
    yIndex=1;
    yBoxColor=mmColor;
}else if (yOnt.getAspect().equals(Aspect.CLINICAL_MEASUREMENT)) {
    yIndex=2;
    yBoxColor=cmColor;
}else if (yOnt.getAspect().equals(Aspect.EXPERIMENTAL_CONDITION)) {
    yIndex=3;
    yBoxColor=ecColor;
}


int countTypeIndex=0;
if (countType.equals("rec")) {
    countTypeIndex=0;
}else if (countType.equals("exp")) {
    countTypeIndex=1;
}else if (countType.equals("study")) {
    countTypeIndex=2;
}

%>

<script>
    function resetPage() {
        location.href="termCompare.html?term1=RS%3A0000457&term2=CMO%3A0000000&countType=rec&species=3";
    }

</script>


<!-- sidebar-->
<br>
<div style="order:1px solid #6391B0; ackground-color: #F0F6F9; ">
<form>
<div style="border: 0px solid black; " >
    <table border=0 cellpadding=0 cellspacing=0 align="center" style="border:1px solid #6391B0; background-color: #F0F6F9;padding:5px;">
        <tr>
          <td>Update&nbsp;X&nbsp;Axis:</td>
           <td>
              <select id="term1" onChange="termCompare(this.value, '<%=yTerm.getAccId()%>','<%=countType%>');" style="background-color:<%=xBoxColor%>;">
                  <option value="RS:0000457">Rat Strain</option>
                  <option value="MMO:0000000">Measurement Method</option>
                  <option value="CMO:0000000">Clinical Measurement</option>
                  <option value="XCO:0000000">Experimental Condition</option>

              </select>
          </td>
          <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td>Update&nbsp;Y&nbsp;Axis:</td>
              <td>
                <select id="term2" onChange="termCompare('<%=xTerm.getAccId()%>',this.value,'<%=countType%>');" style="background-color:<%=yBoxColor%>;">
                    <option value="RS:0000457">Rat Strain</option>
                    <option value="MMO:0000000">Measurement Method</option>
                    <option value="CMO:0000000">Clinical Measurement</option>
                    <option value="XCO:0000000">Experimental Condition</option>
                </select>
            </td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
          <td>Count Type</td>
            <td>
              <select id="countType" onChange="termCompare('<%=xTerm.getAccId()%>','<%=yTerm.getAccId()%>',this.value);">
                  <option value="rec">Record Count</option>
                  <option value="exp">Experiment Count</option>
                  <option value="study">Study Count</option>
              </select>
          </td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td><input type="button" value="RESET" onClick="resetPage()"></td>
      </tr>
        </table>
</div>
</form>




<script>
    document.getElementById("term1").selectedIndex=<%=xIndex%>;
    document.getElementById("term2").selectedIndex=<%=yIndex%>;
    document.getElementById("countType").selectedIndex=<%=countTypeIndex%>;
</script>


<!--
<div style="margin-left:5px;">Study List</div>
<div style="height:500px; width:158px;overflow-y: auto; border:1px solid #6391B0; margin:5px; padding:5px; background-color:white;">
    <%
     int i=1;
     //Iterator symbolIt = om.getMapped().iterator();
     Iterator symbolIt = or.getStudyMap().keySet().iterator();

      while (symbolIt.hasNext()) {
         Object obj = symbolIt.next();

         String symbol = "";
         int rgdId=-1;
         String type="";

         symbol=(String) obj;
      %>

            <li><a href="javascript:termCompare('<%=xTerm.getAccId()%>','<%=yTerm.getAccId()%>','<%=countType%>', '<%=obj%>')" style="font-size:13px;" ><%=or.getStudyMap().get(obj)%></a><br></li>
       <%
       }
     %>
</div>
</div>
-->


<script>
    function excludeClicked() {

        var url = location.href.replace("&limit=true","");

        if (document.getElementById("limit").checked) {
            location.href=url+"&limit=true";
            return;
        }

        location.href=url;


    }
</script>


<div style="position:absolute; top: 90; left:10;">
<table border=0>
    <tr>
        <td valign="center" style="height:260px;">
            <table width="300" border=0>
                <tr>
                    <td style ="order:1px solid #6391B0; background-color: #F0F6F9;padding:5px; color: #2865a3; font-size: 20px; font-weight:700;"><span style="text-decoration:underline;">PhenoMiner Term Comparison</span><br><span style="font-size:14px;">(Select a box to view records)</span></td>
                </tr>
                <tr>
                    <td><br></td>
                </tr>
                <tr>
                    <td align="center" style="font-size: 18px; color: #4088B8; font-weight:700;"><%=xTerm.getTerm()%></td>
                </tr>
                <tr>
                    <td align="center"style="font-size: 16px; color: #4088B8;">vs</td>
                </tr>
                <tr>
                    <td align="center" style="font-size: 18px; color: #4088B8; font-weight:700;"><%=yTerm.getTerm()%></td>
                </tr>
            </table>

        </td>
    </tr>
    <tr>
        <td style="background-color:#F0F6F9;" align="center">Exclude empty columns and rows <input style="color:red;" id="limit" id="limit" name="limit" type="checkbox" onclick="excludeClicked()" <%if (req.getParameter("limit").equals("true")) out.print("checked");%>></td>
    </tr>
</table>
</div>



<div style="position: absolute; left: 10px; top: 95px; ">
<div style="position: absolute; left:300px; top:0px;" >
    <div class="iewrap">
        <div class="container" style="ackground-color:<%=xBoxColor%>;border-left:5px solid <%=xBoxColor%>;border-top:5px solid <%=xBoxColor%>;">
           <% Iterator dit = xTerms.iterator();
               int cnt=0;
               while(dit.hasNext()) {

                 if (emptyX.containsKey(cnt)) {
                     dit.next();
                     cnt++;
                     continue;
                 }

                 cnt++;
                 TermWithStats xTermWs = (TermWithStats) dit.next();

                 if (xTermWs.getChildTermCount() > 0) {
           %>
                 <div class="head" ><div id="h" class="vert" ><a title="<%=xTermWs.getTerm()%>" href="javascript:termCompare('<%=xTermWs.getAccId()%>','<%=req.getParameter("term2")%>','<%=countType%>');">&nbsp;<%=xTermWs.getTerm().replaceAll("\\s","&nbsp;")%></a></div></div>
           <%    } else { %>
                 <div class="head" ><div id="h" class="vert" ><a title="<%=xTermWs.getTerm()%>" style="text-decoration: none; cursor:default;  color: #771428;" href="javascript:void(0);">&nbsp;<%=xTermWs.getTerm().replaceAll("\\s","&nbsp;")%></a></div></div>


               <% }
             } %>
       </div>
    </div>
</div>

<div style="position: absolute; top: 300px; left:0;ackground-color:<%=yBoxColor%>; border-top:5px solid <%=yBoxColor%>;border-left:5px solid <%=yBoxColor%>;">
<% Iterator pit = yTerms.iterator();
   cnt=0;
   while(pit.hasNext()) {

      if (emptyY.containsKey(cnt)) {
          pit.next();
          cnt++;
          continue;
      }

      cnt++;



      TermWithStats yTermWs = (TermWithStats) pit.next();
     %>
      <div style="background-color:#EEEEEE; width: 300px;overflow: hidden; height: 24px; text-align: right;margin-top:1px;">

          <% if (yTermWs.getChildTermCount() > 0) { %>
              <a  title="<%=yTermWs.getTerm()%>" href="javascript:termCompare('<%=xTerm.getAccId()%>','<%=yTermWs.getAccId()%>','<%=countType%>');">&nbsp;<%=yTermWs.getTerm().replaceAll("\\s","&nbsp;")%></a>
          <% } else { %>
            <a  style="text-decoration: none; cursor:default;  color: #771428;" title="<%=yTermWs.getTerm()%>" href="javascript:void(0)" >&nbsp;<%=yTermWs.getTerm().replaceAll("\\s","&nbsp;")%></a>
          <% } %>
      </div>
     <%
  }
   %>
</div>

<div style="min-width: <%=horizontalWidth%>px; position: absolute; top:305px; left:305px; width:<%=horizontalWidth%>px; border:0px solid red;">
    <table border=0 cellpadding=0 cellspacing=0>
    <%
     for (int k=0; k < mapData.length; k++) {
         %>
          <tr>

        <!--<div style="position:relative; width:<%=horizontalWidth%>px; border:0px solid orange; ">-->
         <%
         for (int j=0; j < mapData[k].length; j++) {

             if (emptyX.containsKey(j) || emptyY.containsKey(k)) {
                 continue;
             }

             String color = UI.getRGBValue(mapData[k][j], max);
             String fontColor="black";

             if (((double) mapData[k][j]) / (double)max > .5) {
                fontColor="white";
             }

             String cursor ="default";
             if (mapData[k][j] > 0) {
                cursor="pointer";
             }

             %>
                 <td><div id="cell<%=k%>-<%=j%>" class="heatCell" style="cursor: <%=cursor%>; color: <%=fontColor%>; background-color:<%=color%>;"><%=mapData[k][j]%></div></td>
                <script>
                    document.getElementById("cell<%=k%>-<%=j%>").cellBgColor = "<%=color%>";
                    document.getElementById("cell<%=k%>-<%=j%>").cellFontColor = "<%=fontColor%>";
                </script>
         <% } %>
         <!-- </div>-->
              </tr>

         <%
     }
%>
     </table>
    <br>&nbsp;<br>&nbsp;<br>&nbsp;
</div>
</div>

<!-- heat map script -->
<script>

    function getKeys (o) {
        var result = [];
        for(var name in o) {
            if (o.hasOwnProperty(name))
              result.push(name);
        }
        return result;
}   ;


    function getTarget(e) {
        return document.all ? e.srcElement : e.currentTarget;
    }

    var mapCellColor="";
    var permHighlight = false;


    function mouseOutHighlight() {

         if (permHighLight) return;

        keys = getKeys(document.heatmap);
        for (i=0; i< keys.length; i++) {
            document.heatmap[keys[i]].style.backgroundColor=  document.heatmap[keys[i]].cellBgColor;
            document.heatmap[keys[i]].style.color=  document.heatmap[keys[i]].cellFontColor;

        }

    }

    function scrollToTop() {

        var obj = document.getElementById("ajaxbox");

        for (i=0; i< obj.children.length; i++) {
            if (obj.children[i].className=="drag-contentarea") {
                obj.children[i].scrollTop=1;
            }
        }
    }

    function clearHighlight() {
        keys = getKeys(document.heatmap);
        for (i=0; i< keys.length; i++) {
            document.heatmap[keys[i]].style.backgroundColor=  document.heatmap[keys[i]].cellBgColor;
            document.heatmap[keys[i]].style.color=  document.heatmap[keys[i]].cellFontColor;

        }
        permHighlight=false
        document.getElementById("clear").style.visibility="hidden";

    }

    function mouseOverHighlight(gene) {


        permHighlight=true;
        clearHighlight();

        keys = getKeys(document.heatmap);

        for (i=0; i< keys.length; i++) {
            if (document.heatmap[keys[i]].genes[gene]) {
                document.heatmap[keys[i]].style.backgroundColor="#FFCF3E";
                document.heatmap[keys[i]].style.color="#000000";
                document.getElementById("clear").style.visibility="visible";
            }

        }

    }

    function postToPhenominer(e) {

        if (!e) e = window.event;
        var firedDiv = getTarget(e);

        if(firedDiv.innerHTML.trim() == "0") {
            alert("Zero Records Found");
            return;
        }

        var cnt = parseInt(firedDiv.innerHTML.trim());

        if (cnt > 1000) {
            alert("A maximum of 1000 records can be viewed at a time.  Please filter your list by selecting an ontology term.");
            return;
        }



        //params = new Object();
       // params = {"method": "getChildren","terms":firedDiv.term1 + "," + firedDiv.term2};

        var urlStr = "/rgdweb/webservice/ontology.html?type=min&method=getChildrenWithRecords&terms=" + firedDiv.term1 + "," + firedDiv.term2;

        $.get(urlStr, function(data, status){

           // if (!e) e = window.event;
           // var firedDiv = getTarget(e);

            params = new Object();
            params = {"method": "getChildrenWithRecords","terms":data};

            postIt("/rgdweb/phenominer/table.html", params);
            return;

        });

    }

    function showGenes(e) {
        if (!e) e = window.event;
        var firedDiv = getTarget(e);

        params = new Object();
        params = {"method": "getChildren","terms":firedDiv.term1 + "," + firedDiv.term2};

        postIt("/rgdweb/webservice/ontology.html", params);
        return;


        if (!e) e = window.event;
        var firedDiv = getTarget(e);

        params = new Object();
        params = {"term1":firedDiv.term1, "term2": firedDiv.term2};

        postIt("/rgdweb/pa/window.html", params);
        return;



        var geneList = getKeys(firedDiv.genes);

        var genes = "";
        for (i=0; i< geneList.length; i++) {
            if (genes.length==0) {
                genes += geneList[i];

            }else {
                genes += "," + geneList[i];
            }
        }

        var genes = '<%=request.getParameter("genes")%>';


        var method = "POST";
    if (genes.length < 1500) {
        method="GET";

    }
        /*
        var url = "/rgdweb/ga/window.html?term1=" + firedDiv.term1 + "&term2=" + firedDiv.term2 + "&genes=" + genes + "&species=<%=req.getParameter("species")%>";
        var googlewin=dhtmlwindow.open("ajaxbox", "ajax", url,"Common Gene Annotations", "width=600px,height=400px,resize=1,scrolling=1,center=1", "recal")
        setTimeout("scrollToTop()",200);
        */

        var form = document.createElement("form");
        form.setAttribute("method", "post");
        form.setAttribute("action", "/rgdweb/pa/window.html");

         var hiddenField = document.createElement("input");
         hiddenField.setAttribute("type", "hidden");
         hiddenField.setAttribute("name", "term1");
         hiddenField.setAttribute("value", firedDiv.term1);

         form.appendChild(hiddenField);

        var hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", "term2");
        hiddenField.setAttribute("value", firedDiv.term2);

        form.appendChild(hiddenField);

        var hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", "genes");
        hiddenField.setAttribute("value", genes);

        form.appendChild(hiddenField);

        var hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", "species");
        hiddenField.setAttribute("value", "<%=req.getParameter("species")%>");

        form.appendChild(hiddenField);

        var hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", "mapKey");
        hiddenField.setAttribute("value", "<%=req.getParameter("mapKey")%>");

        form.appendChild(hiddenField);

        document.body.appendChild(form);
        form.submit();
    }

    document.heatmap=new Object();

<%
it2 = yTerms.iterator();
yPos=0;
while (it2.hasNext()) {


   TermWithStats yTermWs = (TermWithStats) it2.next();

   Iterator it = xTerms.iterator();
   int xPos=0;
   while (it.hasNext()) {
       TermWithStats xTermWs = (TermWithStats) it.next();

       if (!emptyX.containsKey(xPos) && !emptyY.containsKey(yPos)) {

   %>
   document.getElementById("cell<%=yPos%>-<%=xPos%>").genes = new Object();
   <%

       //List intersection = oe3.getOverlap(yTermWs.getAccId(), xTermWs.getAccId());
       //List intersection = new ArrayList();

       //Iterator intersectIt = intersection.iterator();

      //  int count=0;
      // while (intersectIt.hasNext()) {
       //     GeneWrapper gw = (GeneWrapper) intersectIt.next();

       %>
            //document.getElementById("cell<%=yPos%>-<%=xPos%>").genes["%=gw.getGene().getSymbol()%>"] = "%=gw.getGene().getRgdId()%>";
            document.getElementById("cell<%=yPos%>-<%=xPos%>").term1= "<%=xTermWs.getAccId()%>";
            document.getElementById("cell<%=yPos%>-<%=xPos%>").term2= "<%=yTermWs.getAccId()%>";
            document.getElementById("cell<%=yPos%>-<%=xPos%>").onclick=postToPhenominer;
            document.heatmap["cell<%=yPos%>-<%=xPos%>"] = document.getElementById("cell<%=yPos%>-<%=xPos%>");
       <%
       //}
       }

       xPos++;
   }
   yPos++;
}
%>
</script>


<br><br><br><br><br><br><br><br><br><br>

<%
} catch (Exception e) {
    e.printStackTrace();
}
    %>
