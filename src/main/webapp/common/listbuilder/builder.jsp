
<link href="http://dev.rgd.mcw.edu/common/style/rgd_styles-3.css" rel="stylesheet" type="text/css" />



<script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

<link rel="stylesheet" href="/rgdweb/OntoSolr/jquery.autocomplete.css" type="text/css" />

<style>
.rootont {
    float:left;
    padding-left:5px;
    padding-right:20px;
    width:205px;
}

.credittext {
    font-size:11px;
    color:#808080;
}
.credittext A {
    font-size:11px;
    color:#505050;
}
</style>


Generate a gene list base on ontology terms

<div style="border: 1px solid black;background-color:white;margin-bottom: 10px; padding-left:8px; padding-rigth:8px;padding-bottom:5px;">
<h2>Browse Ontologies</h2>


    <p style="font-size:11px;color:gray">Click ontology name to browse term tree.</p>


  <div><!-- div with all checkboxes for ontologies -->
      <div class="rootont">      <table border=0 width="300">
                <tr>
                    <td width=20><a href="/rgdweb/ontology/view.html?acc_id=CHEBI:0"><img src="/rgdweb/common/images/add.png"></a></td>
                    <td><label for="ontid_CHEBI"><a href="/rgdweb/ontology/view.html?acc_id=CHEBI:0" title="click to browse ontology tree">CHEBI:&nbsp;Chebi&nbsp;Ontology</a></label></td>
                </tr>
              </table>

            </div>
      <div class="rootont">      <table border=0 width="300">
                <tr>
                    <td width=20><a href="/rgdweb/ontology/view.html?acc_id=CL:0000000"><img src="/rgdweb/common/images/add.png"></a></td>
                    <td><label for="ontid_CL"><a href="/rgdweb/ontology/view.html?acc_id=CL:0000000" title="click to browse ontology tree">CL:&nbsp;Cell&nbsp;Ontology</a></label></td>
                </tr>
              </table>

            </div>
      <div class="rootont">      <table border=0 width="300">
                <tr>
                    <td width=20><a href="/rgdweb/ontology/view.html?acc_id=GO:0008150"><img src="/rgdweb/common/images/add.png"></a></td>
                    <td><label for="ontid_BP"><a href="/rgdweb/ontology/view.html?acc_id=GO:0008150" title="click to browse ontology tree">GO:&nbsp;Biological&nbsp;Process</a></label></td>
                </tr>
              </table>

            </div>
      <div class="rootont">      <table border=0 width="300">
                <tr>
                    <td width=20><a href="/rgdweb/ontology/view.html?acc_id=GO:0005575"><img src="/rgdweb/common/images/add.png"></a></td>
                    <td><label for="ontid_CC"><a href="/rgdweb/ontology/view.html?acc_id=GO:0005575" title="click to browse ontology tree">GO:&nbsp;Cellular&nbsp;Component</a></label></td>
                </tr>
              </table>

            </div>
      <div class="rootont">      <table border=0 width="300">
                <tr>
                    <td width=20><a href="/rgdweb/ontology/view.html?acc_id=GO:0003674"><img src="/rgdweb/common/images/add.png"></a></td>
                    <td><label for="ontid_MF"><a href="/rgdweb/ontology/view.html?acc_id=GO:0003674" title="click to browse ontology tree">GO:&nbsp;Molecular&nbsp;Function</a></label></td>
                </tr>
              </table>

            </div>
      <div class="rootont">      <table border=0 width="300">
                <tr>
                    <td width=20><a href="/rgdweb/ontology/view.html?acc_id=MP:0000001"><img src="/rgdweb/common/images/add.png"></a></td>
                    <td><label for="ontid_MP"><a href="/rgdweb/ontology/view.html?acc_id=MP:0000001" title="click to browse ontology tree">MP:&nbsp;Mammalian&nbsp;Phenotype</a></label></td>
                </tr>
              </table>

            </div>
      <div class="rootont">      <table border=0 width="300">
                <tr>
                    <td width=20><a href="/rgdweb/ontology/view.html?acc_id=PW:0000001"><img src="/rgdweb/common/images/add.png"></a></td>
                    <td><label for="ontid_PW"><a href="/rgdweb/ontology/view.html?acc_id=PW:0000001" title="click to browse ontology tree">PW:&nbsp;Pathway&nbsp;Ontology</a></label></td>
                </tr>
              </table>

            </div>
      <div class="rootont">      <table border=0 width="300">
                <tr>
                    <td width=20><a href="/rgdweb/ontology/view.html?acc_id=RDO:0000001"><img src="/rgdweb/common/images/add.png"></a></td>
                    <td><label for="ontid_RDO"><a href="/rgdweb/ontology/view.html?acc_id=RDO:0000001" title="click to browse ontology tree">RDO:&nbsp;RGD&nbsp;Disease&nbsp;Ontology</a></label></td>
                </tr>
              </table>

            </div>
      <div class="rootont">      <table border=0 width="300">
                <tr>
                    <td width=20><a href="/rgdweb/ontology/view.html?acc_id=RS:0000457"><img src="/rgdweb/common/images/add.png"></a></td>
                    <td><label for="ontid_RS"><a href="/rgdweb/ontology/view.html?acc_id=RS:0000457" title="click to browse ontology tree">RS:&nbsp;Rat&nbsp;Strains</a></label></td>
                </tr>
              </table>

            </div>

      <div style="clear:both;"></div>
  </div>

</div>
</div>


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



<table>
<tr>
    <td width=100>Disease:</td>
    <td colspan="2">
        <input type="text" id = "rdo_term" name="rdo_term" size="40" value="">
        <input type="hidden" id="rdo_acc_id" name="rdo_acc_id" value=""/>
        <!--<input type="button" id="rdo_popup" value="Browse Diseases" >-->
        <a href="" id="rdo_popup">Browse Ontology Tree</a>
    </td>
</tr>
</table>
<table>
<tr>
    <td width=100>Pathway:</td>
    <td colspan="2">
        <input type="text" id = "pw_term" name="pw_term" size="40" value="">
        <input type="hidden" id="pw_acc_id" name="pw_acc_id" value=""/>
        <!--<input type="button" id="rdo_popup" value="Browse Diseases" >-->
        <a href="" id="pw_popup">Browse Ontology Tree</a>
    </td>
</tr>
</table>
<table>
<tr>
    <td width=100>Mammalian Phenotype:</td>
    <td colspan="2">
        <input type="text" id = "mp_term" name="mp_term" size="40" value="">
        <input type="hidden" id="mp_acc_id" name="mp_acc_id" value=""/>
        <!--<input type="button" id="rdo_popup" value="Browse Diseases" >-->
        <a href="" id="mp_popup">Browse Ontology Tree</a>
    </td>
</tr>
</table>
<table>
<tr>
    <td width=100>CHEBI:</td>
    <td colspan="2">
        <input type="text" id = "chebi_term" name="chebi_term" size="40" value="">
        <input type="hidden" id="chebi_acc_id" name="chebi_acc_id" value=""/>
        <!--<input type="button" id="rdo_popup" value="Browse Diseases" >-->
        <a href="" id="chebi_popup">Browse Ontology Tree</a>
    </td>
</tr>
</table>
