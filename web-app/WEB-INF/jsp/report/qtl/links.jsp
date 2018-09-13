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
    <td colspan="2"><b>More on <%=obj.getSymbol()%></b></td>
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
            <a href="/jbrowse/?data=data_rgd5&loc=<%=fu.getJBrowseLoc(mdPrev)%>&tracks=AQTLS">rn5</a>
            <% }
                if( fu.mapPosIsValid(md) ){ %>
            <a href="/jbrowse/?data=data_rgd6&loc=<%=fu.getJBrowseLoc(md)%>&tracks=AQTLS">rn6</a>
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
            <a href="/jbrowse/?data=data_hg19&loc=<%=fu.getJBrowseLoc(mdPrev)%>&tracks=AQTLS">hg19</a>
            <% }
                if( fu.mapPosIsValid(md) ){ %>
            <a href="/jbrowse/?data=data_hg38&loc=<%=fu.getJBrowseLoc(md)%>&tracks=AQTLS">hg38</a>
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
            <a href="/jbrowse/?data=data_mm37&loc=<%=fu.getJBrowseLoc(mdPrev)%>&tracks=AQTLS">mm9</a>
            <% }
                if( fu.mapPosIsValid(md) ){ %>
            <a href="/jbrowse/?data=data_mm38&loc=<%=fu.getJBrowseLoc(md)%>&tracks=AQTLS">mm10</a>
            <% } %>
        </td>
    </tr><%
        }
    }
%>

    <tr>
    <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><a href="/tools/qtls/qtlRegistrationIndex.cgi">QTL Registration</a></td>
</tr>
 </table>

<%@ include file="../sectionFooter.jsp"%>
