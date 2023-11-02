




var <%=ontId%>_popup_wnd = null;

    $("#<%=ontId%>_popup").click(function(){
        if( <%=ontId%>_popup_wnd!=null ) {
            if( !<%=ontId%>_popup_wnd.closed ) {
                <%=ontId%>_popup_wnd.focus();
                return;
            }
        }
        <%=ontId%>_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=<%=ontId.toUpperCase()%>&sel_term=<%=ontId%>_term&sel_acc_id=<%=ontId%>_acc_id&term="
               +document.getElementById("<%=ontId%>_term").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
        return false;
    });


    $("input[name='<%=ontId%>_term']").autocomplete('/solr/OntoSolr/select', {
      extraParams:{
          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
          'bf': 'term_len_l^.02',

          'fq': 'cat:(<%=ontId.toUpperCase()%>)',
          'wt': 'velocity',
          'v.template': 'termidselect'
      },
    crossDomain: true,
      max: 100,
      'termSeparator': ' OR '
    }
    );

    $('#<%=ontId%>_term').result(function(data, value){
        document.getElementById("<%=ontId%>_acc_id").value= value[1];
    });


