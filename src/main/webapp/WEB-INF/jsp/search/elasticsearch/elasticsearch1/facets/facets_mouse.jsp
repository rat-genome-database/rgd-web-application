
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
    Map<String, Integer> mouseDocCounts=new HashMap<>();
    long mouseDocCount=0;
    for(Terms.Bucket speciesBkt:species){
        if(speciesBkt.getKey().toString().equalsIgnoreCase("mouse")){
            mouseDocCount=speciesBkt.getDocCount();
            List<Terms.Bucket> mouseBuckets= (List<Terms.Bucket>) aggregations.get("mouse");
            for(Terms.Bucket bkt:mouseBuckets){
                mouseDocCounts.put((String) bkt.getKey(), Math.toIntExact(bkt.getDocCount()));
            }
            System.out.println("DOC COUNTS:" + mouseDocCounts.keySet());
        }
    }
    if(mouseDocCount!=0){
%>
<li>
    <button style="border:none;background-color: transparent" onclick="filterClick('<%=searchBean.getCategory()%>', 'Mouse','', '')"><span style="font-weight: bold;color:#24609c">mouse ( <%=mouseDocCount%>)</span></button>
    <ul>
        <% if(mouseDocCounts.get("Gene")!=null){%>
        <li> <button style="border:none;background-color: transparent" onclick="filterClick('Gene', 'Mouse','','')"><span>Gene (<%=mouseDocCounts.get("Gene")%>)</span></button>
            <ul><%for(Terms.Bucket bkt:aggregations.get("mouseGene")){%>
                <li onclick="filterClick('Gene', 'Mouse','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                <%}%>
            </ul>
        </li>
        <%}%>
        <% if(mouseDocCounts.get("Strain")!=null){%>
        <li> <button style="border:none;background-color: transparent" onclick="filterClick('Strain', 'Mouse','','')"><span>Strain (<%=mouseDocCounts.get("Strain")%>)</span></button>
            <ul><%
                for(Terms.Bucket bkt:aggregations.get("mouseStrain")){%>
                <li onclick="filterClick('Strain', 'Mouse','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                <%}%>
            </ul>
        </li>
        <%}%>
        <% if(mouseDocCounts.get("QTL")!=null){%>
        <li> <button style="border:none;background-color: transparent" onclick="filterClick('QTL', 'Mouse','','')"><span>QTL (<%=mouseDocCounts.get("QTL")%>)</span></button>
            <ul><%for(Terms.Bucket bkt:aggregations.get("mouseQTL")){%>
                <li onclick="filterClick('QTL', 'Mouse','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                <%}%>
            </ul>
        </li>
        <%}%>
        <% if(mouseDocCounts.get("SSLP")!=null){%>
        <li> <button style="border:none;background-color: transparent" onclick="filterClick('SSLP', 'Mouse','','')"><span>QTL (<%=mouseDocCounts.get("SSLP")%>)</span></button>
            <ul><%for(Terms.Bucket bkt:aggregations.get("mouseSSLP")){%>
                <li onclick="filterClick('SSLP', 'Mouse','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                <%}%>
            </ul>
        </li>
        <%}%>
        <% if(mouseDocCounts.get("Cell line")!=null){%>
        <li> <button style="border:none;background-color: transparent" onclick="filterClick('Cell line', 'Mouse','','')"><span>Cell line (<%=mouseDocCounts.get("Cell line")%>)</span></button>
            <ul><%for(Terms.Bucket bkt:aggregations.get("mouseCell line")){%>
                <li onclick="filterClick('Cell line', 'Mouse','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                <%}%>
            </ul>
        </li>
        <%}%>
        <% if(mouseDocCounts.get("Promoter")!=null){%>
        <li> <button style="border:none;background-color: transparent" onclick="filterClick('Promoter', 'Mouse','','')"><span>Promoter (<%=mouseDocCounts.get("Promoter")%>)</span></button>
            <ul><%for(Terms.Bucket bkt:aggregations.get("mousePromoter")){%>
                <li onclick="filterClick('Promoter', 'Mouse','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                <%}%>
            </ul>
        </li>
        <%}%>
        <% if(mouseDocCounts.get("Variant")!=null){%>
        <li><button style="border:none;background-color: transparent" onclick="filterClick('Variant', 'Mouse','','')"><span>Variant (<%=mouseDocCounts.get("Variant")%>)</span></button>

            <ul>
                <li><span>Type</span>
                    <ul><%for(Terms.Bucket bkt:aggregations.get("mouseVariant")){%>
                        <li onclick="filterClick('Variant', 'Mouse','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <%}%>
                    </ul>
                </li>
                <li><span>Polyphen</span>
                    <ul><%for(Terms.Bucket bkt:aggregations.get("mousePolyphen")){%>
                        <li onclick="filterClick('Variant', 'Mouse','', '<%=bkt.getKey()%>', 'polyphenStatus')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <%}%>
                    </ul>
                </li>
                <li><span>Region</span>
                    <ul><%for(Terms.Bucket bkt:aggregations.get("mouseRegion")){%>
                        <li onclick="filterClick('Variant', 'Mouse','', '<%=bkt.getKey()%>', 'region')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <%}%>
                    </ul>
                </li>
                <li><span>Sample</span>
                    <ul><%for(Terms.Bucket bkt:aggregations.get("mouseSample")){%>
                        <li onclick="filterClick('Variant', 'Mouse','', '<%=bkt.getKey()%>', 'sample')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <%}%>
                    </ul>
                </li>
            </ul>

        </li>
        <%}%>
    </ul>
</li>
<%}%>
