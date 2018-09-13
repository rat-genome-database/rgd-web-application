<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ taglib uri="http://rgd.mcw.edu/taglibs/ontbrowser" prefix="ontbrowser" %>
<!DOCTYPE html>
<head>
    <link href="/common/style/rgd_styles-3.css" rel="stylesheet" type="text/css" >
    <link href="/rgdweb/css/ontology.css" rel="stylesheet" type="text/css" >
</head>
<body>
<%

    // if acc_id parameter is not given, use 'ont' parameter to determine ontology root term
    // for browsing
    response.setHeader("Access-Control-Allow-Origin", "*.mcw.edu");
    String accId = request.getParameter("acc_id");
    if( Utils.isStringEmpty(accId) ) {
        String ontId = request.getParameter("ont");
        if( !Utils.isStringEmpty(ontId) ) {

            // try a term parameter
            String termName = request.getParameter("term");
            if( !Utils.isStringEmpty(termName) ) {
                Term term = new OntologyXDAO().getTermByTermName(termName, ontId);
                if( term!=null )
                    accId = term.getAccId();
            }

            if( Utils.isStringEmpty(accId) )
                accId = new OntologyXDAO().getRootTerm(ontId);
        }
    }

    // url for browsing the tree should include 'sel_acc_id' and 'sel_term' parameters if available
    String selAccId = request.getParameter("sel_acc_id");
    String selTerm = request.getParameter("sel_term");
    String url = "/rgdweb/ontology/view.html?mode=popup";
    if( !Utils.isStringEmpty(selAccId) )
        url += "&sel_acc_id="+selAccId;
    if( !Utils.isStringEmpty(selTerm) )
        url += "&sel_term="+selTerm;
    if( Utils.NVL(request.getParameter("dia"),"0").equals("1") ) {
        url += "&dia=1";
    }
%>

<ontbrowser:tree acc_id="<%=accId%>"
                 url="<%=url%>"
                 offset="<%=request.getParameter(\"offset\")%>"
                 opener_sel_acc_id="<%=selAccId%>"
                 opener_sel_term="<%=selTerm%>"
                 filter="<%=request.getParameter(\"filter\")%>"
        />
</body>
</html>