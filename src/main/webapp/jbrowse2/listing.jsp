<%@ page import="java.util.LinkedHashMap" %>


<%
    String pageTitle = "Rat Genome Database";
    String headContent = "";
    String pageDescription = "The Rat Genome Database houses genomic, genetic, functional, physiological, pathway and disease data for the laboratory rat as well as comparative data for mouse and human.  The site also hosts data mining and analysis tools for rat genomics and physiology";
%>
<%@ include file="/common/headerarea.jsp"%>

<div style="border:1px solid black; font-size:18px;padding:20px;margin-bottom:20px;">
RGD is transitioning to JBrowse 2.   An archival version of JBrowse 1 will be available until March 31st 2024. <br><br> Data and tracks in JBrowse 1 will not be updated after January 1st 2024.
</div>

<table align="center" border="0">
    <tr>
        <td valign="top">
            <table style="margin:5px;">
                <tr>
                    <td align="center"><a href="/jbrowse2/" style="font-size:26px;">Enter JBrowse 2</a></td>
                </tr>
                <tr>
                    <td><a href="/jbrowse2/"><img style="border:2px solid grey;" src="/rgdweb/common/images/jbrowse2Screen.png"/></a></td>
                </tr>
                <tr>
                    <td align="center">
                       <!-- http://host/jbrowse2/?config=test_data/config.json&loc=chr1:6000-7000&assembly=hg19&tracks=gene_track,vcf_track-->
                       <table>
                           <tr>
                               <td>
                        <div  style="border:1px dashed black; padding:5px;margin-top:10px;"><h2>Available Datasets</h2>
                            <ul></ul>
                            <ul>
                                <li><a href="/jbrowse2/?loc=chr1:60000-70000&assembly=rn7.2&tracks=">mRatBN7.2 (Rat)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=rn6&tracks=">Rnor_6.0 (Rat)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=rn5&tracks=">Rnor_5.0 (Rat)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=rn3.4&tracks=">RGSC_v3.4 (Rat)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=UTH_Rnor_SHR_Utx&tracks=">UTH_Rnor_SHR_Utx (Rat)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=UTH_Rnor_SHRSP_BbbUtx_1.0&tracks=">UTH_Rnor_SHRSP_BbbUtx_1.0 (Rat)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=UTH_Rnor_WKY_Bbb_1.0&tracks=">UTH_Rnor_WKY_Bbb_1.0 (Rat)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=hg38&tracks=">hg38 (Human)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=hg19&tracks=">hg19 (Human)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=hg18&tracks=">hg18 (Human)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=mm39&tracks=">GRCm39 (Mouse)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=mm38&tracks=">GRCm38 (Mouse)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=mm37&tracks=">GRCm37 (Mouse)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=canFam3.1&tracks=">canFam3.1 (Domestic Dog)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=susScr11&tracks=">susScr11 (Pig)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=susScr3&tracks=">susScr3 (Pig)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=chlSab2&tracks=">chlSab2 (Green Monkey/Vervet)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=veroWho&tracks=">veroWho (Green Monkey/Vervet)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=panPan3&tracks=">panPan3 (Bonobo)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=panPan2&tracks=">panPan2 (Bonobo)</a></li>
                                <li><a href="/jbrowse2/?loc=chr1:6000000-7000000&assembly=hetGla2&tracks=">hetGla2 (Naked Mole-Rat)</a></li>

                            </ul></div>
                               </td>
                           </tr>
                       </table>

                    </td>
                </tr>
            </table>
        </td>
        <td>&nbsp;&nbsp;&nbsp;</td>
        <td valign="top">
            <table style="margin:5px;">
                <tr>
                    <td align="center"><a href="/jbrowse/" style="font-size:26px;">Enter JBrowse 1</a></td>
                </tr>
                <tr>
                    <td><a href="/jbrowse/"><img style="border:2px solid grey;" src="/rgdweb/common/images/jbrowse1Screen.png"/></a></td>
                </tr>
                <tr>
                    <td>
                        <table align="center">
                            <tr>
                                <td >


                        <div style="border:1px dashed black; padding:5px;margin-top:10px;" ><h2>Available Datasets</h2>
                            <ul></ul>
                            <ul>
                                <li><a href="/jbrowse/?data=data_rn7_2">RGD mRatBN7.2</a></li>
                                <li><a href="/jbrowse/?data=data_rn7y">RGD mRatBN7.2 SRY</a></li>
                                <li><a href="/jbrowse/?data=data_rn7yp">rnBN7_YpSKAL2022</a></li>
                                <li><a href="/jbrowse/?data=data_rn7yps">rnBN7_YpSKAL2023</a></li>
                                <li><a href="/jbrowse/?data=data_rnUTH">UTH Rnor SHRSP BbbUtx 1.0</a></li>
                                <li><a href="/jbrowse/?data=data_uth_shr">UTH_Rnor_SHR_Utx</a></li>
                                <li><a href="/jbrowse/?data=data_uth_shrsp">UTH_Rnor_SHRSP_BbbUtx_1.0</a></li>
                                <li><a href="/jbrowse/?data=data_uth_wky">UTH_Rnor_WKY_Bbb_1.0</a></li>
                                <li><a href="/jbrowse/?data=data_uth_wky2023">UTH_Rnor_WKY_2023</a></li>
                                <li><a href="/jbrowse/?data=data_rgd6">Rat Genome Database v6</a></li>
                                <li><a href="/jbrowse/?data=data_rgd5">Rat Genome Database v5</a></li>
                                <li><a href="/jbrowse/?data=data_rgd3_4">Rat Genome Database v3.4</a></li>
                                <li><a href="/jbrowse/?data=data_mm39">RGD Mouse GRCm39 (mm39)</a></li>
                                <li><a href="/jbrowse/?data=data_mm38">RGD Mouse v38 (mm10)</a></li>
                                <li><a href="/jbrowse/?data=data_mm37">RGD Mouse v37</a></li>
                                <li><a href="/jbrowse/?data=data_hg18">RGD Human v36.3 (hg18)</a></li>
                                <li><a href="/jbrowse/?data=data_hg19">RGD Human v37 (hg19)</a></li>
                                <li><a href="/jbrowse/?data=data_hg38">RGD Human v38.7 (hg38)</a></li>
                                <li><a href="/jbrowse/?data=data_dog3_1">RGD Dog CanFam3.1</a></li>
                                <li><a href="/jbrowse/?data=data_bonobo1_1">RGD Bonobo panpan1.1</a></li>
                                <li><a href="/jbrowse/?data=data_squirrel2_0">RGD Squirrel SpeTri2.0</a></li>
                                <li><a href="/jbrowse/?data=data_cl1_0">RGD Chinchilla ChiLan1.0</a></li>
                                <li><a href="/jbrowse/?data=data_pig11_1">RGD Pig Sscrofa11.1</a></li>
                                <li><a href="/jbrowse/?data=data_pig10_2">RGD Pig Sscrofa10.2</a></li>
                                <li><a href="/jbrowse/?data=data_chlSab2">RGD Green Monkey 1.1 (chlSab2)</a></li>
                                <li><a href="/jbrowse/?data=data_hetGla2">RGD Naked Mole Rat (HetGla_female_1.0)</a></li>
                                <li><a href="/jbrowse/?data=data_veroWho">RGD Green Monkey (Vero_WHO_p1.0)</a></li>
                            </ul></div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>



<%@ include file="/common/footerarea.jsp"%>



