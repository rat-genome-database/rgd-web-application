<%@ page import="java.util.LinkedHashMap" %>


<%
    String pageTitle = "Rat Genome Database";
    String headContent = "";
    String pageDescription = "The Rat Genome Database houses genomic, genetic, functional, physiological, pathway and disease data for the laboratory rat as well as comparative data for mouse and human.  The site also hosts data mining and analysis tools for rat genomics and physiology";
%>
<%@ include file="/common/headerarea.jsp"%>

<div style="border:1px solid black; font-size:18px;padding:20px;margin-bottom:20px;">
RGD is transitioning to JBrowse 2.   JBrowse 1 will be retired in late 2024.
</div>

<table align="center">
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
</table>


<table align="center" border="0">
    <tr>
        <td align="center"><a style="font-size:30px;" href="/jbrowse2/">Enter JBrowse 2</a></td>
        <td></td>
        <td align="center"><a style="font-size:30px" href="/jbrowse/">Enter JBrowse 1</a></td>
    </tr>
    <tr>
        <td valign="top">
            <div style="border:1px solid lightgrey; padding:10px;margin-top:10px;" ><h2>Available JBrowse 2 Datasets</h2>
                <ul>
                    <li>Rat</li>
                <ul>
                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=mRatBN7.2">mRatBN7.2</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=Rnor_6.0">Rnor_6.0</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=Rnor_5.0">Rnor_5.0</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=RGSC_v3.4">RGSC_v3.4</a></li>
                                <li><a href="/jbrowse2/?loc=Chr1:1..8,689,541&assembly=UTH_Rnor_SHR_Utx">UTH_Rnor_SHR_Utx</a></li>
                                <li><a href="/jbrowse2/?loc=Chr1:1..8,689,541&assembly=UTH_Rnor_SHRSP_BbbUtx_1.0">UTH_Rnor_SHRSP_BbbUtx_1.0</a></li>
                                <li><a href="/jbrowse2/?loc=Chr1:1..8,689,541&assembly=UTH_Rnor_WKY_Bbb_1.0">UTH_Rnor_WKY_Bbb_1.0</a></li>
                </ul>
                    <li>Mouse</li>
                    <ul>
                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=GRCm39">GRCm39</a></li>
                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=GRCm38.p6">GRCm38.p6</a></li>
                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=MGSCv37">MGSCv37</a></li>
                    </ul>
                    <li>Human</li>
                    <ul>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=GRCh38.p14">GRCh38.p14</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=GRCh37.p13">GRCh37.p13</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=NCBI36">NCBI36</a></li>
                    </ul>
                    <li>Domestic Dog</li>
                    <ul>
                                <li><a href="/jbrowse2/?loc=Chr1:4,981,881..2,678,785&assembly=CanFam3.1">CanFam3.1</a></li>
                    </ul>
                    <li>Bonobo</li>
                    <ul>

                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=Mhudiblu_PPA_v0">Mhudiblu_PPA_v0</a></li>
                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=panpan1.1">panpan1.1</a></li>
                    </ul>

                    <li>Thirteen Lined Ground Squirell</li>
                    <ul>
                        <li><a href="/jbrowse2/?loc=NW_004936469:1..81,790,585&assembly=SpeTri2.0">SpeTri2.0</a></li>
                    </ul>
                    <li>Chinchilla</li>
                    <ul>
                        <li><a href="/jbrowse2/?loc=NW_004955402:1..81,790,585&assembly=ChiLan1.0">ChiLan1.0</a></li>
                    </ul>

                    <li>Pig</li>
                    <ul>

                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=Sscrofa11.1">Sscrofa11.1</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=Sscrofa10.2">Sscrofa10.2</a></li>
                    </ul>
                    <li>Green Monkey/Vervet</li>
                    <ul>

                    <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=Chlorocebus_sabeus1.1">Chlorocebus_sabeus 1.1</a></li>
                                <li><a href="/jbrowse2/?loc=NW_023666033:1..81,790,585&assembly=Vero_WHO_p1.0">Vero_WHO_p1.0</a></li>
                    </ul>
                    <li>Naked Mole-Rat</li>
                    <ul>
                                <li><a href="/jbrowse2/?loc=NW_004624730:1..78,885,850&assembly=HetGla_female_1.0">HetGla_female_1.0</a></li>
                    </ul></ul></div>
                                </td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td valign="top">
                        <div style="border:1px solid lightgrey; padding:10px;margin-top:10px;" ><h2>Available JBrowse 1 Datasets</h2>
                            <ul>
                                <li>Rat</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_rn7_2">mRatBN7.2</a></li>
                                <li><a href="/jbrowse/?data=data_rgd6">Rnor_6.0</a></li>
                                <li><a href="/jbrowse/?data=data_rgd5">Rnor_5.0</a></li>
                                <li><a href="/jbrowse/?data=data_rgd3_4">RGSC_v3.4</a></li>
                                <li><a href="/jbrowse/?data=data_uth_shr">UTH_Rnor_SHR_Utx</a></li>
                                <li><a href="/jbrowse/?data=data_uth_shrsp">UTH_Rnor_SHRSP_BbbUtx_1.0</a></li>
                                <li><a href="/jbrowse/?data=data_uth_wky">UTH_Rnor_WKY_Bbb_1.0</a></li>
                                </ul>
                                <li>Mouse</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_mm39">GRCm39</a></li>
                                <li><a href="/jbrowse/?data=data_mm38">GRCm38</a></li>
                                <li><a href="/jbrowse/?data=data_mm37">MGSCv37</a></li>
                                </ul>
                                <li>Human</li>
                                <ul>
                                    <li><a href="/jbrowse/?data=data_hg38">GRCh38</a></li>
                                    <li><a href="/jbrowse/?data=data_hg19">GRCh37</a></li>
                                    <li><a href="/jbrowse/?data=data_hg18">NCBI36</a></li>
                                </ul>
                                <li>Domestic Dog</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_dog3_1">CanFam3.1</a></li>
                                </ul>
                                <li>Bonobo</li>
                                <ul>
                                    <li><a href="/jbrowse/?data=data_bonobo2">Mhudiblu_PPA_v0</a></li>
                                    <li><a href="/jbrowse/?data=data_bonobo1_1">panpan1.1</a></li>
                                </ul>
                                <li>Thirteen Lined Ground Squirell</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_squirrel2_0">SpeTri2.0</a></li>
                                </ul>
                                <li>Chinchilla</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_cl1_0">ChiLan1.0</a></li>
                                </ul>
                                <li>Pig</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_pig11_1">Sscrofa11.1</a></li>
                                <li><a href="/jbrowse/?data=data_pig10_2">Sscrofa10.2</a></li>
                                </ul>
                                <li>Green Monkey/Vervet</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_chlSab2">Chlorocebus_sabeus 1.1</a></li>
                                    <li><a href="/jbrowse/?data=data_veroWho">Vero_WHO_p1.0</a></li>
                                </ul>
                                <li>Naked Mole Rat</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_hetGla2">HetGla_female_1.0</a></li>
                                </ul></ul></div>

        </td>
    </tr>
</table>



<%@ include file="/common/footerarea.jsp"%>



