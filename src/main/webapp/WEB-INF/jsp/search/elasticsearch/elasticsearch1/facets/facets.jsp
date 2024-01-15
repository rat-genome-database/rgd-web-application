<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.elasticsearch.search.aggregations.bucket.terms.Terms" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %><%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/15/2024
  Time: 3:30 PM
  To change this template use File | Settings | File Templates.
--%>
<%
    Map<String, Integer> docCounts=new HashMap<>();
    List<Terms.Bucket> buckets=new ArrayList<>();
    String category=new String();
    String species=new String();
    long docCount=0;

%>
<li>
    <button style="border:none;background-color: transparent" onclick="filterClick('<%=category%>', '<%=species%>','', '')"><span style="font-weight: bold;color:#24609c"><%=species%> ( <%=docCount%>)</span></button>
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
                <li><span>Type</span>
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
