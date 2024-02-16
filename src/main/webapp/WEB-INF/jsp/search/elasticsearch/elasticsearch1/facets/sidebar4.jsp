<%@ page import="edu.mcw.rgd.search.elasticsearch1.model.SearchBean" %>
<%@ page import="org.springframework.ui.ModelMap" %>
<%@ page import="org.elasticsearch.search.aggregations.bucket.terms.Terms" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    ModelMap model= (ModelMap) request.getAttribute("model");
    SearchBean searchBean= (SearchBean) model.get("searchBean");
    Map<String, List<? extends Terms.Bucket>> aggregations= (Map<String, List<? extends Terms.Bucket>>) model.get("aggregations");
    List<Terms.Bucket> speciesBkts= (List<Terms.Bucket>) aggregations.get("species");
    List<String> speciesOrderList=Arrays.asList("Rat", "Human", "Mouse","Chinchilla","Dog","Bonobo",
            "Pig", "Green Monkey", "Naked Mole-Rat");
    List<Terms.Bucket> speciesOrderedBkts= new ArrayList<>();
    for(String orderedSpecies: speciesOrderList) {
        for (Terms.Bucket species : speciesBkts) {
            if (orderedSpecies.equalsIgnoreCase(species.getKeyAsString())){
                speciesOrderedBkts.add(species);
            }
        }
    }
%>
<div>
<!--div><button id="viewAllBtn" style="display:none">View All Results</button></div-->
    <div>

    <div style="width:40%;float:right">
        <form action="/rgdweb/elasticResults.html" id="viewAllForm">
            <input type="hidden" value="${model.term}" id="searchTerm" name="term"/>
            <input type="hidden" value="general" id="searchCategory" name="category"/>
<%--            <!--input type="hidden" name="species" id = "sp1" value="${model.sp1}"-->--%>
            <input type="hidden" name="type" id = "type" >
            <input type="hidden" name="viewall" value="true"/>
            <input type="hidden" name="chr" id = "chr" value="${model.searchBean.chr}">
            <input type="hidden" name="start" id="start" value="${model.searchBean.start}"/>
            <input type="hidden" name="stop" id = "stop" value="${model.searchBean.stop}"/>
            <c:if test="${!model.objectSearch.equals('true')}">
            <button  type="submit" id="viewAll">View All Results</button>
            </c:if>
        </form>

    </div>

<h3>Filters</h3>

   </div>
<div id="jstree_results">
    <ul>
        <% if(!searchBean.getCategory().equalsIgnoreCase("general") || model.get("defaultAssembly")!=null){%>
        <%

            for(Terms.Bucket speciesBkt:speciesOrderedBkts){
                Map<String, Integer> docCounts=new HashMap<>();
                long docCount=0;
                String species=null;

                    docCount=speciesBkt.getDocCount();
                    species=speciesBkt.getKey().toString();
                    List<Terms.Bucket> buckets= (List<Terms.Bucket>) aggregations.get(species.toLowerCase());
                    if(buckets!=null){
                    for(Terms.Bucket bkt:buckets){
                        docCounts.put((String) bkt.getKey(), Math.toIntExact(bkt.getDocCount()));
                    }
                    String variant=species.toLowerCase()+"Variant";
                    String polyphen=species.toLowerCase()+"Polyphen";
                    String variantCategory=species.toLowerCase()+"VariantCategory";
                    String region=species.toLowerCase()+"Region";
                    String sample=species.toLowerCase()+"Sample";
                    String sslp=species.toLowerCase()+"SSLP";
                    String gene=species.toLowerCase()+"Gene";
                    String strain=species.toLowerCase()+"Strain";
                    String qtl=species.toLowerCase()+"QTL";
                    String cellLine=species.toLowerCase()+"Cell line";
                    String promoter=species.toLowerCase()+"Promoter";
                    if(docCount!=0){
        %>
        <%@include file="facets.jsp"%>


        <%}}}%>
        <li><span style="font-weight: bold;color:#24609c">Other Categories:</span>
            <ul>

                <c:forEach items="${model.aggregations.category}" var="item">
                    <c:if test="${item.key.equalsIgnoreCase('reference')}">
                        <li style="border:none;background-color: transparent;cursor: pointer" onclick="filterClick('${item.key}', '')">${item.key}(${item.docCount})</li>
                    </c:if>
                </c:forEach>

                <c:if test="${fn:length(model.aggregations.ontology)>0}">

                    <c:forEach items="${model.aggregations.category}" var="item">
                        <c:if test="${item.key.equalsIgnoreCase('ontology')}">
                            <li><span style="font-weight: bold">Ontology Terms: (${item.docCount})</span>
                                <ul>
                                    <c:forEach items="${model.aggregations.ontology}" var="ontItem">
                                        <li>
                                            <button style="border:none;background-color: transparent;cursor:pointer" onclick="filterClick('Ontology', '','${ontItem.key}')">${ontItem.key}</button>(${ontItem.docCount})</li>
                                    </c:forEach>
                                </ul>
                            </li>
                        </c:if>
                    </c:forEach>
                </c:if>



            </ul>
        </li>
        <%}%>
    </ul>
</div>

</div>