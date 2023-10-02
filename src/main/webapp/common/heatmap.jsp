<%@ page import="edu.mcw.rgd.web.UI" %>
<%@ page import="java.util.TreeMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.web.HeatMap" %>
<%

/*
   Example

    HeatMap hm = new HeatMap();

    hm.setCellWidth(24);
    hm.setCellFontSize(9);
    hm.setHeaderHeight(300);
    hm.setMaxValue(33);

    int[][] mapData = new int[3][3];
    mapData[0][0] = 10;
    mapData[0][1] = 1;
    mapData[0][2] = 33;
    mapData[1][0] = 16;
    mapData[1][1] = 4;
    mapData[1][2] = 8;
    mapData[2][0] = 31;
    mapData[2][1] = 14;
    mapData[2][2] = 10;

    hm.setMapData(mapData);

    TreeMap xAxis = new TreeMap();
    xAxis.put("Term 1", "http://www.yahoo.com");
    xAxis.put("Term 2", "http://www.google.com");
    xAxis.put("Term 3", "http://www.cnn.com");
    hm.setxAxis(xAxis);

    TreeMap yAxis = new TreeMap();
    yAxis.put("Term A", "http://www.yahoo.com");
    yAxis.put("Term B", "http://www.google.com");
    yAxis.put("Term C", "http://www.cnn.com");
    hm.setyAxis(yAxis);

    hm.setyAxisSelectedIndex(1);
    hm.setxAxisSelectedIndex(2);
*/


    //do not edit below this point
%>
<%

    int horizontalWidth=(hm.getCellWidth() +1) * hm.getMapData().length;
    int tableHeight = hm.getMapData().length * hm.getCellWidth();


    Iterator xIt = hm.getxAxis().keySet().iterator();

    for (int i=0; i< hm.getxAxisSelectedIndex(); i++ ) {
        xIt.next();
    }

    String xAxisSelectedTerm = "";
    if( xIt.hasNext() ) {
        xAxisSelectedTerm = (String) xIt.next();
    }

    Iterator yIt = hm.getyAxis().keySet().iterator();

    for (int i=0; i< hm.getyAxisSelectedIndex(); i++ ) {
        yIt.next();
    }

    String yAxisSelectedTerm = "";
    if( yIt.hasNext() ) {
        yAxisSelectedTerm = (String) yIt.next();
    }

%>


<link rel="stylesheet" href="/rgdweb/js/javascriptPopUpWindow/GAdhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/rgdweb/js/javascriptPopUpWindow/dhtmlwindow.js">

/***********************************************
* DHTML Window Widget- © Dynamic Drive (www.dynamicdrive.com)
* This notice must stay intact for legal use.
* Visit http://www.dynamicdrive.com/ for full source code
***********************************************/

</script>


<!-- heat map styles -->
<style>

    * html .iewrap      {
        float: left;
        /*width*/
        margin-left: <%=horizontalWidth%>px;
        display: inline;
        position: relative;
    }

    * html .container {
		float: left;
        /*width*/
		margin-left: -<%=horizontalWidth%>px;
		position: relative;
		}

    .container {

        position: relative;
         /* this will give container dimension, because floated child nodes don't give any */
         /* if your child nodes are inline-blocked, then you don't have to set it */
         overflow: auto;

        /*width*/
        min-width: <%=horizontalWidth%>px;

     }

     .container .head{

           /* float your elements or inline-block them to display side by side */
           float: left;
           /* these are height and width dimensions of your header */

            height: <%=hm.getHeaderHeight()%>px;
            width: <%=hm.getCellWidth()%>px;
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
                line-height: <%=hm.getCellWidth()%>px;

                /* setting background may yield better results in IE text clear type rendering */
                background: #eee;
                display: block;

                /* this will prevent it from wrapping too much text */
                white-space: nowrap;

                /* so it stays off the edge */
                padding-left: 3px;

                /* IE specific rotation code */
                writing-mode: tb-rl;
                filter: flipv fliph;

                /* CSS3 specific totation code */
                /* translate should have the same negative dimension as head height */
                transform: rotate(270deg) translate(-<%=hm.getHeaderHeight()%>px,0);
                transform-origin: 0 0;
                -moz-transform: rotate(270deg) translate(-<%=hm.getHeaderHeight()%>px,0);
                -moz-transform-origin: 0 0;
                -webkit-transform: rotate(270deg) translate(-<%=hm.getHeaderHeight()%>px,0);
                -webkit-transform-origin: 0 0;

            }

        .heatCell {
            position:relative;
            min-width: <%=hm.getCellWidth()%>px;
            min-height: <%=hm.getCellWidth()%>px;
            width:<%=hm.getCellWidth()%>px;
            height:<%=hm.getCellWidth()%>px;
            *width: <%=hm.getCellWidth() + 1%>px;
            *height: <%=hm.getCellWidth() + 1%>px;
            border-top: 1px solid white;
            border-left: 1px solid white;
            font-size: <%=hm.getCellFontSize()%>px;
            float:left;
            text-align:center;
        }

