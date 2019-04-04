<%@ page import="edu.mcw.rgd.datamodel.annotation.OntologyEnrichment" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>
<%@ page import="edu.mcw.rgd.web.UI" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.GeneWrapper" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Aspect" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>

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

<% if (om.getMapped().size()==0) { %>
    <br>
    <div style="font-size:20px; font-weight:700;"><%=om.getMapped().size()%> Genes in set</div>
<%  return;
    } %>
 <%




    OntologyXDAO xdao = new OntologyXDAO();
    int max = Integer.MIN_VALUE;

    Term xTerm = xdao.getTermByAccId(req.getParameter("term1"));
    Term yTerm = xdao.getTermByAccId(req.getParameter("term2"));
    List<TermWithStats> xTerms = xdao.getActiveChildTerms(xTerm.getAccId(),Integer.parseInt(req.getParameter("species")));
    List<TermWithStats> yTerms = xdao.getActiveChildTerms(yTerm.getAccId(),Integer.parseInt(req.getParameter("species")));

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


         overlap = adao.getGeneCountOverlap(om.getMappedRgdIds(),xAccIds,yAccIds);




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

            Integer val =  (Integer) overlap.get(xTermWs.getAccId() + "_" + yTermWs.getAccId());

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

    if (om.getMapped().size() ==0) {
        out.println("<br><br><div style='color: red; ' >0 Genes Found</div>");
        return;
    }

%>

<!-- sidebar-->
<br>
<div style="border:1px solid #6391B0; background-color: #F0F6F9; width:180px; height:500px;">
<form>
<div style="border: 0px solid black; " >
    <table border=0 cellpadding=0 cellspacing=0 align="center">
        <tr>
          <td>Update&nbsp;X&nbsp;Axis:</td>
        </tr>
        <tr>
           <td>

              <select id="term1" onChange="termCompare(this.value, '<%=yTerm.getAccId()%>')">
                  <option value="DOID:4">Disease</option>
                  <option value="PW:0000001">Pathway</option>
             <% if(Integer.parseInt(req.getParameter("species")) == SpeciesType.HUMAN) { %>  <option value="HP:0000001">Phenotype</option>
             <% } else %> <option value="MP:0000001">Phenotype</option>
                  <option value="GO:0008150">GO: Biological Process</option>
                  <option value="GO:0005575">GO: Cellular Component</option>
                  <option value="GO:0003674">GO: Molecular Function</option>
                  <option value="CHEBI:0">ChEBI</option>
                  <!--<option value="CHEBI:24432">CHEBI:Biological Role</option>-->
              </select>
          </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td>Update&nbsp;Y&nbsp;Axis:</td>
          </tr>
          <tr>
              <td>
                <select id="term2" onChange="termCompare('<%=xTerm.getAccId()%>',this.value);">
                    <option value="DOID:4">Disease</option>
                    <option value="PW:0000001">Pathway</option>
                    <% if(Integer.parseInt(req.getParameter("species")) == SpeciesType.HUMAN) { %>  <option value="HP:0000001">Phenotype</option>
                    <% } else %> <option value="MP:0000001">Phenotype</option>
                    <option value="GO:0008150">GO: Biological Process</option>
                    <option value="GO:0005575">GO: Cellular Component</option>
                    <option value="GO:0003674">GO: Molecular Function</option>
                    <option value="CHEBI:0">ChEBI</option>
                </select>
            </td>
        </tr>
        </table>
</div>
</form>

    <%
    //this is a hack since selected attr was not working in firefox
    int xIndex=0;
    if (xOnt.getAspect().equals(Aspect.DISEASE)) {
        xIndex=0;
    }else if (xOnt.getAspect().equals(Aspect.PATHWAY)) {
        xIndex=1;
    }else if (xOnt.getAspect().equals(Aspect.MAMMALIAN_PHENOTYPE)) {
        xIndex = 2;
    }else if(xOnt.getAspect().equals(Aspect.HUMAN_PHENOTYPE)) {
        xIndex = 2;
    }else if (xOnt.getAspect().equals(Aspect.BIOLOGICAL_PROCESS)) {
        xIndex=3;
    }else if (xOnt.getAspect().equals(Aspect.CELLULAR_COMPONENT)) {
        xIndex=4;
    }else if (xOnt.getAspect().equals(Aspect.MOLECULAR_FUNCTION)) {
        xIndex=5;
    }else if (xOnt.getAspect().equals(Aspect.CHEBI)) {
        xIndex=6;
    }

    int yIndex=0;
    if (yOnt.getAspect().equals(Aspect.DISEASE)) {
        yIndex=0;
    }else if (yOnt.getAspect().equals(Aspect.PATHWAY)) {
        yIndex=1;
    }else if (yOnt.getAspect().equals(Aspect.MAMMALIAN_PHENOTYPE)) {
        yIndex=2;
    }else if (yOnt.getAspect().equals(Aspect.HUMAN_PHENOTYPE)) {
        yIndex=2;
    }else if (yOnt.getAspect().equals(Aspect.BIOLOGICAL_PROCESS)) {
        yIndex=3;
    }else if (yOnt.getAspect().equals(Aspect.CELLULAR_COMPONENT)) {
       yIndex=4;
    }else if (yOnt.getAspect().equals(Aspect.MOLECULAR_FUNCTION)) {
        yIndex=5;
    }else if (yOnt.getAspect().equals(Aspect.CHEBI)) {
        yIndex=6;
    }



    %>



