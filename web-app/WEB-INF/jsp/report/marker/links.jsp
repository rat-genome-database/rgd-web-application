<%@ include file="../sectionHeader.jsp"%>
<%
    MapData mdPrev = null;
    if( obj.getSpeciesTypeKey()==SpeciesType.HUMAN ) {
        List t63List = mapDAO.getMapData(obj.getRgdId(), 17);
        if (t63List.size() > 0) {
            mdPrev = (MapData) t63List.get(0);
        } else {
            mdPrev = new MapData();
        }
    }
    else if( obj.getSpeciesTypeKey()==SpeciesType.RAT ) {
        List t63List = mapDAO.getMapData(obj.getRgdId(), 70);
        if (t63List.size() > 0) {
            mdPrev = (MapData) t63List.get(0);
        } else {
            mdPrev = new MapData();
        }
    }
    else if( obj.getSpeciesTypeKey()==SpeciesType.MOUSE ) {
        List t63List = mapDAO.getMapData(obj.getRgdId(), 18);
        if (t63List.size() > 0) {
            mdPrev = (MapData) t63List.get(0);
        } else {
            mdPrev = new MapData();
        }
    }
%>

<table class="rgdRightColumnBox" width="180" cellpadding="0" cellspacing="0">
<tr>
    <td colspan="2"><b>More on <%=obj.getName()%></b></td>
</tr>
<%
    if( obj.getSpeciesTypeKey()==SpeciesType.RAT ) {
        if( fu.mapPosIsValid(md) || fu.mapPosIsValid(mdPrev) ){ %>
    <tr>
        <td>
            <img src='/rgdweb/common/images/bullet_green.png' alt=''/>
        </td>
        <td>JBrowse:
            <% if( fu.mapPosIsValid(mdPrev) ){ %>
            <a href="https://jbrowse.rgd.mcw.edu/?data=data_rgd5&loc=<%=fu.getJBrowseLoc(mdPrev)%>&tracks=SSLP">rn5</a>
            <% }
                if( fu.mapPosIsValid(md) ){ %>
            <a href="https://jbrowse.rgd.mcw.edu/?data=data_rgd6&loc=<%=fu.getJBrowseLoc(md)%>&tracks=SSLP">rn6</a>
            <% } %>
        </td>
    </tr>
    <%
        }
    }
    else
    if(obj.getSpeciesTypeKey()==SpeciesType.HUMAN ){
        if( fu.mapPosIsValid(md) || fu.mapPosIsValid(mdPrev) ){ %>
    <tr>
        <td>
            <img src='/rgdweb/common/images/bullet_green.png' alt=''/>
        </td>
        <td>JBrowse:
            <% if( fu.mapPosIsValid(mdPrev) ){ %>
            <a href="https://jbrowse.rgd.mcw.edu/jbrowse/?data=data_hg19&loc=<%=fu.getJBrowseLoc(mdPrev)%>&tracks=SSLP">hg19</a>
            <% }
                if( fu.mapPosIsValid(md) ){ %>
            <a href="https://jbrowse.rgd.mcw.edu/jbrowse/?data=data_hg38&loc=<%=fu.getJBrowseLoc(md)%>&tracks=SSLP">hg38</a>
            <% } %>
        </td>
    </tr><%
    }
}
else
if(obj.getSpeciesTypeKey()==SpeciesType.MOUSE ){
    if( fu.mapPosIsValid(md) || fu.mapPosIsValid(mdPrev) ){ %>
    <tr>
        <td>
            <img src='/rgdweb/common/images/bullet_green.png' alt=''/>
        </td>
        <td>JBrowse:
            <% if( fu.mapPosIsValid(mdPrev) ){ %>
            <a href="https://jbrowse.rgd.mcw.edu/?data=data_mm37&loc=<%=fu.getJBrowseLoc(mdPrev)%>&tracks=SSLP">mm9</a>
            <% }
                if( fu.mapPosIsValid(md) ){ %>
            <a href="https://jbrowse.rgd.mcw.edu/?data=data_mm38&loc=<%=fu.getJBrowseLoc(md)%>&tracks=SSLP">mm10</a>
            <% } %>
        </td>
    </tr><%
        }
    }
%>

<% if( fu.mapPosIsValid(md) ) { %>
<tr>
    <td><img src='/rgdweb/common/images/bullet_green.png' alt=''/></td><td><a href="http://useast.ensembl.org/<%=SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey()).replace(" ","_")%>/Location/View?r=<%=md.getChromosome()%>:<%=md.getStartPos()%>-<%=md.getStopPos()%>">Ensembl</a></td>
</tr>
<tr>
    <td><img src='/rgdweb/common/images/bullet_green.png' alt=''/></td><td><a href="https://www.ncbi.nlm.nih.gov/mapview/maps.cgi?taxid=10116&chr=<%=md.getChromosome()%>&MAPS=sts,genes&cmd=focus&query=<%=obj.getName()%>">NCBI</a></td>
</tr>
<% } %>
</table>

<%@ include file="../sectionFooter.jsp"%>
