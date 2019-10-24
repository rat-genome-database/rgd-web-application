<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="edu.mcw.rgd.datamodel.MappedGene" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>

<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>









<%
    GeneDAO geneDAO = new GeneDAO();

    String zoom = request.getParameter("z");
    String chr=request.getParameter("chr");
    String fromSpecies=request.getParameter("fs");
    String toSpecies=request.getParameter("ts");

    if (zoom == null || zoom.equals("")) {
        zoom = ".0005";
    }
    if (chr == null || chr.equals("")) {
        chr = "10";
    }
    if (fromSpecies == null || fromSpecies.equals("")) {
        fromSpecies = "3";
    }
    if (toSpecies == null || toSpecies.equals("")) {
        toSpecies = "1";
    }

%>


<script>
    new Vue({
        el: '#app',
        data: {
            message: 'Hello Vue.js!'
        }
    })

</script>












<div id="app">
    <p>{{ message }}</p>
    <input v-model="message">
</div>




<a href="javascript:zoom(.5)">click</a>


<path class="button" onclick="pan(0, 25)" d="M25 5 l6 10 a20 35 0 0 0 -12 0z" />
<path class="button" onclick="pan(25, 0)" d="M5 25 l10 -6 a35 20 0 0 0 0 12z" />
<path class="button" onclick="pan(0,-25)" d="M25 45 l6 -10 a20, 35 0 0,1 -12,0z" />
<path class="button" onclick="pan(-25, 0)" d="M45 25 l-10 -6 a35 20 0 0 1 0 12z" />

<circle class="button" cx="25" cy="20.5" r="4" onclick="zoom(0.8)"/>
<circle class="button" cx="25" cy="29.5" r="4" onclick="zoom(1.25)"/>

<form action="check.jsp">
<table style="border: 1px solid black;">
    <tr>
        <td>Zoom Ratio:</td>
        <td><input type="text" name="z" value="<%=zoom%>" size="10"/></td>
        <td>Base Species:</td>
        <td><input type="text" name="fs" value="<%=fromSpecies%>" size="10"/></td>
        <td>To Species:</td>
        <td><input type="text" name="ts" value="<%=toSpecies%>" size="10"/></td>
        <td>Chromosome:</td>
        <td><input type="text" name="chr" value="<%=chr%>" size="5"/></td>

    <td><input type="submit" value="update"></td>
    </tr>
</table>
</form>



<style>
    .bars {
        border:2px solid black;
    }
</style>









<script>
    //build gene map

    var genes = new Array();

    <%
    List<MappedGene> genes = geneDAO.getActiveMappedGenesBySpecies(Integer.parseInt(fromSpecies), chr);

    int i=0;
    for (MappedGene gene: genes) {
        if (gene.getChromosome().equals(chr)) {
            int y = (int)(gene.getStart() * Double.parseDouble(zoom));
            int geneLen = (int) ((gene.getStop() - gene.getStart()) * Double.parseDouble(zoom));
%>
    genes[<%=i%>] = new Object();
    genes[<%=i%>].rgdId="<%=gene.getGene().getRgdId()%>";
    genes[<%=i%>].symbol="<%=gene.getGene().getSymbol()%>";
    genes[<%=i%>].start=<%=gene.getStart()%>;
    genes[<%=i%>].stop=<%=gene.getStop()%>;

    <%
        i++;
        }
    }
%>

</script>



<svg height="60000" width="1800" id="map-svg"  viewBox="0 0 1800 60000" style="border:1px solid black;">
    <g class="genes" id="genes">
    </g>
</svg>



<script>

    var scale = <%=zoom%>;





</script>



<script>

    var synMap= Array();