</style>



<div style="position: relative; height:<%=tableHeight + hm.getHeaderHeight() + 5%>px; width:<%=horizontalWidth + hm.getHeaderHeight()%>px; border: 1px solid black;">

    <div style="position:absolute; top: 0; left:0;">
    <table border=0>
        <tr>
            <td valign="center" style="height:<%=hm.getHeaderHeight() - 20%>px;">
                <table width="<%=hm.getHeaderHeight() -5%>" border=0>
                    <tr>
                        <td align="center" style="font-size: 18px; color: #4088B8; font-weight:700;"><%=xAxisSelectedTerm%></td>
                    </tr>
                    <tr>
                        <td align="center"style="font-size: 16px; color: #4088B8;">vs</td>
                    </tr>
                    <tr>
                        <td align="center" style="font-size: 18px; color: #4088B8; font-weight:700;"><%=yAxisSelectedTerm%></td>
                    </tr>
                </table>

            </td>
        </tr>
    </table>
    </div>
<div style="position: absolute; left:<%=hm.getHeaderHeight()%>px; top:0px;" >
    <div class="iewrap">
        <div class="container">

                 <%
                     xIt = hm.getxAxis().keySet().iterator();
                     while (xIt.hasNext()) {
                         String xAxisTerm=(String) xIt.next();
                 %>
                        <div class="head"><div id="h" class="vert">&nbsp;<a title="<%=xAxisTerm%>" href="<%=hm.getxAxis().get(xAxisTerm)%>"><%=xAxisTerm%></a></div></div>
                 <% } %>
       </div>
    </div>
</div>

<div style="position: absolute; top: <%=hm.getHeaderHeight()%>px; left:0;">

    <%
        yIt = hm.getyAxis().keySet().iterator();
        while (yIt.hasNext()) {
            String yAxisTerm=(String) yIt.next();
    %>
            <div style="background-color:#EEEEEE; width: <%=hm.getHeaderHeight()%>px;overflow: hidden; height: 24px; text-align: right;margin-top:1px;"><a  title="<%=yAxisTerm%>" href="<%=hm.getyAxis().get(yAxisTerm)%>"><%=yAxisTerm%></a>&nbsp;</div>
    <% } %>

</div>


<div style="position: absolute; top:<%=hm.getHeaderHeight()%>px; left:<%=hm.getHeaderHeight()%>px;">
    <table border=0 cellpadding=0 cellspacing=0>

    <%
         for (int k=0; k < hm.getMapData().length; k++) {
             %>
              <tr>

             <%
             for (int j=0; j < hm.getMapData()[k].length; j++) {
                 String color = UI.getRGBValue(hm.getMapData()[k][j], hm.getMaxValue());
                 String fontColor="black";

                 if (((double) hm.getMapData()[k][j]) / (double)hm.getMaxValue() > .5) {
                    fontColor="white";
                 }

                 String cursor ="default";
                 if (hm.getMapData()[k][j] > 0) {
                    cursor="pointer";
                 }

                 %>
                    <td>
                        <div id="cell<%=k%>-<%=j%>" class="heatCell" style="cursor: <%=cursor%>; color: <%=fontColor%>; background-color:<%=color%>;">
                            <%=hm.getMapData()[k][j]%></div>
                    </td>

                    <script>
                        document.getElementById("cell<%=k%>-<%=j%>").cellBgColor = "<%=color%>";
                        document.getElementById("cell<%=k%>-<%=j%>").cellFontColor = "<%=fontColor%>";
                    </script>
             <% } %>

                </tr>

             <%
         }
    %>

    </table>

    </div>

 </div>



