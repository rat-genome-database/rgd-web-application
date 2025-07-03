<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>


<%
String pageTitle = "Variant Visualizer (Define Region)";
String headContent = "";
String pageDescription = "Define Region";

%>
<script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

<link rel="stylesheet" href="/solr/OntoSolr/jquery.autocomplete.css" type="text/css" />


<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>



   <br>
<div class="typerMat">
    <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>

    <br>
    <table width="100%" class="stepLabel" cellpadding=0 cellspacing=0>
        <tr>
            <td>Limit Variants to Annotated Genes</td>
        </tr>
    </table>




   <br>

<%--
<div style="background-image: url(/rgdweb/common/images/dna2.jpg);">&nbsp;</div>
--%>


  <script>
$(document).ready(function(){

    // handle to popup windows
    var rdo_popup_wnd = null;
    var chebi_popup_wnd = null;
    var mp_popup_wnd = null;
    var pw_popup_wnd = null;

    $("#rdo_popup").click(function(){
        if( rdo_popup_wnd!=null ) {
            if( !rdo_popup_wnd.closed ) {
                rdo_popup_wnd.focus();
                return;
            }
        }
        rdo_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=RDO&sel_term=rdo_term&sel_acc_id=rdo_acc_id&term="
               +document.getElementById("rdo_term").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
    });

    $("input[name='rdo_term']").autocomplete('/solr/OntoSolr/select', {
      extraParams:{
          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
          'bf': 'term_len_l^.02',

          'fq': 'cat:(RDO)',
          'wt': 'velocity',
          'v.template': 'termidselect'
      },
      max: 100,
      'termSeparator': ' OR '
    }
    );

    $('#rdo_term').result(function(data, value){
        document.getElementById("rdo_acc_id").value= value[1];
    });




   $("#mp_popup").click(function(){
        if( mp_popup_wnd!=null ) {
            if( !mp_popup_wnd.closed ) {
                mp_popup_wnd.focus();
                return;
            }
        }
        mp_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=MP&sel_term=mp_term&&sel_acc_id=mp_acc_id&term="
               +document.getElementById("mp_term").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
    });

    $("input[name='mp_term']").autocomplete('/solr/OntoSolr/select', {
      extraParams:{
          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
          'bf': 'term_len_l^.02',

          'fq': 'cat:(MP)',
          'wt': 'velocity',
          'v.template': 'termidselect'
      },
      max: 100,
      'termSeparator': ' OR '
    }
    );

    $('#mp_term').result(function(data, value){
        document.getElementById("mp_acc_id").value= value[1];
    });


    $("#pw_popup").click(function(){
         if( pw_popup_wnd!=null ) {
             if( !pw_popup_wnd.closed ) {
                 pw_popup_wnd.focus();
                 return;
             }
         }
         pw_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=PW&sel_term=pw_term&sel_acc_id=pw_acc_id&term="
                +document.getElementById("pw_term").value,
                '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
     });

     $("input[name='pw_term']").autocomplete('/solr/OntoSolr/select', {
       extraParams:{
           'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
           'bf': 'term_len_l^.02',

           'fq': 'cat:(PW)',
           'wt': 'velocity',
           'v.template': 'termidselect'
       },
       max: 100,
       'termSeparator': ' OR '
     }
     );

    $('#pw_term').result(function(data, value){
        document.getElementById("pw_acc_id").value= value[1];
    });



    $("#chebi_popup").click(function(){
        if( chebi_popup_wnd!=null ) {
            if( !chebi_popup_wnd.closed ) {
                chebi_popup_wnd.focus();
                return;
            }
        }
        chebi_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=CHEBI&sel_term=chebi_term&sel_acc_id=chebi_acc_id&term="
               +document.getElementById("chebi_term").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
    });

    $("input[name='chebi_term']").autocomplete('/solr/OntoSolr/select', {
      extraParams:{
          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
          'bf': 'term_len_l^.02',

          'fq': 'cat:(CHEBI)',
          'wt': 'velocity',
          'v.template': 'termidselect'
      },
      max: 100,
      'termSeparator': ' OR '
    }
    );

    $('#chebi_term').result(function(data, value){
        document.getElementById("chebi_acc_id").value= value[1];
    });



});
</script>


<form action="dist.html" name="optionForm" >