<%

    //build the synteny map
    try {

        Connection c = geneDAO.getConnection();

        Statement s = c.createStatement();
        ResultSet rs = s.executeQuery("select * from synteny where chromosome1 = '" + chr + "' and map_key1=" + MapManager.getInstance().getReferenceAssembly(Integer.parseInt(fromSpecies)).getKey() + " and map_key2=" + MapManager.getInstance().getReferenceAssembly(Integer.parseInt(toSpecies)).getKey() + " order by start_pos1");

        //System.out.println("select * from synteny where chromosome1 = '" + chr + "' and species1=" + fromSpecies + " and species2=" + toSpecies + " order by start_pos1");

        while (rs.next()) {
            %>
                var obj = Object();

                obj.chr = "<%=rs.getString("chromosome1")%>";
                obj.start=<%=rs.getString("start_pos1")%>;
                obj.stop=<%=rs.getString("stop_pos1")%>;
                obj.fromMap = <%=rs.getString("map_key1")%>;
                obj.toMap =  <%=rs.getString("map_key2")%>;
                obj.orientation=<%=rs.getString("orientation")%>;
                obj.synChr = "<%=rs.getString("chromosome2")%>";
                obj.synStart=<%=rs.getString("start_pos2")%>;
                obj.synStop=<%=rs.getString("stop_pos2")%>;

                synMap[synMap.length] = obj;
            <%
        }
        c.close();

    }catch (Exception e) {
        e.printStackTrace();
    }
%>

</script>