<script>
    document.getElementById("term1").selectedIndex=<%=xIndex%>
    document.getElementById("term2").selectedIndex=<%=yIndex%>
</script>


<div style="margin-left:5px;">Gene List</div>
<div style="height:300px; width:158px;overflow-y: auto; border:1px solid #6391B0; margin:5px; padding:5px; background-color:white;">
    <%
     int i=1;
     Iterator symbolIt = om.getMapped().iterator();
     while (symbolIt.hasNext()) {
         Object obj = symbolIt.next();

         String symbol = "";
         int rgdId=-1;
         String type="";

         if (obj instanceof Gene) {
             Gene g = (Gene) obj;
             symbol=g.getSymbol();
             rgdId=g.getRgdId();
             type="gene";
         }
         if (obj instanceof String) {
             symbol=(String) obj;
             rgdId=-1;
         }

        if (rgdId==-1) {
        %>
            <span style="color:red; font-weight:700;"><%=symbol%></span><span style="font-size:11px;">&nbsp;(<%=i%>)</span><br>

        <% } else { %>
            <a style="font-size:18px;" ><%=symbol%></a><span style="font-size:11px;">&nbsp;(<%=i%>)</span><br>
        <% }
           i++;
     }
     %>
</div>
</div>

<div style="position:absolute; top: 80; left:210;">
<table border=0>
    <tr>
        <td valign="center" style="height:280px;">
            <table width="300" border=0>
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
</table>
</div>

<div style="position: absolute; left: 210px; top: 85px; ">
<div style="position: absolute; left:300px; top:0px;" >
    <div class="iewrap">
        <div class="container">
           <% Iterator dit = xTerms.iterator();
             while(dit.hasNext()) {
                 TermWithStats xTermWs = (TermWithStats) dit.next();

                 if (xTermWs.getChildTermCount() > 0) {
           %>
                 <div class="head"><div id="h" class="vert"><a title="<%=xTermWs.getTerm()%>" href="javascript:termCompare('<%=xTermWs.getAccId()%>','<%=req.getParameter("term2")%>');">&nbsp;<%=xTermWs.getTerm().replaceAll("\\s","&nbsp;")%></a></div></div>
           <%    } else { %>
                 <div class="head"><div id="h" class="vert"><a title="<%=xTermWs.getTerm()%>" style="text-decoration: none; cursor:default;  color: #771428;" href="javascript:void(0);">&nbsp;<%=xTermWs.getTerm().replaceAll("\\s","&nbsp;")%></a></div></div>


               <% }
             } %>
       </div>
    </div>
</div>

<div style="position: absolute; top: 300px; left:0;">
<% Iterator pit = yTerms.iterator();
  while(pit.hasNext()) {
      TermWithStats yTermWs = (TermWithStats) pit.next();
     %>
      <div style="background-color:#EEEEEE; width: 300px;overflow: hidden; height: 24px; text-align: right;margin-top:1px;">

          <% if (yTermWs.getChildTermCount() > 0) { %>
              <a  title="<%=yTermWs.getTerm()%>" href="javascript:termCompare('<%=xTerm.getAccId()%>','<%=yTermWs.getAccId()%>');">&nbsp;<%=yTermWs.getTerm().replaceAll("\\s","&nbsp;")%></a>
          <% } else { %>
            <a  style="text-decoration: none; cursor:default;  color: #771428;" title="<%=yTermWs.getTerm()%>" href="javascript:void(0)" >&nbsp;<%=yTermWs.getTerm().replaceAll("\\s","&nbsp;")%></a>
          <% } %>
      </div>
     <%
  }
   %>
</div>

<div style="min-width: <%=horizontalWidth%>px; position: absolute; top:300px; left:300px; width:<%=horizontalWidth%>px; border:0px solid red;">
    <table border=0 cellpadding=0 cellspacing=0>
    <%
     for (int k=0; k < mapData.length; k++) {
         %>
          <tr>

        <!--<div style="position:relative; width:<%=horizontalWidth%>px; border:0px solid orange; ">-->
         <%
         for (int j=0; j < mapData[k].length; j++) {
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

    function showGenes(e) {
        if (!e) e = window.event;
        var firedDiv = getTarget(e);

        params = new Object();
        params = {"term1":firedDiv.term1, "term2": firedDiv.term2};

        postIt("/rgdweb/ga/window.html", params);
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
        form.setAttribute("action", "/rgdweb/ga/window.html");

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
            document.getElementById("cell<%=yPos%>-<%=xPos%>").onclick=showGenes;
            document.heatmap["cell<%=yPos%>-<%=xPos%>"] = document.getElementById("cell<%=yPos%>-<%=xPos%>");
       <%
       //}

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
