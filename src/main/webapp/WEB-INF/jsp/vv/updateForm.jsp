<%@ page import="edu.mcw.rgd.process.Utils" %>

<style>
     .updateForm {
         font-size: 13px;
         font-weight:700;
         color:#2865A3;
         background-color:#EEEEEE;

     }
     .updateForm input{
         font-size:13px;
         margin-right:10px;
     }
     .updateForm td{
         font-size:13px;
         font-weight:700;
         color:#2865A3;
     }

     #zIn, #zOut {
         cursor: pointer;
         border-radius: 45%;
         padding: 8px; /* Space around the image inside the circle */
         transition: background-color 0.3s; /* Smooth transition for background color */
     }

     /* Styles when hovering over the images */
     #zIn:hover, #zOut:hover {
         background-color: lightgrey; /* Light grey background on hover */
     }

</style>
<%
    int regionSize = (int)(vsb.getStopPosition() - vsb.getStartPosition() +1);
%>
<form>
<%
    String chr = vsb.getChromosome();
    if (chr == null) {
        chr = "";
    }

    String start = "";
    String stop = "";

    if (vsb.getStartPosition() > -1) {
        start =  FormUtility.formatThousands(vsb.getStartPosition());
    }

    if (vsb.getStopPosition() > -1) {
        stop =  FormUtility.formatThousands(vsb.getStopPosition());
    }
%>

<table width="100%" class="updateForm" >
    <tr>
        <td>
            <table border=0 align="center">
            <tr>
<%--                <td align="center">Chromosome</td>--%>
<%--                <td><input type="text" name="chr" size=2 id="chr" value="<%=chr%>"/></td>--%>
                <td><input type="hidden" name="chr" size=2 id="chr" value="<%=chr%>"/></td>
<%--                <td align="center">Start Position</td>--%>
<%--                <td><input type="text" name="start" id="start" size="15" value="<%=start%>"/></td>--%>
                <td><input type="hidden" name="start" id="start" size="15" value="<%=start%>"/></td>
<%--                <td align="center">Stop Position</td>--%>
<%--                <td><input type="text" name="stop" id="stop"  size="15" value="<%=stop%>"/></td>--%>
                <td><input type="hidden" name="stop" id="stop"  size="15" value="<%=stop%>"/></td>
                <td>Search Region</td>
                <td><input type="text" name="search" size="50" id="search" value="Chr<%=chr%>:<%=start%>..<%=stop%>"></td>
                <td><input type="button" value="Update" onClick="updatePage()"/></td>
                <td><img id="zOut" src="/rgdweb/common/images/zoom/zoom-out.png"  alt="-"></td>
                <td>&nbsp;&nbsp;</td>
                <td><img id="zIn" src="/rgdweb/common/images/zoom/zoom-in.png"  alt="+"></td>
            </tr>
            </table>
        </td>
        <td >
            <% if (regionSize > 0) { %>
            <table border=0 align="center">
            <tr>
                <td style="font-weight:700;  color:#2865A3;" align="center">Region Size:</td>
                <td align="center" ><%=FormUtility.formatThousands(regionSize)%> (bp)</td>
                <td>&nbsp;</td>
                <td style="font-weight:700;  color:#2865A3;" align="center">Positions:</td>
                <td align="center" ><%=positionCount%></td>
            </tr>
            </table>
            <% } %>
        </td>
    </tr>
</table>
</form>
<script>

    let isManualEdit = true;  // This flag determines the source of the update.
    let isUpdate=false;
    function updatePage() {

        if (validateSearchInput()) {
            //update chr,start pos, stop pos values
            if (isManualEdit) {
                update();  // Only call update if the change is manual
            }
            var queryString = "?<%=request.getQueryString()%>";
            queryString = addParam("chr", document.getElementById("chr").value, queryString);
            queryString = addParam("start", document.getElementById("start").value, queryString);
            queryString = addParam("stop", document.getElementById("stop").value, queryString);
            queryString = addParam("geneList", "", queryString);
            queryString = addParam("geneStart", "", queryString);
            queryString = addParam("geneStop", "", queryString);

            location.href = "variants.html" + queryString;
        }
    }
    function update(){
        let searchVal = document.getElementById("search").value;

        //update chr value
        let colIndex = searchVal.indexOf(":");
        let chrVal = searchVal.substring(3,colIndex);
        document.getElementById("chr").value=chrVal;

        //update start position value
        let startPosIndex = searchVal.indexOf("..");
        let startVal = searchVal.substring(colIndex+1,startPosIndex);
        document.getElementById("start").value = startVal;

        //update stop position value
        let stopVal = searchVal.substring(startPosIndex+2);
        document.getElementById("stop").value = stopVal;
    }

    // Function to handle the zoom-in operation
    function zoomIn() {
        isManualEdit = false;
        let originalStart = parseInt(document.getElementById("start").value.replace(/,/g, ''), 10);
        let originalStop = parseInt(document.getElementById("stop").value.replace(/,/g, ''), 10);

        let newStart = originalStart + 100000;  // Potential new start value
        let newStop = originalStop - 100000;    // Potential new stop value

        if (newStop - newStart > 1000) {
            document.getElementById("start").value = newStart;
            document.getElementById("stop").value = newStop;
            updatePage();
        } else {
            console.log("Start: " + originalStart + ", Stop: " + originalStop);
            alert("Maximum zoom limit reached");
        }
    }


    // Function to handle the zoom-out operation
    function zoomOut() {
        isManualEdit = false;
        let originalStart = parseInt(document.getElementById("start").value.replace(/,/g, ''), 10);
        let originalStop = parseInt(document.getElementById("stop").value.replace(/,/g, ''), 10);

        let newStart = originalStart - 100000;  // Potential new start value
        let newStop = originalStop + 100000;    // Potential new stop value

        if (newStart > 0) {
            document.getElementById("start").value = newStart;
            document.getElementById("stop").value = newStop;
            updatePage();
        } else {
            console.log("Start: " + originalStart + ", Stop: " + originalStop);
            alert("Minimum zoom limit reached or invalid range");
        }
    }


    document.getElementById("search").addEventListener('input', function() {
        isManualEdit = true;  // Set flag true on manual input.
    });

    function validateSearchInput() {
        let input = document.getElementById("search").value;
        // Regular expression to match the pattern "Chr#:startpos..stoppos"
        let pattern = /^Chr([A-Za-z0-9]+):([\d,]+)\.\.([\d,]+)$/;
        if (!pattern.test(input)) {
            alert("Please enter a valid format: 'Chr#:startpos..stoppos'");
        }
        else{
            isUpdate = true;
        }
        return isUpdate;
    }

    document.getElementById("zIn").addEventListener("click", zoomIn);
    document.getElementById("zOut").addEventListener("click", zoomOut);
</script>