<script>

    var chrLen = 282763074;
    var svgns = "http://www.w3.org/2000/svg";
    var scale=<%=zoom%>;
    var step = 1000000;
    var topX = 20;
    var topY=30;


    function buildChr() {
        var chrBacking = document.createElementNS(svgns, 'rect');
        chrBacking.setAttributeNS(null,"fill","#E0E0E0");
        chrBacking.setAttributeNS(null,"x",170 + topX);
        chrBacking.setAttributeNS(null,"y",topY);
        chrBacking.setAttributeNS(null,"width",'25');
        chrBacking.setAttributeNS(null,"height",10000);
        document.getElementById('genes').appendChild(chrBacking);
    }

    function buildScale() {
        for (i=0; i<chrLen; i++) {

            var line = document.createElementNS(svgns, 'line');
            line.setAttributeNS(null,"x1",200 + topX);
            line.setAttributeNS(null,"y1",0 + topY);
            line.setAttributeNS(null,"x2",200 + topX);
            line.setAttributeNS(null,"y2",2000 + topY);
            line.setAttributeNS(null,"style","stroke:rgb(255,0,0);stroke-width:4");

            //alert(parseInt(i * (scaleSep * scale)));
            document.getElementById('genes').appendChild(line);


            line = document.createElementNS(svgns, 'line');
            line.setAttributeNS(null,"x1",200 + topX);
            line.setAttributeNS(null,"y1",parseInt(i * (step * scale)) + topY);
            line.setAttributeNS(null,"x2",215 + topX);
            line.setAttributeNS(null,"y2",parseInt(i * (step * scale)) + topY);
            line.setAttributeNS(null,"style","stroke:rgb(255,0,0);stroke-width:2");

            //alert(parseInt(i * (scaleSep * scale)));
            document.getElementById('genes').appendChild(line);

            var text = document.createElementNS(svgns, 'text');
            text.setAttributeNS(null,"x",220 + topX);
            text.setAttributeNS(null,"y",parseInt(i * (step * scale)) + 3 + topY);
            text.setAttributeNS(null,"fill","black");
            text.setAttributeNS(null,"style","font-size:14px;");
            text.innerHTML=commaFormat(i * step);

            document.getElementById('genes').appendChild(text);

            if ( (i * step) > chrLen) {
                break;
            }

        }
    }




    function mapRootGenes() {
        for (i=0; i<genes.length; i++) {

            var y = topY + (genes[i].start * scale);
            var x = topX + 100;
            var barLen= x + 20;

            var geneLen = (genes[i].stop - genes[i].start) * scale;

            var text = document.createElementNS(svgns, 'text');
            text.setAttributeNS(null, 'x', topX);
            text.setAttributeNS(null, 'y', y );
            text.setAttributeNS(null, 'fill', "#2865A3");
            text.setAttributeNS(null, 'style', "font-size:10px;");
            text.innerHTML="<a target='_blank' href='https://rgd.mcw.edu/rgdweb/report/gene/main.html?id=" + genes[i].rgdId + "'>" + genes[i].symbol + "</a>";

            document.getElementById('genes').appendChild(text);


            var polygon = document.createElementNS(svgns, 'polygon');
            polygon.setAttributeNS(null, 'points', x + "," + y + " " + barLen + "," + y + " " + barLen + "," + (parseInt(y+geneLen)));
            polygon.setAttributeNS(null, 'style', 'fill:lime;stroke:purple;stroke-width:1;');
            document.getElementById('genes').appendChild(polygon);

        }
    }

    function mapSyntenyBlocks() {

/*
        for (i = 0; i < synMap.length; i++) {

            var obj = rec = synMap[i];
            alert(JSON.stringify(obj));
            if (i=3) break;
        }
*/

        for (i = 0; i < synMap.length; i++) {

            var obj = rec = synMap[i];
            var title = document.createElementNS(svgns, 'title');
            title.innerHTML = "Species: " + rec.fromSpecies + "Chr" + rec.chr + ": " + commaFormat(rec.start) + " .. " + commaFormat(rec.stop) + " Mapped to Species: " + rec.toSpecies + " chr" + rec.synChr + ": " + commaFormat(rec.synStart) + ".." + commaFormat(rec.synStop);

            var yVal = parseInt((rec.start * scale)) + topY;

            var rect = document.createElementNS(svgns, 'rect');
            rect.setAttributeNS(null, 'x', 170 + topX);
            rect.setAttributeNS(null, 'y', yVal);
            rect.setAttributeNS(null, 'height', parseInt(((rec.stop - rec.start) * scale)));
            rect.setAttributeNS(null, 'width', 25);
            rect.setAttributeNS(null, 'fill', "green");
            rect.appendChild(title);

            document.getElementById('genes').appendChild(rect);

            if (parseInt((rec.start * scale)) + topY > 20) {
                var text = document.createElementNS(svgns, 'text');
                text.setAttributeNS(null, 'x', 170 + topX + 3);
                text.setAttributeNS(null, 'y', yVal + 20);
                text.setAttributeNS(null, 'fill', "white");
                text.setAttributeNS(null, 'style', "font-size:16px;");
                text.innerHTML=rec.chr;
                document.getElementById('genes').appendChild(text);
            }



            /*
                        var ortho = document.createElementNS(svgns, 'rect');
                        ortho.setAttributeNS(null, 'x', 370 + topX);
                        ortho.setAttributeNS(null, 'y', parseInt((rec.start * scale)) + topY);
                        ortho.setAttributeNS(null, 'height', parseInt(((rec.stop - rec.start) * scale)));
                        ortho.setAttributeNS(null, 'width', 25);
                        ortho.setAttributeNS(null, 'fill', "green");
                        ortho.appendChild(title);

                        document.getElementById('genes').appendChild(ortho);

                        var text = document.createElementNS(svgns, 'text');
                        text.setAttributeNS(null, 'x', 370 + topX);
                        text.setAttributeNS(null, 'y', parseInt((rec.start * scale)) + topY + 15);
                        text.setAttributeNS(null, 'fill', "#FECF10");
                        text.setAttributeNS(null, 'style', "font-size:16px;");
                        text.innerHTML=rec.synChr;
                        document.getElementById('genes').appendChild(text);
             */

        }
    }


    function orderBySynChr(localMap) {

        var chrHash= {};
        var chrArr = [];

        var sortedByChr = [];

        for (i = 0; i < localMap.length; i++) {
            var currentChr = localMap[i].synChr;

            if (chrHash[currentChr] == null) {
                for (y=0; y< localMap.length; y++) {
                    if (localMap[y].synChr == currentChr) {
                        chrArr[chrArr.length] = currentChr;
                        sortedByChr[sortedByChr.length] = localMap[y];
                    }
                }
                chrHash[currentChr] = 1;
            }
        }

        return sortedByChr;
//        console.log(JSON.stringify(chrArr));
    }



    function sout(str) {
        console.log(str);
    }

    function oout(obj) {
        console.log(JSON.stringify(obj));
    }

    function orderSyn(localMap) {

        var chunk = [];

        var sortedSynMap=[];
        //console.log(JSON.stringify(sortedSynMap));

        var currentChr = localMap[0].synChr;
        for (i = 0; i < localMap.length; i++) {
            var obj = localMap[i];
            if (!obj) { continue; }
            if (obj.synChr==currentChr) {
                chunk[chunk.length] = obj;
            }else {
                var sorted = mergeSort(chunk);

                for (j=0; j<sorted.length; j++) {
                    sortedSynMap[sortedSynMap.length] = sorted[j];

                }

                chunk=[];
                chunk[0] = obj;
                currentChr=obj.synChr;
            }
        }

        sorted = mergeSort(chunk);

        for (j=0; j<sorted.length; j++) {
            sortedSynMap[sortedSynMap.length] = sorted[j];
        }

        return sortedSynMap;

        //console.log("total map " + JSON.stringify(sortedSynMap));

    }

    function mergeSort(list) {
        const len = list.length
        //sout("len = " + len);
        // an array of length == 1 is technically a sorted list
        if (len == 1) {
            return list
        }

        // get mid item
        const middleIndex = Math.ceil(len / 2)

        // split current list into two: left and right list
        let leftList = list.slice(0, middleIndex)
        let rightList = list.slice(middleIndex, len)

        leftList = mergeSort(leftList)
        rightList = mergeSort(rightList)

        return merge(leftList, rightList)
    }

    // Solve the sub-problems and merge them together
    function merge(leftList, rightList) {
        const sorted = []
        while (leftList.length > 0 && rightList.length > 0) {
            const leftItem = leftList[0]
            const rightItem = rightList[0]
            if (leftItem.synStart > rightItem.synStart) {
                sorted.push(rightItem)
                rightList.shift()
            } else {
                sorted.push(leftItem);
                leftList.shift()
            }
        }

        // if left list has items, add what is left to the results
        while (leftList.length !== 0) {
            sorted.push(leftList[0])
            leftList.shift()
        }

        // if right list has items, add what is left to the results
        while (rightList.length !== 0) {
            sorted.push(rightList[0])
            rightList.shift()
        }

        // merge the left and right list
        return sorted
    }


        function commaFormat(str) {
            var num = str + "";
            var formatedNum = "";

            for (var i = 0; i < num.length + 1; i++) {

                if (i==4 || i==7 || i==10) {
                    formatedNum = "," + formatedNum;
                }

                formatedNum = num.charAt(num.length - i) + formatedNum;
            }

            return formatedNum;


        }



        function buildRegions(orderMap) {

            var lastChr = "";

            var regions = [];

            for (i = 0; i < orderMap.length; i++) {

                var rec = orderMap[i];

                regionStart = rec.synStart;
                regionChr = rec.synChr;
                regionStop = rec.synStop;

                //boolean sameRegion = true;
                for (j = (i+1); j < orderMap.length; j++) {
                    if (regionChr == orderMap[j].synChr) {
                        regionStop= orderMap[j].synStop
                    }else {
                        i=(j-1);

                        var region = {};
                        region.start=regionStart;
                        region.stop = regionStop;
                        region.chr=regionChr;

                        regions[regions.length] = region;
                        break;
                    }
                }




            }

            return regions;

        }

        var colors = {};
        colors["1"] = "#bf1f1f";
        colors["2"] = "#e16e41";
        colors["3"] = "#bf7a1f";
    colors["4"] = "#e0c840";
    colors["5"] = "#a9bf1f";
    colors["6"] = "#9cdf41";
    colors["7"] = "#4dbf1f";
    colors["8"] = "#40e040";
    colors["9"] = "#1ebf4d";
    colors["10"] = "#40e09a";
    colors["11"] = "#20c0a8";
    colors["12"] = "#41c9e1";
    colors["13"] = "#1f7ac0";
    colors["14"] = "#406de0";
    colors["15"] = "#1f1fbf";
    colors["16"] = "#703de0";
    colors["17"] = "#791fbf";
    colors["18"] = "#c840e0";
    colors["19"] = "#bf1ea8";
    colors["20"] = "red";
    colors["21"] = "green";
    colors["22"] = "orange";
    colors["X"] = "#e03f9c";
    colors["Y"] = "#bf1f4d";


    function mapGenes() {


        for (i=0; i<genes.length; i++) {

            var y = topY + (genes[i].start * scale);
            var x = topX + 100;
            var barLen= x + 20;

            var geneLen = (genes[i].stop - genes[i].start) * scale;

            var text = document.createElementNS(svgns, 'text');
            text.setAttributeNS(null, 'x', topX);
            text.setAttributeNS(null, 'y', y );
            text.setAttributeNS(null, 'fill', "#2865A3");
            text.setAttributeNS(null, 'style', "font-size:10px;");
            text.innerHTML="<a target='_blank' href='https://rgd.mcw.edu/rgdweb/report/gene/main.html?id=" + genes[i].rgdId + "'>" + genes[i].symbol + "</a>";

            document.getElementById('genes').appendChild(text);


            var polygon = document.createElementNS(svgns, 'polygon');
            polygon.setAttributeNS(null, 'points', x + "," + y + " " + barLen + "," + y + " " + barLen + "," + (parseInt(y+geneLen)));
            polygon.setAttributeNS(null, 'style', 'fill:lime;stroke:purple;stroke-width:1;');
            document.getElementById('genes').appendChild(polygon);

        }
    }


    function mapNextBlocks(lst) {

            yStart=0;

        for (i = 0; i < lst.length; i++) {

            //if (i==3) break;

            var rec = lst[i];

            var msg = "Species: " + rec.fromMap + "Chr" + rec.chr + ": " + commaFormat(rec.start) + " .. " + commaFormat(rec.stop) + " Mapped to Species: " + rec.toMap + " chr" + rec.synChr + ": " + commaFormat(rec.synStart) + " .. " + commaFormat(rec.synStop);

            var title = document.createElementNS(svgns, 'title');
            title.innerHTML = "Species: " + rec.fromMap + " Chr" + rec.chr + ":" + rec.start + ".." + rec.stop + " Mapped to Species: " + rec.toMap + " chr" + rec.synChr + ":" + rec.synStart + ".." + rec.synStop;

            var yPx =  parseInt(yStart + topY);
            var yHeight = parseInt(((rec.synStop - rec.synStart) * scale));
            if (yHeight==0) {
                yHeight=1;
            }

           // alert("ystart = " + yStart + " yHeight = " + yHeight);



            yStart = yStart + yHeight + 2;

           // alert("ystart = " + yStart + " yPx = " + yPx + " - yHeight = " + yHeight);


          //  alert("yStart = " + yStart);

            var ortho = document.createElementNS(svgns, 'rect');
            ortho.setAttributeNS(null, 'x', 470 + topX  );
            //ortho.setAttributeNS(null, 'y', yPx);
            ortho.setAttributeNS(null, 'y', yPx);
            ortho.setAttributeNS(null, 'height', yHeight);
            ortho.setAttributeNS(null, 'width', 25);
            ortho.setAttributeNS(null, 'fill', colors[rec.synChr]);
            ortho.setAttributeNS(null, 'style', "border:1px solid black;");
            ortho.appendChild(title);

            document.getElementById('genes').appendChild(ortho);

            if (yHeight > 20) {
                var text = document.createElementNS(svgns, 'text');
                text.setAttributeNS(null, 'x', 470 + topX + 3);
                text.setAttributeNS(null, 'y', yPx + 20);
                text.setAttributeNS(null, 'fill', "white");
                text.setAttributeNS(null, 'style', "font-size:16px;");
                text.innerHTML=rec.synChr;
                document.getElementById('genes').appendChild(text);

                text = document.createElementNS(svgns, 'text');
                text.setAttributeNS(null, 'x', 470 + topX + 30);
                text.setAttributeNS(null, 'y', yPx + 10);
                text.setAttributeNS(null, 'fill', "black");
                text.setAttributeNS(null, 'style', "font-size:13px;");
                text.innerHTML=commaFormat(rec.synStart);
                document.getElementById('genes').appendChild(text);

                text = document.createElementNS(svgns, 'text');
                text.setAttributeNS(null, 'x', 470 + topX + 30);
                text.setAttributeNS(null, 'y', yPx -2 + yHeight);
                text.setAttributeNS(null, 'fill', "black");
                text.setAttributeNS(null, 'style', "font-size:13px;");
                text.innerHTML=commaFormat(rec.synStop);
                document.getElementById('genes').appendChild(text);



            }
/*
            rect.setAttributeNS(null, 'x', 170 + topX);
            rect.setAttributeNS(null, 'y', parseInt((rec.start * scale)) + topY);
            rect.setAttributeNS(null, 'height', parseInt(((rec.stop - rec.start) * scale)));
*/

            var topLine = document.createElementNS(svgns, 'line');
            topLine.setAttributeNS(null,'x1',170 + topX + 25);
            topLine.setAttributeNS(null,'y1',parseInt((rec.start * scale)) + topY);
            topLine.setAttributeNS(null,'x2',470 + topX);
            topLine.setAttributeNS(null,'y2',yPx);
            topLine.setAttributeNS(null,'style',"stroke:rgb(255,0,0);stroke-width:1");

            document.getElementById('genes').appendChild(topLine);

            /*
            var bottomLine = document.createElementNS(svgns, 'line');
            bottomLine.setAttributeNS(null,'x1',0);
            bottomLine.setAttributeNS(null,'y1',100);
            bottomLine.setAttributeNS(null,'x2',300);
            bottomLine.setAttributeNS(null,'y2',300);
            bottomLine.setAttributeNS(null,'style',"stroke:rgb(255,0,0);stroke-width:2");

            document.getElementById('genes').appendChild(bottomLine);
            */

            /*
                    <svg height="210" width="500">
                                <line x1="0" y1="0" x2="200" y2="200" style="stroke:rgb(255,0,0);stroke-width:2" />
                        </svg>
              */

         //   alert(document.getElementById('genes').innerHTML);

            /*
            var text = document.createElementNS(svgns, 'text');
            text.setAttributeNS(null, 'x', 370 + topX);
            text.setAttributeNS(null, 'y', parseInt((yVal * scale)) + topY + 15);
            text.setAttributeNS(null, 'fill', "black");
            text.setAttributeNS(null, 'style', "font-size:16px;");
            text.innerHTML=rec.synChr + " " + msg;
            document.getElementById('genes').appendChild(text);
            */
            //yStart = yPx + yHeight + 10;
        }
    }


    buildChr();
    buildScale();
    mapSyntenyBlocks();
    mapRootGenes();
    var sortedChr = orderBySynChr(synMap);
    var orderedMap = orderSyn(sortedChr);

   // var regions = buildRegions(orderedMap);

    //oout(regions);

    //drawRegions




    mapNextBlocks(orderedMap);


