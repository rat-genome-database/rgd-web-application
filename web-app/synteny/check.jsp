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


<div id="app">
    <div style="background-color:red;" v-on:click='testIt()'>lakjsdfljasd</div>

    <p>{{ message }}</p>
    <input v-model="message">
</div>







<a href="javascript:zoom(.5)">click</a>



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

    var chrLen = 112626471;
    var svgns = "http://www.w3.org/2000/svg";
    var scale=<%=zoom%>;
    var step = 1000000;
    var topX = 20;
    var topY=30;



    function plot() {


    }


    function plotGenes(rec,yPx, yHeight, xPx) {
        console.log(yHeight);


        console.log("red = " + JSON.stringify(rec));

        axios
                .get("https://dev.rgd.mcw.edu/rgdws/genes/region/" + rec.synChr + "/" + rec.synStart + "/" + rec.synStop + "/" + rec.toMap)
                .then(function (response) {
                    for (var key in response.data) {
                        //alert(response.data[key].key);
                    }

                   //console.log(JSON.stringify(response["data"]))

                    var data = response["data"];

                    var synStart = rec.synStart;
                    var synStop = rec.synStop;


                    var yStart = yPx
                    var yStop = yPx + yHeight;

                    var visibleLen=parseInt(yHeight);
                    var bpRegionLen=rec.synStop-rec.synStart;

                    console.log("visible Len = " + visibleLen);
                    console.log("bpRegionLen = " + bpRegionLen);

                    var localScale = (parseInt(visibleLen) / parseInt(bpRegionLen));

                    var x = topX + 700;

                    for (var key in response["data"]) {
                            console.log(JSON.stringify(data[key]));

                       // for (i=0; i<genes.length; i++) {
                            //var topX=100;
                            //var y = topY + (data.start * scale);
                            var barLen= x + 20;

                        console.log("yStart = " + yStart);
                        console.log("yStop = " + yStop);
                        console.log("localScale = " + localScale);


                        var geneLen = (data[key].stop - data[key].start) * scale;

                            var y =100 + (data[key].start - synStart) * localScale;

                            console.log("data key start " + data[key].start);
                            console.log("synStart " + synStart);
                            console.log((data[key].start - synStart));
                           console.log(" times local scale " + (data[key].start - synStart) * localScale);

                            console.log("local scale " + localScale);
                            var text = document.createElementNS(svgns, 'text');
                            text.setAttributeNS(null, 'x', xPx);
                            text.setAttributeNS(null, 'y', yPx + ((100 + (data[key].start - synStart)) * localScale) );
                            text.setAttributeNS(null, 'fill', "#2865A3");
                            text.setAttributeNS(null, 'style', "font-size:10px;");
                            text.innerHTML="<a target='_blank' href='https://rgd.mcw.edu/rgdweb/report/gene/main.html?id=" + data[key].rgdId + "'>" + data[key].symbol + "</a>";

                            document.getElementById('genes').appendChild(text);

                    }

                })
                .catch(function (error) {
                    console.log(error)
                    v.errored = true
                })
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

            xPx = 470 + topX

            yStart = yStart + yHeight + 2;


            var ortho = document.createElementNS(svgns, 'rect');
            ortho.setAttributeNS(null, 'x',  xPx );
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


                plotGenes(rec, yPx, yHeight, xPx-70);




            }

            var topLine = document.createElementNS(svgns, 'line');
            topLine.setAttributeNS(null,'x1',170 + topX + 25);
            topLine.setAttributeNS(null,'y1',parseInt((rec.start * scale)) + topY);
            topLine.setAttributeNS(null,'x2',470 + topX);
            topLine.setAttributeNS(null,'y2',yPx);
            topLine.setAttributeNS(null,'style',"stroke:rgb(255,0,0);stroke-width:1");

            document.getElementById('genes').appendChild(topLine);

        }
    }


    //buildScale();
    mapSyntenyBlocks();
    //mapRootGenes();
    //var sortedChr = orderBySynChr(synMap);
    //var orderedMap = orderSyn(sortedChr);
    //mapNextBlocks(orderedMap);


</script>


<script>

    var v = new Vue({
        el: '#app',
        data: {
            message: 'Hello Vue.js!',
            chromosomeLen: 0,
            svgns: "http://www.w3.org/2000/svg",
            scale: <%=zoom%>,
            step: 1000000,
            topX : 20,
            topY: 30,
            chromosomeWidth: 25
        },
        methods: {
            init: function () {

                this.getChromosomeLength();
                this.getSyntenyBlocks();

            },
            getChromosomeLength:function() {
                axios
                        .get("https://dev.rgd.mcw.edu/rgdws/maps/chr/10/360")
                        .then(function (response) {
                            v.chromosomeLen=response['data'].seqLength;
                        })
                        .catch(function (error) {
                            alert(error);
                            console.log(error)
                            v.errored = true
                        })
            },
            getSyntenyBlocks: function () {
                axios
                .get("https://dev.rgd.mcw.edu/rgdws/orthology/synteny/10/360/38")
                        .then(function (response) {
                            alert(JSON.stringify(response));
                        })
                        .catch(function (error) {
                            alert(error);
                            console.log(error)
                            v.errored = true
                        })
            },
            layoutBackbone: function () {
                var chrBacking = document.createElementNS(svgns, 'rect');
                chrBacking.setAttributeNS(null,"fill","#E0E0E0");
                chrBacking.setAttributeNS(null,"x",170 + this.topX);
                chrBacking.setAttributeNS(null,"y",this.topY);
                chrBacking.setAttributeNS(null,"width",this.chromosomeWidth);
                chrBacking.setAttributeNS(null,"height",parseInt(this.chromosomeLen * this.scale));
                document.getElementById('genes').appendChild(chrBacking);

            },
            getOrthology: function() {

            }
        }
    })

    v.init();
</script>

