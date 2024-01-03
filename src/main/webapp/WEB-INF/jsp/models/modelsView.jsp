<%@ page import="edu.mcw.rgd.datamodel.models.GeneticModel" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.models.ModelSort" %>
<%@ page import="edu.mcw.rgd.models.ModelsHeaderRecord" %>
<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%
    List<GeneticModel> strainsUnsorted = (List) request.getAttribute("strains");
//    List<GeneticModel> strainsUnsorted = (List<GeneticModel>) session.getAttribute("strains");
    List<GeneticModel> strains = ModelSort.sortByGeneSymbol(strainsUnsorted);
    Map<ModelsHeaderRecord, List<GeneticModel>> hcMap = (Map) request.getAttribute("headerChildMap");
//    Map<ModelsHeaderRecord, List<GeneticModel>> hcMap = (Map<ModelsHeaderRecord, List<GeneticModel>>) session.getAttribute("headerChildMap");
//    Map<String, String> backStrainList = (Map) session.getAttribute("backStrainList");
    Map<String, String> backStrainList = (Map) request.getAttribute("backStrainList");
%>
<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Rat Genetic Models</div>
</div>

<div id="modelsViewContent" >
    <div style="margin-bottom:10px;width:50%;float:left">
        <input type="text" class="search searchBox rounded" name="geneSearch" data-filter-column="1" placeholder="Search by Gene Symbol..." style="width:60%;border-color:lightgrey">
        <button type="button" class="btn btn-primary reset" title="Reset table">Reset</button> <!-- targeted by the "filter_reset" option -->
    </div>
    <div id="pager" class="pager" style="float:right;margin-bottom:2px;">
        <form>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
            <input type="text" class="pagedisplay"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
            <select class="pagesize">
                <option   value="10">10</option>
                <option value="20">20</option>
                <option value="30">30</option>
                <option  value="40">40</option>
                <option   value="100">100</option>
                <option selected="selected" value="9999">All Rows</option>
            </select>
        </form>
    </div>

</div>

<div id="modelsView" >


    <table id="modelTable" cellspacing="1" class="tablesorter" style="table-layout: fixed;">
        <!--caption style="font-weight:bold;font-size:20px;color:#24609c">Genetic Models Data</caption-->
        <thead>

        <tr>
            <th style="width:5%;cursor:pointer" class="filter-false expandCollapseAll"><i  class="fa fa-plus-circle expandAll" aria-hidden="true" style="color:green;font-size: 20px" title="Click to expand all"></i></th>
            <th  class="tablesorter-header" data-placeholder="" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Gene Symbol</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer;text-align:left "title="Click to Sort">Gene</th>
            <th  class="tablesorter-header filter-false" style=" cursor: pointer; width:5.5%" title="Click to Sort">No. of Models</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer; "title="Click to Sort">Background Strain</th>
            <th class="tablesorter-header" style=" cursor: pointer;" title="Click to Sort">Strain Symbol</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer;"title="Click to Sort">Aliases</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer;"title="Click to Sort">Method</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer;" title="Click to Sort">Availability</th>
            <th class="tablesorter-header filter-false"  >Origination</th>
            <th class="tablesorter-header filter-false" >Phenotype Data</th>
            <th class="tablesorter-header filter-false">Publications</th>
            <th class="tablesorter-header filter-false">Available Source</th>
<%--            <th class="filter-false">Ask about this Model!</th>--%>

        </tr>

        </thead>
        <tbody style="text-align: center;vertical-align:center">
