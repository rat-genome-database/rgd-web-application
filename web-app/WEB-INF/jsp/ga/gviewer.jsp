<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.datamodel.QTL" %>
<%@ page import="edu.mcw.rgd.datamodel.SSLP" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>


<%@ include file="header.jsp" %>
<%@ include file="menuBar.jsp" %>


<jsp:include page="/rgdweb/gTool/displayViewer.jsp?genes=A2M,RAET1E,RAET1L,LRP11,PCMT1,LATS1,KATNA1,PPIL4,ZC3H12D,TAB2,UST,SAMD5,STXBP5,RAB32,GRM1,SHPRH,FBXO30,RPL35A,UTRN,STX11,SF3B5,PLAGL1,LTV1,PHACTR2,FUCA2,PEX3,AIG1,HIVEP2,GPR126,VTA1,GJE1,CITED2,TXLNB,HECA,REPS1,CCDC28A,HEBP2,PERP,OLIG3,IFNGR1,IL22RA2,IL20RA,SLC35D3,PEX7,MAP7,BCLAF1,PDE7B,AHI1,HBS1L,ALDH8A1,PTPRK,LAMA2,ARHGAP18,L3MBTL3,SAMD3,TMEM200A,AKAP7,ARG1,MED23,ENPP3,ENPP1,CTGF,MOXD1,STX7,TAAR9,TAAR6,TAAR5,TAAR3,TAAR2,TAAR1,VNN1,VNN3,DDX11L1,DDX11L1,WASH7P,MIR1302-2,FAM138A,OR4G4P,OR4G11P,OR4F5,RPL23AP21,CICP7,OR4F29,RPL23AP24,OR4F16,CICP3,LINC00115,FAM41C,SAMD11,NOC2L,KLHL17,PLEKHN1,C1orf170,HES4,RPL39P12,ISG15,AGRN,RNF223,C1orf159,MIR200B,MIR200A,MIR429,TTLL10,TNFRSF18,TNFRSF4,SDF4,B3GALT6,FAM132A,UBE2J2,SCNN1D,ACAP3,PUSL1,CPSF3L,GLTPD1,TAS1R3,DVL1,MXRA8,AURKAIP1,CCNL2,MRPL20,ANKRD65,TMEM88B,VWA1,ATAD3C,ATAD3B,ATAD3A,TMEM240,SSU72,C1orf233,MIB2,MMP23B,CDK11B,SLC35E2B,MMP23A,CDK11A,SLC35E2,NADK,GNB1,CALML6,TMEM52,C1orf222,KIAA1751,GABRD,PRKCZ,C1orf86,SKI&geneColor=blue&qtls=&qtlColor=&species=1&height=200&width=700" >
   <jsp:param name="hello" value="2" />
</jsp:include>