</script>


<script>
    //plot genes
/*
    for (i=0; i<genes.length; i++) {

        var y = genes[i].start * scale;

        var geneLen = (genes[i].stop - genes[i].start) * scale;

        var text = document.createElementNS(svgns, 'text');
        text.setAttributeNS(null, 'x', 0);
        text.setAttributeNS(null, 'y', y);
        text.setAttributeNS(null, 'fill', "#2865A3");
        text.setAttributeNS(null, 'style', "font-size:10px;");
        text.innerHTML=genes[i].symbol;

        var polygon = document.createElementNS(svgns, 'polygon');
        polygon.setAttributeNS(null, 'points',"100," + y + " 120," + y + " 120," + (parseInt(y+geneLen)));
        polygon.setAttributeNS(null, 'style', 'fill:lime;stroke:purple;stroke-width:1;');


        document.getElementById('genes').appendChild(text);
        document.getElementById('genes').appendChild(polygon);

    }
*/

</script>


<script>

    var transformMatrix = [1, 0, 0, 1, 0, 0];

    var svg = document.querySelector('svg');
    var box = svg.getAttribute('viewBox');

    var viewbox = box.split(" ");
    var centerX = parseFloat(viewbox[2]) / 2;
    var centerY = parseFloat(viewbox[3]) / 2;
    var matrixGroup = svg.getElementById("genes");

    function zoom(zoomScale) {
       // alert(zoomScale);
        return true;
        for (var i = 0; i < 4; i++) {
            transformMatrix[i] *= zoomScale;
        }
        transformMatrix[4] += (1 - zoomScale) * centerX;
        transformMatrix[5] += (1 - zoomScale) * centerY;

        var newMatrix = "matrix(" +  transformMatrix.join(' ') + ")";
        matrixGroup.setAttributeNS(null, "transform", newMatrix);
    }

    function pan(dx, dy) {
        transformMatrix[4] += dx;
        return true;
        transformMatrix[5] += dy;

        var newMatrix = "matrix(" +  transformMatrix.join(' ') + ")";
        matrixGroup.setAttributeNS(null, "transform", newMatrix);
    }

    function hey() {
        alert("yo");
    }


    document.body.addEventListener('wheel',function(event){
        mouseController.wheel(event);
        alert("hello");
        return false;
    }, false);
</script>

