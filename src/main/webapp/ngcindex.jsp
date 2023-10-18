<%
    String pageDescription = "Chinchilla Lanigera - Home Page";
    String pageTitle = "Home Page";
    String headContent = "";
%>
<%@include file="common/ngcheaderarea.jsp"%>
<center><h1>Welcome to the Chinchilla Research Resource Database<br>A model organism database for <span style="font-style:italic;">Chinchilla lanigera</span></h1></center>

<% int inc = 210;
    int topInc=75;
    int topBase=25;
    int wid=200;
%>


<div style="position:relative;height:300px;">

<table align="center" border="0" cellpadding="2">
    <tr >
        <td valign="top">
            <table border="0"  width="<%=wid%>" height="150" style=" background-color:#D4CFC3;border-radius: 25px;border: 1px solid black; ">
                <tr>
                    <td  style="font-size:22px; padding:5px; " valign="top"><div style="width:100%; border-bottom: 3px solid white">Genes</div></td>
                </tr>
                <tr>
                    <td valign="top" style="font-size:13px;">Search Genes and Human Orthologs</td>
                </tr>
                <tr>
                    <td valign="top" align="center"><br><input style="font-weight: 700;" type="button" value="Search Genes" onClick="location.href='/rgdweb/search/genes.html'" /><br><br></td>
                </tr>
            </table>

        </td>
        <td valign="top">
            <table border="0"  width="<%=wid%>" height="150" style=" background-color:#D4CFC3;border-radius: 25px;border: 1px solid black; ">
                <tr>
                    <td style="font-size:22px; padding:5px; " valign="top"><div style="width:100%; border-bottom: 3px solid white">Genome Browser<br><span style="font-size:11px; "></span></div></td>
                </tr>
                <tr>
                    <td valign="top" style="font-size:13px;">Visualize Chinchilla Genes, Transcripts and Expression</td>
                </tr>
                <tr>
                    <td valign="top" align="center"><br><input style="font-weight: 700;" type="button" value="Browse Genome" onClick="location.href='/jbrowse/?data=data_cl1_0&tracks=GFF3_track'" /><br><br></td>
                </tr>
            </table>


        </td>
        <td valign="top">
            <table border="0"  width="<%=wid%>" height="150" style="background-color:#D4CFC3;border-radius: 25px;border: 1px solid black;  ">
                <tr>
                    <td  style="font-size:22px; padding:5px; " valign="top"><div style="width:100%; border-bottom: 3px solid white">Ontology&nbsp;Browser<br><span style="font-size:11px; "></span></div></td>
                </tr>
                <tr>
                    <td valign="top" style="font-size:13px; ">Search For Chinchilla Genes By Function</td>
                </tr>
                <tr>
                    <td valign="top" align="center"><br><input style="font-weight: 700;" type="button" value="Search Annotations" onClick="location.href='/rgdweb/ontology/search.html'" /><br><br></td>
                </tr>
            </table>


        </td>
        </tr>
        <tr>
        <td valign="top">

            <table border="0"  width="<%=wid%>" height="150" style="background-color:#D4CFC3;border-radius: 25px;border: 1px solid black;">
                <tr>
                    <td  style="font-size:22px; padding:5px; " valign="top"><div style="width:100%; border-bottom: 3px solid white">Gene Annotator<br></div></td>
                </tr>
                <tr>
                    <td valign="top" style="font-size:13px; ">Retrieve and Analyze Functional Data on Gene Set</td>
                </tr>
                <tr>
                    <td valign="top" align="center"><br><input style="font-weight: 700;" type="button" value="Go To GA Tool" onClick="location.href='/rgdweb/ga/start.jsp'" /><br><br></td>
                </tr>
            </table>




        </td>
        <td valign="top">
            <table border="0"  width="<%=wid%>" height="150" style="background-color:#D4CFC3;border-radius: 25px;border: 1px solid black;  ">
                <tr>
                    <td  style="font-size:22px; padding:5px; " valign="top"><div style="width:100%; border-bottom: 3px solid white">File Downloads<br><span style="font-size:11px; "></span></div></td>
                </tr>
                <tr>
                    <td valign="top" style="font-size:13px; ">Download Chinchilla Data from FTP Site</td>
                </tr>
                <tr>
                    <td valign="top" align="center"><br><input style="font-weight: 700;" type="button" value="View Files" onClick="location.href='ftp://ftp.rgd.mcw.edu/pub/chinchilla'" /><br><br></td>
                </tr>
            </table>


        </td>
    </tr>
</table>





    <!--
    <table border="0"  width="<%=wid%>" height="150" style="background-color:#D4CFC3;border-radius: 25px;border: 1px solid black; position:absolute; top:<%=topBase + topInc%>; left:<%=(inc *3) + 3%>;">
          <tr>
            <td  style="font-size:24px; padding:5px;  " valign="top"><div style="width:100%; border-bottom: 3px solid white">Phenominer<br><span style="font-size:11px; ">Query Experimental Data</span></div></td>
          </tr>
          <tr>
            <td valign="top" align="center"><br><input style="font-weight: 700;" type="button" value="Search Phenominer" onClick="location.href='/phenotypesChin'" /><br><br></td>
          </tr>
       </table>
    -->

</div>

<%@include file="common/ngcfooterarea.jsp"%>