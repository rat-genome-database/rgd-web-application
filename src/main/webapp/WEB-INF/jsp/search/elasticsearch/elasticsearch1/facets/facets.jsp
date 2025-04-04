<%@ page import="org.elasticsearch.search.aggregations.bucket.terms.Terms" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%@ page import="java.net.URLEncoder" %>
<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/15/2024
  Time: 10:07 AM
  To change this template use File | Settings | File Templates.
--%>

<li>
<button style="border:none;background-color: transparent" onclick="filterClick('<%=searchBean.getCategory()%>', '<%=species%>','', '')"><span style="font-weight: bold;color:#24609c"><%=species%> ( <%=docCount%>)</span></button>
<ul>
    <% if(docCounts.get("Gene")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Gene', '<%=species%>','','')"><span>Gene (<%=docCounts.get("Gene")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get(gene)){%>
            <li onclick="filterClick('Gene', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("Strain")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Strain', '<%=species%>','','')"><span>Strain (<%=docCounts.get("Strain")%>)</span></button>
        <ul><%
            for(Terms.Bucket bkt:aggregations.get(strain)){%>
            <li onclick="filterClick('Strain', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("QTL")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('QTL', '<%=species%>','','')"><span>QTL (<%=docCounts.get("QTL")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get(qtl)){
                String qtlFacet="";
                if(bkt.getKey().toString().length()>50){
                    qtlFacet+=bkt.getKey().toString().substring(0,50);
                    qtlFacet+="...";
                }else{
                    qtlFacet=bkt.getKey().toString();}
        %>
            <li onclick="filterClick('QTL', '<%=species%>','', '<%=URLEncoder.encode(bkt.getKey().toString(),"UTF-8")%>','trait')" title="<%=bkt.getKey()%>"><%=qtlFacet%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("SSLP")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('SSLP', '<%=species%>','','')"><span>SSLP (<%=docCounts.get("SSLP")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get(sslp)){%>
            <li onclick="filterClick('SSLP', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("Cell line")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Cell line', '<%=species%>','','')"><span>Cell line (<%=docCounts.get("Cell line")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get(cellLine)){%>
            <li onclick="filterClick('Cell line', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("Promoter")!=null){%>
    <li> <button style="border:none;background-color: transparent" onclick="filterClick('Promoter', '<%=species%>','','')"><span>Promoter (<%=docCounts.get("Promoter")%>)</span></button>
        <ul><%for(Terms.Bucket bkt:aggregations.get(promoter)){%>
            <li onclick="filterClick('Promoter', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
            <%}%>
        </ul>
    </li>
    <%}%>
    <% if(docCounts.get("Variant")!=null){%>
    <li><button style="border:none;background-color: transparent" onclick="filterClick('Variant', '<%=species%>','','')"><span>Variant (<%=docCounts.get("Variant")%>)</span></button>

        <ul>
            <%if(aggregations.get(variantCategory)!=null && aggregations.get(variantCategory).size()>0){%>

            <li><span>Category</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get(variantCategory)){%>
                    <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>','variantCategory')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <%}%>
            <li><span>Type</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get(variant)){%>
                    <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <%if(aggregations.get(polyphen)!=null && aggregations.get(polyphen).size()>0){%>
            <li><span>Polyphen</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get(polyphen)){%>
                    <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>', 'polyphenStatus')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <%}%>
            <%if(aggregations.get(region)!=null && aggregations.get(region).size()>0){%>

            <li><span>Region</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get(region)){%>
                    <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>', 'region')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <%}%>
            <%if(aggregations.get(sample)!=null && aggregations.get(sample).size()>0){%>

            <li><span>Sample</span>
                <ul><%for(Terms.Bucket bkt:aggregations.get(sample)){%>
                    <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>', 'sample')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                    <%}%>
                </ul>
            </li>
            <%}%>
        </ul>

    </li>
    <%}%>
</ul>
</li>


