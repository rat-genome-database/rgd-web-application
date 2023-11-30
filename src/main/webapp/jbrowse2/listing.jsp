<%@ page import="java.util.LinkedHashMap" %>


<%
    String pageTitle = "Rat Genome Database";
    String headContent = "";
    String pageDescription = "The Rat Genome Database houses genomic, genetic, functional, physiological, pathway and disease data for the laboratory rat as well as comparative data for mouse and human.  The site also hosts data mining and analysis tools for rat genomics and physiology";
%>
<%@ include file="/common/headerarea.jsp"%>

<div style="border:1px solid black; font-size:18px;padding:20px;margin-bottom:20px;">
RGD is transitioning to JBrowse 2.   An archival version of JBrowse 1 will be available until January 1st 2025.
</div>

<table align="center">
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
</table>


<table align="center" border="0">
    <tr>
        <td align="center"><input  style="font-size:30px" type="button" onclick="location.href='/jbrowse2/'" value="Enter JBrowse 2 (Beta)"/></td>
        <td></td>
        <td align="center"><input style="font-size:30px" onclick="location.href='/jbrowse/'" type="button" value="Enter JBrowse 1"/></td>
    </tr>
    <tr>
        <td valign="top">
            <div style="order:1px dashed black; padding:5px;margin-top:10px;" ><h2>Available JBrowse 2 Datasets</h2>
                <ul>
                    <li>Rat</li>
                <ul>
                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=rn7.2">mRatBN7.2</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=rn6">Rnor_6.0</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=rn5">Rnor_5.0</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=rn3.4">RGSC_v3.4</a></li>
                                <li><a href="/jbrowse2/?loc=Chr1:1..8,689,541&assembly=UTH_Rnor_SHR_Utx">UTH_Rnor_SHR_Utx</a></li>
                                <li><a href="/jbrowse2/?loc=Chr1:1..8,689,541&assembly=UTH_Rnor_SHRSP_BbbUtx_1.0">UTH_Rnor_SHRSP_BbbUtx_1.0</a></li>
                                <li><a href="/jbrowse2/?loc=Chr1:1..8,689,541&assembly=UTH_Rnor_WKY_Bbb_1.0">UTH_Rnor_WKY_Bbb_1.0</a></li>
                </ul>
                    <li>Mouse</li>
                    <ul>
                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=mm39">GRCm39</a></li>
                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=mm38">GRCm38</a></li>
                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=mm37">GRCm37</a></li>
                    </ul>
                    <li>Human</li>
                    <ul>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=hg38">hg38</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=hg19">hg19</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=hg18">hg18</a></li>
                    </ul>
                    <li>Domestic Dog</li>
                    <ul>
                                <li><a href="/jbrowse2/?loc=Chr1:4,981,881..2,678,785&assembly=canFam3">canFam3.1</a></li>
                    </ul>
                    <li>Bonobo</li>
                    <ul>

                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=panPan3">panPan3</a></li>
                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=panPan2">panPan2</a></li>
                    </ul>

                    <li>Pig</li>
                    <ul>

                        <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=susScr11">susScr11</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=susScr3">susScr3</a></li>
                    </ul>
                    <li>Green Monkey/Vervet</li>
                    <ul>

                    <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=chlSab2">chlSab2</a></li>
                                <li><a href="/jbrowse2/?loc=NW_023666033:1..81,790,585&assembly=veroWho">veroWho</a></li>
                    </ul>
                    <li>Naked Mole-Rat</li>
                    <ul>
                                <li><a href="/jbrowse2/?loc=NW_004624730:1..78,885,850&assembly=hetGla2">hetGla2</a></li>
                    </ul></ul></div>
                                </td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td valign="top">
                        <div style="order:1px dashed black; padding:5px;margin-top:10px;" ><h2>Available JBrowse 1 Datasets</h2>
                            <ul>
                                <li>Rat</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_rn7_2">RGD mRatBN7.2</a></li>
                                <li><a href="/jbrowse/?data=data_uth_shr">UTH_Rnor_SHR_Utx</a></li>
                                <li><a href="/jbrowse/?data=data_uth_shrsp">UTH_Rnor_SHRSP_BbbUtx_1.0</a></li>
                                <li><a href="/jbrowse/?data=data_uth_wky">UTH_Rnor_WKY_Bbb_1.0</a></li>
                                <li><a href="/jbrowse/?data=data_rgd6">Rat Genome Database v6</a></li>
                                <li><a href="/jbrowse/?data=data_rgd5">Rat Genome Database v5</a></li>
                                <li><a href="/jbrowse/?data=data_rgd3_4">Rat Genome Database v3.4</a></li>
                                </ul>
                                <li>Mouse</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_mm39">RGD Mouse GRCm39 (mm39)</a></li>
                                <li><a href="/jbrowse/?data=data_mm38">RGD Mouse v38 (mm10)</a></li>
                                <li><a href="/jbrowse/?data=data_mm37">RGD Mouse v37</a></li>
                                </ul>
                                <li>Human</li>
                                <ul>

                                <li><a href="/jbrowse/?data=data_hg18">RGD Human v36.3 (hg18)</a></li>
                                <li><a href="/jbrowse/?data=data_hg19">RGD Human v37 (hg19)</a></li>
                                <li><a href="/jbrowse/?data=data_hg38">RGD Human v38.7 (hg38)</a></li>
                                </ul>
                                <li>Domestic Dog</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_dog3_1">RGD Dog CanFam3.1</a></li>
                                </ul>
                                <li>Bonobo</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_bonobo1_1">RGD Bonobo panpan1.1</a></li>
                                    <li><a href="/jbrowse/?data=data_bonobo2">RGD Bonobo Mhudiblu_PPA_v0</a></li>
                                </ul>
                                <li>Thirteen Lined Ground Squirell</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_squirrel2_0">RGD Squirrel SpeTri2.0</a></li>
                                </ul>
                                <li>Chinchilla</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_cl1_0">RGD Chinchilla ChiLan1.0</a></li>
                                </ul>
                                <li>Pig</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_pig11_1">RGD Pig Sscrofa11.1</a></li>
                                <li><a href="/jbrowse/?data=data_pig10_2">RGD Pig Sscrofa10.2</a></li>
                                </ul>
                                <li>Green Monkey/Vervet</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_chlSab2">RGD Green Monkey 1.1 (chlSab2)</a></li>
                                    <li><a href="/jbrowse/?data=data_veroWho">RGD Green Monkey (Vero_WHO_p1.0)</a></li>
                                </ul>
                                <li>Naked Mole Rat</li>
                                <ul>
                                <li><a href="/jbrowse/?data=data_hetGla2">RGD Naked Mole Rat (HetGla_female_1.0)</a></li>
                                </ul></ul></div>

        </td>
    </tr>
</table>



<%@ include file="/common/footerarea.jsp"%>