<table border=0 align="center" style="padding:8px; ">
    <tr>
        <td width=150 style="font-size:16px;color:white;">Variants will only be included if they are located in a gene annotated to terms selected in the form</td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td >

            <table border="0" cellspacing=4 cellpadding=0 class="carpeASTable">
                <tr>
                <td   colspan=3><div class="typerSubTitle" >Position</div></td>
                </tr>


                <tr>
                    <td colspan="3">
                    <table>
                        <tr>
                            <td>Chromosome <select   name="chr" id="chr" ><option value="1" selected>1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="X">X</option><option value="Y">Y</option><option value="MT">MT</option></select></td>
                            <td>&nbsp;&nbsp;&nbsp;Start <input type="text" name="start" size="25" value="<%=FormUtility.formatThousands(dm.out("start",req.getParameter("start")))%>"></td>
                            <td>&nbsp;&nbsp;&nbsp;Stop <input type="text" name="stop" size="25" value="<%=FormUtility.formatThousands(dm.out("stop",req.getParameter("stop")))%>"></td>
                        </tr>
                    </table>
                    </td>
                </tr>
                <tr><td>&nbsp;</td></tr>
                <tr>
                <td   colspan=3><div class="typerSubTitle" >Select Terms</div></td>
                </tr>
                <tr>
                    <td colspan=2>
                        <table>
                        <tr>
                            <td width=100>Disease:</td>
                            <td colspan="2">
                                <input type="text" id = "rdo_term" name="rdo_term" size="40" value="<%=req.getParameter("rdo_term")%>">
                                <input type="hidden" id="rdo_acc_id" name="rdo_acc_id" value="<%=req.getParameter("rdo_acc_id")%>"/>
                                <input type="button" id="rdo_popup" value="Browse Diseases" >
                            </td>
                        </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan=2>
                        <table>
                        <tr>
                            <td width=100>Pathway:</td>
                            <td   colspan="2">
                                <input type="text" id = "pw_term" name="pw_term" size="40"  value="<%=req.getParameter("pw_term")%>" >
                                <input type="hidden" id="pw_acc_id" name="pw_acc_id" value="<%=req.getParameter("pw_acc_id")%>"/>
                                <input type="button" id="pw_popup" value="Browse Pathways">
                            </td>
                        </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan=2>
                        <table>
                        <tr>
                            <td width=100>Phenotype:</td>
                            <td   colspan="2">
                                <input type="text" id = "mp_term" name="mp_term" size="40" value="<%=req.getParameter("mp_term")%>" >
                                <input type="hidden" id="mp_acc_id" name="mp_acc_id" value="<%=req.getParameter("mp_acc_id")%>"/>
                                <input type="button" id="mp_popup" value="Browse Phenotypes">
                            </td>
                        </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan=2>
                        <table>
                        <tr>
                            <td  width=100>Drug/Chemical:</td>
                            <td colspan="2">
                                <input type="text" id = "chebi_term" name="chebi_term" size="40" value="<%=req.getParameter("chebi_term")%>">
                                <input type="hidden" id="chebi_acc_id" name="chebi_acc_id" value="<%=req.getParameter("chebi_acc_id")%>"/>
                                <input type="button" id="chebi_popup" value="Browse Drugs and Chemicals">
                            </td>
                        </tr>
                        </table>
                    </td>
                </tr>
                <tr><td>&nbsp;</td></tr>

            </table>
            </td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>

        <td valign="top" align="left">
            <div style="margin-left:10px;"><input  class="continueButton"  type="submit" value="Continue..."/></div>
        </td>
    </tr>
</table>

    <br><br>
   <table width="100%" class="stepLabel" cellpadding=0 cellspacing=0>
   <tr>
   <td><b>Strains Selected</td>
   </tr>
   </table>

        <div style="margin-top:12px; margin-bottom:12px;">
<table border=0 width="100%" style="border:1px dashed white; padding-bottom:5px;">
    <tr>
     <td style="font-size:11px;color:white;" >
    <%
    List<String> sampleIds = new ArrayList();

    for (int i=1; i<100; i++) {
        if (request.getParameter("sample" + i) != null) {
            String strain = "";
            if (i > 1) {
                strain += ",&nbsp;";
            }

            strain+= SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName();

    %>
        <%=strain%>
        <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
    <%
        }
    }
    %>
         <input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>"/>
        </td>
    </tr>
</table>
</div>


</div>

</form>



