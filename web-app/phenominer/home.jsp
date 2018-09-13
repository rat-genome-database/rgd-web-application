<%@ page import="edu.mcw.rgd.process.Utils" %>

<%

String pageTitle = "Phenominer";
String headContent = "";
String pageDescription = "";
%>

<%
    int species = 3;

    try {
        species = Integer.parseInt(request.getParameter("species"));
    }catch (Exception e) {

    }

%>


<%@ include file="/common/headerarea.jsp"%>

<script>
    function updateSpecies(species) {
        location.href = "/rgdweb/phenominer/home.jsp?species=" + species;
    }
</script>

                <table width="95%" cellspacing="1px" border="0">
                    <tr>

                        <td style = "color: #2865a3; font-size: 20px; font-weight:700;">PhenoMiner Database </td>

                        <td align="right" style="color:red; font-size: 20px; font-weight: 700;">&nbsp;</td>
                    </tr>
                </table>
                <br>
                <span style="font-size:18px">Select Species</span>
                <!--<span style="font-size:16px;">To begin, select a starting point</span> <br>-->
                    <select name="species" style="font-size:18px" onChange="updateSpecies(this.value)">
                        <option value="3" <% if (species==3) out.print("selected"); %> style="font-size:18px">Rat</option>
                        <option value="4" <% if (species==4) out.print("selected"); %> style="font-size:18px">Chinchilla</option>
                    </select>
                <br>
                <form>

                    <table border="0" cellpadding="2" cellspacing="6" align="center">
                        <tbody>
                        <tr>
                            <td align="left" width="300" valign="top" ><div style="border: 1px solid black;">

                                <% if (species==3) { %>

                                <table border="0"  width="100%" style="background-color: #d7e4bd">
                                    <tr>
                                        <td  style="font-size:24px; background-color: #d7e4bd; " valign="top"><div style="width:100%; border-bottom: 3px solid white">Rat Strains<br><span style="font-size:11px; ">Search for data related to one or more rat strains.</span></div></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">congenic strain, ACI, BN</span></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Select Strains" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=RS&species=<%=species%>'" /><br><br></td>
                                    </tr>
                                </table>
                                <% } else if (species==4) { %>
                                <table border="0"  width="100%" style="background-color: #d7e4bd">
                                    <tr>
                                        <td  style="font-size:24px; background-color: #d7e4bd; " valign="top"><div style="width:100%; border-bottom: 3px solid white">Chinchilla Sources<br><span style="font-size:11px; ">Search for data related to one or more chinchilla sources.</span></div></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">Bbcdw:Chin, Rrcjo:Chin</span></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Select Sources" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=CS&species=<%=species%>'" /><br><br></td>
                                    </tr>
                                </table>

                                <% } %>

                            </div></td>
                            <td align="left" width="300" valign="top" ><div style="border: 1px solid black;">
                                <table border="0"  width="100%" style="background-color: #b9cde5">
                                    <tr>
                                        <td  style="font-size:24px; background-color: #b9cde5; " valign="top"><div style="width:100%; border-bottom: 3px solid white">Experimental Conditions<br><span style="font-size:11px; ">Find data based on a list of a conditions.</span></div></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">diet, atmosphere composition, activity level</span></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Select Conditions" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=XCO&species=<%=species%>'" /><br><br></td>
                                    </tr>
                                </table>
                            </div></td>
                        </tr>
                        <tr>
                            <td align="left"  valign="top"><div style="border: 1px solid black;">
                                <table border="0"  width="100%" style="background-color: #ccc1da">
                                    <tr>
                                        <td  style="font-size:24px; background-color: #ccc1da; " valign="top"><div style="width:100%; border-bottom: 3px solid white">Clinical Measurements<br><span style="font-size:11px; ">Query the database by clinical measurements.</span></div></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">heart rate, blood cell count</span></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Select Clinical Measurements" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=CMO&species=<%=species%>'" /><br><br></td>
                                    </tr>
                                </table>
                            </div></td>
                            <td align="left"  valign="top"><div style="border: 1px solid black;">
                                <table border="0"  width="100%" style="background-color: #fcd5b5">
                                    <tr>
                                        <td  style="font-size:24px; background-color: #fcd5b5; " valign="top"><div style="width:100%; border-bottom: 3px solid white">Measurement Methods<br><span style="font-size:11px; ">Base your query on a list of Measurement methods.</span></div></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">fluid filled catheter, blood chemistry panel </span></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Select Methods" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=MMO'" /><br><br></td>
                                    </tr>
                                </table>
                            </div></td>
                        </tr>
                        </tbody>
                    </table>
                </form>
                <br>


                <span style="font-size:16px;font-weight:bold"> * If you would like to show your own data in PhenoMiner, please submit your data <a href="/wg/home/phenominer-data-upload"><span style="font-size:16px;font-weight:bold">here.</span></a></span> <br>

                <br>


<%@ include file="/common/footerarea.jsp"%>


