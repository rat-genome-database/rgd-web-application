<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<br><br>
<%
    String dest=request.getParameter("dest");
    String loc = request.getParameter("loc");
    String assembly = request.getParameter("assembly");

/*
    CanFam3.1
ChiLan1.0
Chlorocebus_sabeus 1.1
CHM1_1.1
Dog10K_Boxer_Tasha
GRCh37.p13
GRCh38.p14
GRCm38.p6
GRCm39
GRCm39
HetGla_female_1.0
HiC_Itri_2
MGSCv37
Mhudiblu_PPA_v0
mRatBN7.2
mRatBN7.2
NCBI36
NHGRI_mPanPan1-v1.1-0.1.freeze_pri
panpan1.1
RGSC_v3.4
Rnor_5.0
Rnor_6.0
ROS_Cfam_1.0
ROS_Cfam_1.0
SpeTri2.0
SpeTri2.0
Sscrofa10.2
Sscrofa11.1
T2T-CHM13v2.0
UMICH_Zoey_3.1
UNSW_CanFamBas_1.0
UTH_Rnor_SHR_Utx
UTH_Rnor_SHRSP_BbbUtx_1.0
UTH_Rnor_WKY_Bbb_1.0
UU_Cfam_GSD_1.0
Vero_WHO_p1.0

     */

    String tracks = "";
    if (assembly.equals("mRatBN7.2")) {
        tracks="Rat mRatBN7.2 (rn7) Genes and Transcripts-mRatBN7.2";
    }else if (assembly.equals("Rnor_6.0")) {
        tracks="Rat Rnor_6.0 (rn6) Genes and Transcripts-Rnor_6.0";
    }else if (assembly.equals("GRCm39")) {
        tracks="Mouse GRCm39 (mm39) Genes and Transcripts-GRCm39";
    }else if (assembly.equals("GRCm38")) {
        assembly="GRCm38.p6";
        tracks="Mouse GRCm38.p6 (mm10) Genes and Transcripts-GRCm38.p6";
    }else if (assembly.equals("Mhudiblu_PPA_v0")) {
        tracks="Bonobo Mhudiblu_PPA_v0 (panPan3) Genes and Transcripts-Mhudiblu_PPA_v0";
    }else if (assembly.equals("Sscrofa11.1")) {
        tracks="Pig Sscrofa11.1 (susScr11) Genes and Transcripts-Sscrofa11.1";
    }else if (assembly.equals("ChlSab1.1")) {
        assembly="Chlorocebus_sabeus1.1";
        tracks="Green Monkey Chlorocebus_sabeus 1.1 (chlSab2) Genes and Transcripts-Chlorocebus_sabeus1.1";
    }else if (assembly.equals("GRCh38")) {
        assembly="GRCh38.p14";
        tracks="Human GRCh38.p14 (hg38) Genes and Transcripts-GRCh38.p14";
    }else if (assembly.equals("Sscrofa10.2")) {
        tracks="Pig Sscrofa10.2 (susScr3) Genes and Transcripts-Sscrofa10.2";
    }else {
        throw new Exception("Assembly " + assembly + " Not Found");
    }

    String url = "https://rgd.mcw.edu/jbrowse2/index.html?config=config.json";
    url += "&assembly=" + assembly + "&loc=" + loc +"&tracks=" + tracks;


%>

If you are not redirected, click here:  <a href="<%=url%>>">Continue to JBrowse2</a>

<script>
    location.replace(<%=url%>);
</script>

