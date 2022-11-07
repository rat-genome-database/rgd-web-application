
<%
    if (ontId.equals("uberon")){
        size = tissueMap.size();
        idName = "tissueId";
    }
    else if (ontId.equals("rs")){
        size = strainMap.size();
        idName = "strainId";
    }
    else if (ontId.equals("cl")){
        size = cellTypeMap.size();
        idName = "cellTypeId";
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
        <%=ontId%>_popup<%=i%>_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=<%=ontId.toUpperCase()%>&sel_term=<%=ontId%>_term&sel_acc_id=<%=idName+i%>&term=&curationTool=1"
               +document.getElementById("<%=ontId%>_term").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
        return false;
    });

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

<%--    $("#<%=ontId%>_popup").click(function(){--%>
<%--        if( <%=ontId%>_popup_wnd!=null ) {--%>
<%--            if( !<%=ontId%>_popup_wnd.closed ) {--%>
<%--                <%=ontId%>_popup_wnd.focus();--%>
<%--                return;--%>
<%--            }--%>
<%--        }--%>
<%--        <%=ontId%>_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=<%=ontId.toUpperCase()%>&sel_term=<%=ontId%>_term&sel_acc_id=<%=ontId%>_acc_id&term="--%>
<%--            +document.getElementById("<%=ontId%>_term").value,--%>
<%--            '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");--%>
<%--        return false;--%>
<%--    });--%>

<%--    $('#<%=ontId%>_term').result(function(data, value){--%>
<%--    document.getElementById("<%=ontId%>_acc_id").value= value[1];--%>
<%--    });--%>