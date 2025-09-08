<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="org.springframework.ui.ModelMap" %>
<%@ page import="edu.mcw.rgd.search.elasticsearch1.model.SearchBean" %>
<%@ page import="org.elasticsearch.search.aggregations.bucket.terms.Terms" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.elasticsearch.search.SearchHit" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ taglib prefix="f" uri="/WEB-INF/tld/functions.tld" %>


<script>
    let link=true;
    let highlightTerm="${model.term}";
</script>
<script>
    $(function () {
        var highlightTerm="${model.term}";


        $(".more").hide();
        $(".moreLink").on("click", function(e) {

            var $this = $(this);
            var $content = $this.parent().find(".more");
            var linkText = $this.text().toUpperCase();

            if(linkText === "SHOW MATCHES..."){
                linkText = "Hide...";
                $content.show();
            } else {
                linkText = "Show Matches...";
                $content.hide();
            }
            $this.text(linkText);
            return false;

        });

        $(".filter-list ul").each(function () {
            var liCount = $(this).children("li").length;
            if (liCount > 5) {
                $(this).next(".moremaps").addClass("showMe");
            }
        });

        $(".moremaps").click(function () {
            $(this).prev("ul").find("li").toggleClass("showList");
            $(this).text(this.innerHTML.includes("more") ? "See less..." : "See more...");
        });

    })

</script>

<%
    ModelMap model= (ModelMap) request.getAttribute("model");
    SearchBean searchBean= (SearchBean) model.get("searchBean");
    String category=searchBean.getCategory();
    Map<String, List<? extends Terms.Bucket>> aggregations= (Map<String, List<? extends Terms.Bucket>>) model.get("aggregations");
    List<Terms.Bucket> speciesAggregations= (List<Terms.Bucket>) aggregations.get("species");
    List<Terms.Bucket> ontologyAggregations= (List<Terms.Bucket>) aggregations.get("ontology");

    String defaultAssembly= null;
            if(model.get("defaultAssembly")!=null) {
                defaultAssembly=    model.get("defaultAssembly").toString();
            }
    SearchHit[] searchHits= null;
    if(model.get("hitArray")!=null)
        searchHits= (SearchHit[]) model.get("hitArray");
    if(searchHits!=null){


%>
<table width="100%">

<tr><td>
<div>
<%@include file="filterResultsHeader.jsp"%>
    </div>
</td></tr>
    <tr><td>
<div class="results" id="tableDiv" style=";word-wrap: break-word; " >
    <%if(category.equalsIgnoreCase("Gene") || category.equalsIgnoreCase("Expressed Gene")
                         || category.equalsIgnoreCase("Promoter")){%>
    <%@include file="resultTables/gene.jsp"%>
    <%}%>
    <%if(category.equalsIgnoreCase("Qtl")){%>
    <%@include file="resultTables/qtl.jsp"%>
    <%}%>
    <%if(category.equalsIgnoreCase("Strain")){%>
    <%@include file="resultTables/strain.jsp"%>
    <%}%>
    <%if(category.equalsIgnoreCase("Sslp")){%>
    <%@include file="resultTables/sslp.jsp"%>
    <%}%>
    <%if(category.equalsIgnoreCase("Reference")){%>
    <%@include file="resultTables/ref.jsp"%>
    <%}%>
    <%if(category.equalsIgnoreCase("Ontology")){%>
    <%@include file="resultTables/ont.jsp"%>
    <%}%>
    <%if(category.equalsIgnoreCase("Variant")){%>
    <%@include file="resultTables/variant.jsp"%>

    <%}%>
    <%if(category.equalsIgnoreCase("Cell line")){%>
    <%@include file="resultTables/cellline.jsp"%>
    <%}%>
    <%if(category.equalsIgnoreCase("Expression Study")){%>
    <%@include file="resultTables/study.jsp"%>
    <%}%>
    <%if(category.equalsIgnoreCase("General")){%>
    <%@include file="resultTables/general.jsp"%>
    <%}%>

    <input type="hidden" id="sampleExists" value="${sampleExists}"/>
   </div>
    </td></tr>
</table>
<%}%>