<%--        <c:set var="strains" value="${m:sortByGeneSymbol(model.strains)}"/>--%>
        <% for (ModelsHeaderRecord mhr : hcMap.keySet()) {
            try {
            List<GeneticModel> entry = hcMap.get(mhr);
            boolean headerRec = true;
            if (entry.size()>1){
//                int i = 0;
                for (GeneticModel strain : strains){
                    if (mhr.getGeneSymbol().equals(strain.getGeneSymbol())) {
                        if (headerRec){ %>
            <tr class="header1" style="display:table-row;">
                <td class="toggle" style="cursor:pointer;text-align:center;"><i  class="fa fa-plus-circle expand" aria-hidden="true" style="color:green;font-size: 20px" title="Click to expand"></i></td>
                <td style="" class="geneSymbol"><a href="/rgdweb/report/gene/main.html?id=<%=strain.getGeneRgdId()%>"target="_blank" title="Gene Symbol"><%=mhr.getGeneSymbol()%></a></td>
                <td title="Gene" style=""><%=mhr.getGene()%></td>
                <td  style="text-align: center;font-weight:bold;" title="No. of Models"><%=entry.size()%></td>
                <!--td><span style="color:blue">Click Expand Button</span></td-->
                <%if(backStrainList!=null){%>
                <td style="" title="Click Epand/Collapse Button"><%=backStrainList.get(mhr.getGeneSymbol())%></td>
                <%}else{%>
                <td></td>
                <%}%>
                <td style="" title="Click Epand/Collapse Button"></td>
                <td style="" title="Click Epand/Collapse Button"></td>
                <td style="" title="Click Epand/Collapse Button"></td>
                <td style="" title="Click Epand/Collapse Button"></td>
                <td style="" title="Click Epand/Collapse Button"></td>
                <td style="" title="Click Epand/Collapse Button"></td>
                <td style="" title="Click Epand/Collapse Button"></td>
                <td style="" title="Click Epand/Collapse Button"></td>
            </tr>
            <tr id="childRecord" class="tablesorter-childRow" style="display:none">
                <td style="display:table-cell" ></td>
                <td style="display:table-cell" ></td>
                <td style="display:table-cell"> </td>
                <td style="display:table-cell" ></td>
                <td style="display:table-cell" ><%=Utils.NVL(strain.getBackgroundStrain(),"")%></td>
                <td style="display:table-cell;line-height: 26pt" ><a href="/rgdweb/report/strain/main.html?id=<%=strain.getStrainRgdId()%>"target="_blank"  title="Strain Symbol"><%=strain.getStrainSymbol()%></a></td>
                <td style="width:40px;display:table-cell" title="Alias">
                    <%
                    boolean first = true;
                    if (strain.getAliases()!=null) {
                        for (String alias : strain.getAliases()) {
                            if (first) {
                                out.print(alias);
                                first = false;
                            } else {
                                out.print(";<br>" + alias);
                            }
                        }
                    }
                    %>
                </td>
                <td style="display:table-cell" ><%=strain.getMethod()%></td>
                <td style="display:table-cell" title="Availability"><%=strain.getAvailability()%></td>
                <%if(strain.getOrigination()!=null){%>
                <td class="source" style="display:table-cell" title="Source"><%=strain.getOrigination()%></td>
                <%}else{%>
                <td></td>
                <%}%>
                <% if (strain.getExperimentRecordCount()>0) {%>
                <td style="display:table-cell" ><a href="<%=strain.getPhenominerUrl()%>" target="_blank" style="color:white" title="Phenominer Link"><img src="/rgdweb/common/images/phenominer_icon.png" alt="Phenominer Link" style="width:25px; height: 25px"/></a></td>
                <%} else {%>
                <td></td>
                <% } %>
                <td style="display:table-cell" >
                    <% if (strain.getReferences().size()>0){%>
                        <a href="javascript:void(0)" onclick="myModal('<%=strain.getStrainRgdId()%>')" title="Publications" ><img src="/rgdweb/common/images/nav/Publications.png" alt="Publications" title="Publications"style="width:20px;height:20px"></a>
                    <% } %>
                </td>
<%--                <% if (strain.getSource()!=null && (strain.getSource().contains("physgen") || strain.getSource().contains("gerrc") || strain.getSource().contains("PhysGen")) ) {%>--%>
<%--                        <td style="text-align: center;display:table-cell" title="mcwcustomrats@mcw.edu"><a href="mailto:mcwcustomrats@mcw.edu?subject=<%=strain.getStrainSymbol()%>" ><i class="fa fa-envelope" aria-hidden="true"  style="color:steelblue"></i></a></td>--%>
<%--                <% } else {%>--%>
<%--                        <td></td>--%>
<%--                <% } %>--%>
                <%if(strain.getSource()!=null){%>
                <td class="source" style="display:table-cell" title="Source"><%=strain.getSource()%></td>
                <%}else{%>
                <td></td>
                <%}%>
            </tr>
        <% headerRec=false;}
                        else {%>

            <tr id="childRecord" class="tablesorter-childRow" style="display:none">
                <td style="display:table-cell" ></td>
                <td style="display:table-cell" ></td>
                <td style="display:table-cell"> </td>
                <td style="display:table-cell" ></td>
                <td style="display:table-cell" ><%=Utils.NVL(strain.getBackgroundStrain(),"")%></td>
                <td style="display:table-cell;line-height: 26pt" ><a href="/rgdweb/report/strain/main.html?id=<%=strain.getStrainRgdId()%>"target="_blank"  title="Strain Symbol"><%=strain.getStrainSymbol()%></a></td>
                <td style="width:40px;display:table-cell" title="Alias">
                    <%
                        boolean first = true;
                        if (strain.getAliases() != null) {
                            for (String alias : strain.getAliases()) {
                                if (first) {
                                    out.print(alias);
                                    first = false;
                                } else {
                                    out.print(";<br>" + alias);
                                }
                            }
                        }
                    %>
                </td>
                <td style="display:table-cell" ><%=strain.getMethod()%></td>
                <td style="display:table-cell" title="Availability"><%=strain.getAvailability()%></td>

                <%if(strain.getOrigination()!=null){%>
                <td class="source" style="display:table-cell" title="Source"><%=strain.getOrigination()%></td>
                <%}else{%>
                <td></td>
                <%}%>
                <% if (strain.getExperimentRecordCount()>0) {%>
                <td style="display:table-cell" ><a href="<%=strain.getPhenominerUrl()%>" target="_blank" style="color:white" title="Phenominer Link"><img src="/rgdweb/common/images/phenominer_icon.png" alt="Phenominer Link" style="width:25px; height: 25px"/></a></td>
                <%} else {%>
                <td></td>
                <% } %>
                <td style="display:table-cell" >
                    <% if (strain.getReferences().size()>0){%>
                    <a href="javascript:void(0)" onclick="myModal('<%=strain.getStrainRgdId()%>')" title="Publications" ><img src="/rgdweb/common/images/nav/Publications.png" alt="Publications" title="Publications"style="width:20px;height:20px"></a>
                    <% } %>
                </td>
<%--                <% if (strain.getSource()!=null && (strain.getSource().contains("physgen") || strain.getSource().contains("gerrc") || strain.getSource().contains("PhysGen")) ) {%>--%>
<%--                <td style="text-align: center;display:table-cell" title="mcwcustomrats@mcw.edu"><a href="mailto:mcwcustomrats@mcw.edu?subject=<%=strain.getStrainSymbol()%>" ><i class="fa fa-envelope" aria-hidden="true"  style="color:steelblue"></i></a></td>--%>
<%--                <% } else {%>--%>
<%--                <td></td>--%>
<%--                <% } %>--%>
                <%if(strain.getSource()!=null){%>
                <td class="source" style="display:table-cell" title="Source"><%=strain.getSource()%></td>
                <%}else{%>
                <td></td>
                <%}%>
            </tr>
        <%         }
                    }
//                    i++;
                } // end strains for
            } else {
        for (GeneticModel strain : strains) {
        if (mhr.getGeneSymbol().equals(strain.getGeneSymbol())) {
        %>
            <tr class="header1" style="display:table-row;">
                <td ></td>
                <td  class="geneSymbol"><a href="/rgdweb/report/gene/main.html?id=<%=strain.getGeneRgdId()%>"target="_blank" title="Gene Symbol"><%=mhr.getGeneSymbol()%></a></td>
                <td title="Gene"><%=mhr.getGene()%></td>
                <td style="text-align:center;" title="No. of Models"><%=entry.size()%></td>
                <td style="display:table-cell" ><%=Utils.NVL(strain.getBackgroundStrain(),"")%></td>
                <td style="line-height: 26pt" ><a href="/rgdweb/report/strain/main.html?id=<%=strain.getStrainRgdId()%>"target="_blank"  title="Strain Symbol"><%=strain.getStrainSymbol()%></a></td>
                <td style="width:40px;display:table-cell" title="Alias">
                    <%
                        boolean first = true;
                        if (strain.getAliases()!=null) {
                            for (String alias : strain.getAliases()) {
                                if (first) {
                                    out.print(alias);
                                    first = false;
                                } else {
                                    out.print(";<br>" + alias);
                                }
                            }
                        }
                    %>
                </td>
                <td style="display:table-cell" ><%=strain.getMethod()%></td>
                <td style="display:table-cell" title="Availability"><%=strain.getAvailability()%></td>
                <%if(strain.getOrigination()!=null){%>
                <td class="source" style="display:table-cell;overflow: auto" title="Source"><%=strain.getOrigination()%></td>
                <%}else{%>
                <td></td>
                <%}%>
                <% if (strain.getExperimentRecordCount()>0) {%>
                <td style="display:table-cell" ><a href="<%=strain.getPhenominerUrl()%>" target="_blank" style="color:white" title="Phenominer Link"><img src="/rgdweb/common/images/phenominer_icon.png" alt="Phenominer Link" style="width:25px; height: 25px"/></a></td>
                <%} else {%>
                <td></td>
                <% } %>
                <td style="display:table-cell" >
                    <% if (strain.getReferences().size()>0){%>
                    <a href="javascript:void(0)" onclick="myModal('<%=strain.getStrainRgdId()%>')" title="Publications" ><img src="/rgdweb/common/images/nav/Publications.png" alt="Publications" title="Publications"style="width:20px;height:20px"></a>
                    <% } %>
                </td>
<%--                <% if (strain.getSource()!=null && (strain.getSource().contains("physgen") || strain.getSource().contains("gerrc") || strain.getSource().contains("PhysGen"))) {%>--%>
<%--                <td style="text-align: center;display:table-cell" title="mcwcustomrats@mcw.edu"><a href="mailto:mcwcustomrats@mcw.edu?subject=<%=strain.getStrainSymbol()%>" ><i class="fa fa-envelope" aria-hidden="true"  style="color:steelblue"></i></a></td>--%>
<%--                <% } else {%>--%>
<%--                <td></td>--%>
<%--                <% } %>--%>
                <%if(strain.getSource()!=null){%>
                <td style="display:table-cell"><%=strain.getSource()%></td>
                <%}else{%>
                <td></td>
                <%}%>
            </tr>
        <%} }
            } /* end if entry.size>1*/ } catch (Exception e) {System.out.println(e); }
        } // end for %>

        </tbody>
    </table>

</div>
<div style="background-color:#24609c;width:75%;margin-left:16%">
    <div id="pager1" class="pager" style="float:right;margin-top:2%">
        <form>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
            <input type="text" class="pagedisplay"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>

        </form>
    </div>
</div>
