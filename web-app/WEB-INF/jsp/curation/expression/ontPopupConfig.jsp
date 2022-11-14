
<%
    switch (ontId) {
        case "uberon":
            if (!createSample)
                size = tissueMap.size();
            idName = "tissueId";
            break;
        case "rs":
            if (!createSample)
                size = strainMap.size();
            idName = "strainId";
            break;
        case "cl":
            if (!createSample)
                size = cellTypeMap.size();
            idName = "cellTypeId";
            break;
    }
    if (size==0)
        size=1;
    for (int i = 0; i < size; i++) {%>

    var <%=ontId%>_popup<%=i%>_wnd = null;
    $("#<%=ontId%>_popup<%=i%>").click(function(){
        if( <%=ontId%>_popup<%=i%>_wnd!=null ) {
            if( !<%=ontId%>_popup<%=i%>_wnd.closed ) {
                <%=ontId%>_popup<%=i%>_wnd.focus();
                return;
            }
        }
        <%=ontId%>_popup<%=i%>_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=<%=ontId.toUpperCase()%>&sel_term=<%=ontId%>_term<%=i%>&sel_acc_id=<%=idName+i%>&curationTool=1&acc_id="
               +document.getElementById("<%=idName+i%>").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
        return false;
    });
<%--    $('#<%=ontId%>_term<%=i%>').result(function(data, value){--%>
<%--    document.getElementById("<%=idName+i%>").value= value[1];--%>
<%--    });--%>
<% } %>

<%--    $("input[name='<%=ontId%>_term']").autocomplete('/OntoSolr/select', {--%>
<%--      extraParams:{--%>
<%--          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',--%>
<%--          'bf': 'term_len_l^.02',--%>

<%--          'fq': 'cat:(<%=ontId.toUpperCase()%>)',--%>
<%--          'wt': 'velocity',--%>
<%--          'v.template': 'termidselect'--%>
<%--      },--%>
<%--      max: 100,--%>
<%--      'termSeparator': ' OR '--%>
<%--    }--%>
<%--    );--%>