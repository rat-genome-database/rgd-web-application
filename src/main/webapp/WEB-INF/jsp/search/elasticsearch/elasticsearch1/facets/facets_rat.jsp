
<%@ page import="org.elasticsearch.search.aggregations.bucket.terms.Terms" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %><%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/15/2024
  Time: 10:07 AM
  To change this template use File | Settings | File Templates.
--%>
<%
    Map<String, Integer> docCounts=new HashMap<>();
    long ratDocCount=0;
    for(Terms.Bucket speciesBkt:species){
        if(speciesBkt.getKey().toString().equalsIgnoreCase("rat")){
            ratDocCount=speciesBkt.getDocCount();
            List<Terms.Bucket> ratBuckets= (List<Terms.Bucket>) aggregations.get("rat");
            for(Terms.Bucket bkt:ratBuckets){
                docCounts.put((String) bkt.getKey(), Math.toIntExact(bkt.getDocCount()));
            }
            System.out.println("DOC COUNTS:" + docCounts.keySet());
        }
    }
if(ratDocCount!=0){
%>
<li>
<button style="border:none;background-color: transparent" onclick="filterClick('<%=searchBean.getCategory()%>', 'Rat','', '')"><span style="font-weight: bold;color:#24609c">Rat ( <%=ratDocCount%>)</span></button>
<ul>
    <% if(docCounts.get("Gene")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Gene', 'Rat','','')"><span>Gene (<%=docCounts.get("Gene")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get("ratGene")){%>
            <li onclick="filterClick('Gene', 'Rat','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("Strain")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Strain', 'Rat','','')"><span>Strain (<%=docCounts.get("Strain")%>)</span></button>
        <ul><%
            for(Terms.Bucket bkt:aggregations.get("ratStrain")){%>
            <li onclick="filterClick('Strain', 'Rat','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("QTL")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('QTL', 'Rat','','')"><span>QTL (<%=docCounts.get("QTL")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get("ratQTL")){%>
            <li onclick="filterClick('QTL', 'Rat','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("SSLP")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('SSLP', 'Rat','','')"><span>QTL (<%=docCounts.get("SSLP")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get("ratSSLP")){%>
            <li onclick="filterClick('SSLP', 'Rat','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("Cell line")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Cell line', 'Rat','','')"><span>Cell line (<%=docCounts.get("Cell line")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get("ratCell line")){%>
            <li onclick="filterClick('Cell line', 'Rat','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("Promoter")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Promoter', 'Rat','','')"><span>Promoter (<%=docCounts.get("Promoter")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get("ratPromoter")){%>
            <li onclick="filterClick('Promoter', 'Rat','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("Variant")!=null){%>
    <li><button style="border:none;background-color: transparent" onclick="filterClick('Variant', 'Rat','','')"><span>Variant (<%=docCounts.get("Variant")%>)</span></button>

        <ul>
            <li><span>Type</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get("ratVariant")){%>
                    <li onclick="filterClick('Variant', 'Rat','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <li><span>Polyphen</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get("ratPolyphen")){%>
                    <li onclick="filterClick('Variant', 'Rat','', '<%=bkt.getKey()%>', 'polyphenStatus')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <li><span>Region</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get("ratRegion")){%>
                    <li onclick="filterClick('Variant', 'Rat','', '<%=bkt.getKey()%>', 'region')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <li><span>Sample</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get("ratSample")){%>
                    <li onclick="filterClick('Variant', 'Rat','', '<%=bkt.getKey()%>', 'sample')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
        </ul>

    </li>
    <%}%>
</ul>
</li>
<%}%>
