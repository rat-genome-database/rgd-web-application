



<%
    String pageTitle = "Disease Portals - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Welcome to the Disease Portals - Rat Genome Database";

%>

<%@ include file="/common/headerarea.jsp"%>

<style>
    .diseasePortalName {
        font-size:20px;
        color:#2865A3;
        text-decoration: none;
    }
    .topDiseaseIcon {
        cursor:pointer;
    }
    .bottomDiseaseIcon {
        cursor:pointer;
        padding-right:10px;
        padding-left:50px;
    }
</style>



<table>
    <tr>
        <td>

<br>
<table border="0" width="800">
    <tr>
        <td colspan="4">
            <div style="background-color:#EFEFEF;padding:10px;">
            <table>
                <tr>
                    <td><h1 style="font-size:36px">Disease Portals</h1></td>
                </tr>
                <tr>
                    <td style=" font-size:16px;">Welcome to the RGD Disease Portals.  These portals are designed to be entry points for disease researchers to access data and tools related to their area of interest.  <a href="/wg/help3/disease-portals/">Click Here</a> for help with the RGD Disease Portals.</td>
                </tr>
            </table>
            </div>

        </td>
    </tr>
    <tr><td>&nbsp;</td>
    </tr>
    <tr>
        <td width="75"><img src="/rgdweb/common/images/portals/1-65.png" border="0" class="topDiseaseIcon" onclick="location.href='/rgdweb/portal/home.jsp?p=1'"/></td>
        <td ><a href="/rgdweb/portal/home.jsp?p=1" class="diseasePortalName">Aging & Age Related Disease</a></td>
        <td width="75"><img src="/rgdweb/common/images/portals/16-65.png" border="0" onclick="location.href='/rgdweb/portal/home.jsp?p=16'" class="bottomDiseaseIcon"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=16" class="diseasePortalName">Behavioral & Substance Use Disorder</a></td>
    </tr>
    <tr>

        <td width="75"><img src="/rgdweb/common/images/portals/2-65.png" border="0" onclick="location.href='/rgdweb/portal/home.jsp?p=2'" class="topDiseaseIcon"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=2" class="diseasePortalName">Cancer & Neoplastic Disease</a></td>
        <td width="75"><img src="/rgdweb/common/images/portals/3-65.png" border="0" class="bottomDiseaseIcon" onclick="location.href='/rgdweb/portal/home.jsp?p=3'"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=3" class="diseasePortalName">Cardiovascular Disease  </a></td>
    </tr>
    <tr>

        <td width="75"><img src="/rgdweb/common/images/portals/14-65.png" border="0" onclick="location.href='/rgdweb/portal/home.jsp?p=14'" class="topDiseaseIcon"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=14" class="diseasePortalName">Coronavirus Disease</a></td>
        <td width="75"><img src="/rgdweb/common/images/portals/12-65.png" border="0" class="bottomDiseaseIcon" onclick="location.href='/rgdweb/portal/home.jsp?p=12'"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=12" class="diseasePortalName">Developmental Disease</a></td>
    </tr>
    <tr>
        <td width="75"><img src="/rgdweb/common/images/portals/4-65.png" border="0" onclick="location.href='/rgdweb/portal/home.jsp?p=4'" class="topDiseaseIcon"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=4" class="diseasePortalName">Diabetes</a></td>
        <td width="75"><img src="/rgdweb/common/images/portals/5-65.png" border="0" class="bottomDiseaseIcon" onclick="location.href='/rgdweb/portal/home.jsp?p=5'"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=5" class="diseasePortalName">Hematologic Disease</a></td>
    </tr>
    <tr>
        <td width="75"><img src="/rgdweb/common/images/portals/6-65.png" border="0" onclick="location.href='/rgdweb/portal/home.jsp?p=6'" class="topDiseaseIcon"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=6" class="diseasePortalName">Immune & Inflammatory Disease</a></td>
        <td width="75"><img src="/rgdweb/common/images/portals/15-65.png" border="0" class="bottomDiseaseIcon" onclick="location.href='/rgdweb/portal/home.jsp?p=15'"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=15" class="diseasePortalName">Infectious Disease</a>&nbsp;</td>
    </tr>
    <tr>
        <td width="75"><img src="/rgdweb/common/images/portals/13-65.png" border="0" onclick="location.href='/rgdweb/portal/home.jsp?p=13'" class="topDiseaseIcon"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=13" class="diseasePortalName">Liver Disease</a></td>
        <td width="75"><img src="/rgdweb/common/images/portals/7-65.png" border="0" class="bottomDiseaseIcon" onclick="location.href='/rgdweb/portal/home.jsp?p=7'"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=7" class="diseasePortalName">Neurological Disease</a></td>
    </tr>
    <tr>
        <td width="75"><img src="/rgdweb/common/images/portals/8-65.png" border="0" onclick="location.href='/rgdweb/portal/home.jsp?p=8'" class="topDiseaseIcon"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=8" class="diseasePortalName">Obesity & Metabolic Syndrome</a></td>
        <td width="75"><img src="/rgdweb/common/images/portals/9-65.png" border="0" class="bottomDiseaseIcon" onclick="location.href='/rgdweb/portal/home.jsp?p=9'"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=9" class="diseasePortalName">Renal Disease</a></td>
    </tr>
    <tr>
        <td width="75"><img src="/rgdweb/common/images/portals/10-65.png" border="0" onclick="location.href='/rgdweb/portal/home.jsp?p=10'" class="topDiseaseIcon"/></td>
        <td class="diseasePortalName"><a href="/rgdweb/portal/home.jsp?p=10" class="diseasePortalName">Respiratory Disease</a></td>
        <td width="75"><img src="/rgdweb/common/images/portals/11-65.png" border="0" class="bottomDiseaseIcon" onclick="location.href='/rgdweb/portal/home.jsp?p=11'"/></td>
        <td class="diseasePortalName" ><a href="/rgdweb/portal/home.jsp?p=11" class="diseasePortalName">Sensory Organ Disease</a></td>
    </tr>
</table>

        </td>
        <td>&nbsp;&nbsp;&nbsp;</td>
        <td width="300" valign="top">
            <br><br><br><br><br>
            <table style="border:1px solid #2865A3;">
                <tr>
                    <td style="background-color: #2865A3;color:white;padding:5px;font-size:16px;">About the RGD Disease Portals</td>
                </tr>
                <tr>
                    <td><div style="padding:5px;">RGD has numerous Disease Portals, where relationships between diseases and genes, QTLs and strains can be explored in human, rat, mouse and in the other five species at RGD. The portals contain data sections for eight other ontologies related to the portal disease category, as well as links to visualization / analysis tools and additional information.</div></td>
                </tr>
            </table>
            <br>
            <table  style="border:1px solid #2865A3;" cellpadding="5">
                <tr>
                    <td style="background-color: #2865A3;color:white;padding:5px;font-size:16px;">Download Data</td>
                </tr>
                <tr>
                    <td>Disease Ontology (RDO) Annotations - RDO - Gene (8 Species), QTL (Rat & Human) and Rat Strain
                        <li style="margin-left:10px;margin-top:5px;"><a href="https://download.rgd.mcw.edu/ontology/annotated_rgd_objects_by_ontology">Ontology Term IDs Only</a></li>
                        <li style="margin-left:10px;margin-top:5px;"><a href="https://download.rgd.mcw.edu/pub/ontology/annotated_rgd_objects_by_ontology/with_terms/">Ontology Term IDs and Text</a></li>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<%@ include file="/common/footerarea.jsp"%>