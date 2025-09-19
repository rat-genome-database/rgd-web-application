<%@ page import="com.google.gson.Gson" %><%@ page import="java.util.LinkedHashMap" %><%@ page import="org.springframework.ui.ModelMap" %><%@ page import="org.elasticsearch.search.SearchHit" %><%@ page import="java.util.List" %><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="f" uri="/WEB-INF/tld/functions.tld" %><% Gson gson = new Gson();

    LinkedHashMap<String,String> hm = new LinkedHashMap<String,String>();
    ModelMap mm = (ModelMap) request.getAttribute("model");
    if(mm!=null && mm.get("hitArray")!=null) {
        SearchHit[] hits = (SearchHit[]) mm.get("hitArray");

        for (SearchHit sh : hits) {
            // for (int i=0; i< hits.length; i++) {
            hm.put((String) sh.getSourceAsMap().get("term_acc"), (String) sh.getSourceAsMap().get("term"));
            // }
        }

        out.print(gson.toJson(hm));

    }
%>