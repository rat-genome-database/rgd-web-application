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
    Map<String, Integer> humanDocCounts=new HashMap<>();
    long humanDocCount=0;
    for(Terms.Bucket speciesBkt:species){
        if(speciesBkt.getKey().toString().equalsIgnoreCase("human")){
            humanDocCount=speciesBkt.getDocCount();
            List<Terms.Bucket> buckets= (List<Terms.Bucket>) aggregations.get("human");
            for(Terms.Bucket bkt:buckets){
                humanDocCounts.put((String) bkt.getKey(), Math.toIntExact(bkt.getDocCount()));
            }
            System.out.println("Human DOC COUNTS:" + humanDocCounts.keySet());
        }
    }
if(humanDocCount!=0){
%>
<li>
<button style="border:none;background-color: transparent" onclick="filterClick('<%=searchBean.getCategory()%>', 'Human','', '')"><span style="font-weight: bold;color:#24609c">Human ( <%=humanDocCount%>)</span></button>
<ul>
    <% if(humanDocCounts.get("Gene")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Gene', 'Human','','')"><span>Gene (<%=humanDocCounts.get("Gene")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get("humanGene")){%>
            <li onclick="filterClick('Gene', 'Human','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>

    <% if(humanDocCounts.get("SSLP")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('SSLP', 'Human','','')"><span>SSLP (<%=humanDocCounts.get("SSLP")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get("humanSSLP")){%>
            <li onclick="filterClick('SSLP', 'Human','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(humanDocCounts.get("Cell line")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Cell line', 'Human','','')"><span>Cell line (<%=humanDocCounts.get("Cell line")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get("humanCell line")){%>
            <li onclick="filterClick('Cell line', 'Human','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(humanDocCounts.get("Promoter")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Promoter', 'Human','','')"><span>Promoter (<%=humanDocCounts.get("Promoter")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get("humanPromoter")){%>
            <li onclick="filterClick('Promoter', 'Human','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(humanDocCounts.get("Variant")!=null){%>
    <li><button style="border:none;background-color: transparent" onclick="filterClick('Variant', 'Human','','')"><span>Variant (<%=humanDocCounts.get("Variant")%>)</span></button>

        <ul>
            <li><span>Type</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get("humanVariant")){%>
                    <li onclick="filterClick('Variant', 'Human','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <li><span>Polyphen</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get("humanPolyphen")){%>
                    <li onclick="filterClick('Variant', 'Human','', '<%=bkt.getKey()%>', 'polyphenStatus')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <li><span>Region</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get("humanRegion")){%>
                    <li onclick="filterClick('Variant', 'Rat','', '<%=bkt.getKey()%>', 'region')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <li><span>Sample</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get("humanSample")){%>
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

