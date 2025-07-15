<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>

<style>

    .carpeLabel {
        font-weight:700;
        background-color:#eeeeee;
        padding-left:5px;
    }

    .carpeASTable{
        background-color:white;
        border: 2px outset #95999b;
    }

    .carpeASTable td {
        color: #111324;
        font-weight:700;

    }

    .carpeLogin {
        background-color: #E8E4D5;
        border:  1px dotted black;
        padding: 35px
    }

    .carpeVarTable{
        background-color:white;
    }

    .carpeASTable td, a,  option{
       font-size:11px;
       font-family:Arial;
       color:#073B6B;
    }

    .carpeASTable input, textarea{
       font-size:11px;
       font-family:Arial;
       color:#3F3F3F;
        border: 1px solid #073B6B;
    }



    .carpeNavTable td, a {
       font-size:11px;
       padding: 2px;
       font-family:Arial;
       color:#3F3F3F;
    }

    .carpeVarTable td, a {
       font-size:11px;
       font-family:Arial;
       color:#3F3F3F;
    }

    .stepLabel {

        font-size:20px;
        font-style:italic;
        margin-bottom:0px;
    }

    .stepLabel td {
        color:white;
        padding-top: 8px;
        padding-left: 8px;
    }

    .typerMat {
        background-image: url(/rgdweb/common/images/bg3.png);

    }

    .typerTitle {
        font-size:16px;
        border: 1px solid black;
        margin-right: 25px;
        *margin-right:9px;
        top: -10px;
        left: 25px;
        position:relative;
        background-image: url(/rgdweb/common/images/dna2.jpg);
        color:black;

    }

    .typerTitleSub{
        background-color:white;
        width:180px;
        padding-left:4px;
        font-size:22px;

    }


    .typerTableHeader {
    }

    .snpHeader {
        background-color: white;
    }

    .snpLabel {
        font-size:11px;
        background-color:#EEEEEE;
        height:23px;
        overflow: hidden;
        text-align: right;
        vertical-align: middle;
        padding-right:4px;
        width:100%;



    }
    .snpLabel a {
        color:#3F3F3F;
        font-size:11px;
        text-align:center;
        vertical-align: middle;
        padding-top:10px;
    }

    .continueButton {
        font-size:16px;
        background-color:#2865A3;
        color:white;
    }

    .typerSubTitle {
        font-weight:700;
        color:#073B6B;
        font-family: italic;
        font-size:14px;
        border-bottom:1px solid #073B6B;
        vertical-align:middle;

    }
    #mainTable *{
        box-sizing: unset;
    }
    #mainTable table {
        border-collapse: unset;
    }
</style>

<script>
    //add a parameter on to the query string passed in
    function addParam(name, value, queryString) {
        var re = new RegExp(name + "=[^\&]*");
        if( re.exec(queryString) != null ) {
            queryString = queryString.replace(re, name + "=" + value);
        }
        else {
            queryString = queryString + "&" + name + "=" + value;
        }
        return queryString;
    }

    //cross browser return of event target
    function getTarget(e) {
        return document.all ? e.srcElement : e.currentTarget;
    }

    function showVariants(e) {


        if (!e) e = window.event;
        var firedDiv = getTarget(e);

        if(document.all) {
        while ((firedDiv != null) ) {
            if (firedDiv.gene) {
                break;
            }

            firedDiv = firedDiv.parentElement;
        }
        }
        navigate(firedDiv.gene, firedDiv.sample);
    }

    function navigate(gene, sample) {

        gene = gene.replaceAll("|","%7C");

        var qString="<%=request.getQueryString()%>";
        console.log("QSTRING:"+ qString)
        var queryString="?";
        if(qString!=null && qString!="null")
        {
         queryString = queryString+"<%=request.getQueryString()%>";
        }
        queryString = addParam("chr","",queryString);
        queryString = addParam("start","",queryString);
        queryString = addParam("stop","",queryString);
        queryString = addParam("geneList",gene,queryString);
        queryString = addParam("geneStart","",queryString);
        queryString = addParam("geneStop","",queryString);
      //  queryString=addParam("sample", sample, queryString);// to display results for one sample
        queryString = addParam("geneStop","",queryString); // displays all samples
        queryString=addParam("mapKey","<%=request.getParameter("mapKey")%>", queryString);

       queryString=addParam("showDifferences","<%=request.getParameter("showDifferences")%>", queryString );

      <%    

       for (int i=1; i<1000; i++) {
           if (request.getParameter("sample" + i) != null) {

   %>
        queryString=addParam("sample<%=i%>", "<%=request.getParameter("sample" + i)%>", queryString);

        <%
                    }
                }

        %>
        console.log("variants.html"+queryString);
        location.href="variants.html" + queryString;
        console.log("variants.html"+queryString);
     //   window.open("variants.html" + queryString);
    }



</script>

<%
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req,  new ArrayList());
    FormUtility fu = new FormUtility();

    String geneList="";


%>
<%@ include file="/common/googleAnalytics.jsp" %>
