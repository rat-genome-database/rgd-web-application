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

	String agrUrl = null;
    String vistaParams = "";
    switch( obj.getSpeciesTypeKey() ) {
        case SpeciesType.RAT:
            vistaParams = "rn4&run=80";
			agrUrl = XDBIndex.getInstance().getXDB(63).getUrl()+"RGD:"+obj.getRgdId();
            break;
        case SpeciesType.HUMAN:
            vistaParams = "hg19&run=4099";
            break;
        case SpeciesType.MOUSE:
            vistaParams = "mm9&run=80";
            break;
    }

    // choose one NCBI Gene id
    List<XdbId> egIds = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_NCBI_GENE, obj.getRgdId());
    String egUrl = null;
    if( !egIds.isEmpty() ) {
        Xdb xdb = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_NCBI_GENE);
        String url = xdb.getUrl(obj.getSpeciesTypeKey());
        if( url!=null ) {
            egUrl = url + egIds.get(0).getAccId();
        }
    }

    // optional url for MGD ids
    String mgdUrl = null;
    if( obj.getSpeciesTypeKey()==SpeciesType.MOUSE ) {
        List<XdbId> mgdIds = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_MGD, obj.getRgdId());
        if( !mgdIds.isEmpty() ) {
            Xdb xdb = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_MGD);
            String url = xdb.getUrl(obj.getSpeciesTypeKey());
            if( url!=null ) {
                mgdUrl = url + mgdIds.get(0).getAccId();
            }
            agrUrl = XDBIndex.getInstance().getXDB(63).getUrl(SpeciesType.MOUSE)+mgdIds.get(0).getAccId();
        }
    }

    // optional url for HGNC ids
    String hgncUrl = null;
    if( obj.getSpeciesTypeKey()==SpeciesType.HUMAN ) {
        List<XdbId> hgncIds = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_HGNC, obj.getRgdId());
        if( !hgncIds.isEmpty() ) {
            Xdb xdb = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_HGNC);
            String url = xdb.getUrl(obj.getSpeciesTypeKey());
            if( url!=null ) {
                hgncUrl = url + hgncIds.get(0).getAccId();
            }
            agrUrl = XDBIndex.getInstance().getXDB(63).getUrl(SpeciesType.HUMAN)+hgncIds.get(0).getAccId();
        }
    }
%>

<table class="rgdRightColumnBox" width="180" cellpadding="0" cellspacing="0">
    <tr>
        <td colspan="2"><b>More on <%=obj.getSymbol()%></b></td>
    </tr>

    <% if( agrUrl!=null ) { %>
    <tr>
        <td><img src='/rgdweb/common/images/bullet_green.png' alt='' /></td>
        <td><a href="<%=agrUrl%>" title="Alliance of Genome Resources">Alliance Gene</a></td>
    </tr>
    <% } %>

    <% if( egUrl!=null ) { %>
    <tr>
        <td><img src='/rgdweb/common/images/bullet_green.png' alt='' /></td>
        <td><a href="<%=egUrl%>" title="go to NCBI Gene">NCBI Gene</a></td>
    </tr>
    <% } %>

    <tr>
        <td><img src='/rgdweb/common/images/bullet_green.png' alt='' /></td>
        <td><a href="http://useast.ensembl.org/<%=SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey()).replace(" ","_")%>/Location/View?r=<%=md.getChromosome()%>:<%=md.getStartPos()%>-<%=md.getStopPos()%>">Ensembl Gene</a></td>
    </tr>

    <% if( obj.getSpeciesTypeKey()==SpeciesType.RAT ) {
            if( fu.mapPosIsValid(md) || fu.mapPosIsValid(mdPrev) ){ %>
        <tr>
            <td>
                <img src='/rgdweb/common/images/bullet_green.png' alt=''/>
            </td>
            <td>JBrowse:
                <% if( fu.mapPosIsValid(mdPrev) ){ %>
                <a href="/jbrowse/?data=data_rgd5&loc=<%=fu.getJBrowseLoc(mdPrev)%>&tracks=ARGD_curated_genes">rn5</a>
                <% }
                    if( fu.mapPosIsValid(md) ){ %>
                <a href="/jbrowse/?data=data_rgd6&loc=<%=fu.getJBrowseLoc(md)%>&tracks=ARGD_curated_genes">rn6</a>
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
                        <a href="/jbrowse/?data=data_hg19&loc=<%=fu.getJBrowseLoc(mdPrev)%>&tracks=ARGD_curated_genes">hg19</a>
                    <% }
                    if( fu.mapPosIsValid(md) ){ %>
                        <a href="/jbrowse/?data=data_hg38&loc=<%=fu.getJBrowseLoc(md)%>&tracks=ARGD_curated_genes">hg38</a>
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
                <a href="/jbrowse/?data=data_mm37&loc=<%=fu.getJBrowseLoc(mdPrev)%>&tracks=ARGD_curated_genes">mm9</a>
                <% }
                    if( fu.mapPosIsValid(md) ){ %>
                <a href="/jbrowse/?data=data_mm38&loc=<%=fu.getJBrowseLoc(md)%>&tracks=ARGD_curated_genes">mm10</a>
                <% } %>
            </td>
        </tr><%
            }
        }

       if( mgdUrl!=null ) { %>
    <tr>
        <td><img src='/rgdweb/common/images/bullet_green.png' alt='' /></td>
        <td><a href="<%=mgdUrl%>" title="go to MGI">MGI Report</a></td>
    </tr>
    <% }
       if( hgncUrl!=null ) { %>
    <tr>
        <td><img src='/rgdweb/common/images/bullet_green.png' alt='' /></td>
        <td><a href="<%=hgncUrl%>" title="go to HGNC">HGNC Report</a></td>
    </tr>
    <% } %>

    <tr>
        <td><img src='/rgdweb/common/images/bullet_green.png' alt='' /></td>

        <td><!--a href="https://www.ncbi.nlm.nih.gov/mapview/maps.cgi?org=<%--=SpeciesType.getCommonName(obj.getSpeciesTypeKey()).toLowerCase()%>&chr=<%=md.getChromosome()--%>&query=<%--=obj.getSymbol()--%>&maps=gene_set&cmd=focus">NCBI Map Viewer</a-->
            <a href="https://www.ncbi.nlm.nih.gov/genome/gdv/browser/?id=<%=ref_seq_acc_id%>&context=genome&chr=<%=md.getChromosome()%>&q=<%=obj.getSymbol()%>">NCBI Genome Data Viewer</a>
        </td>
    </tr>

    <!--tr>
        <td><img src='/rgdweb/common/images/bullet_green.png' alt='' /></td>
        <td><a href="http://pipeline.lbl.gov/servlet/vgb2/?pos=chr<%--=md.getChromosome()%>:<%=md.getStartPos()%>-<%=md.getStopPos()--%>&scrollbar=1&base=<%--=vistaParams--%>">Vista</a></td>
    </tr>
    <tr>
        <td><img src='/rgdweb/common/images/bullet_green.png' alt='' /></td>
        <td><a href="http://pipeline.lbl.gov/cgi-bin/vistatrack?position=chr<%--=md.getChromosome()--%>:<%--=md.getStartPos()--%>-<%--=md.getStopPos()--%>&db=<%--=vistaParams--%>">Vista + UCSC</a></td>
    </tr-->
 </table>

<%@ include file="../sectionFooter.jsp"%>

