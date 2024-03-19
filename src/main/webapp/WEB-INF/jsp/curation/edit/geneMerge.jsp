<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.ontology.Annotation" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.edit.GeneMergeBean" />
<% String headContent = "\n" +
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/common/search.css\">\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/css/ontology.css\">\n";

   String pageTitle = "Gene Merge - Object Edit - Rat Genome Database";
   String pageDescription = pageTitle;
%>
<%@ include file="/common/headerarea.jsp"%>
<style>
    .gmgreen {
        color:green;
        font-weight:bold;
    }
</style>
<div style="margin-left:10px;">
<h2>GENE MERGE TOOL - STEP 1</h2>

<% if( !bean.getRgdIdFrom().getObjectStatus().equals("ACTIVE") ) {
    out.print("<hr><h5>Gene with rgd id "+bean.getRgdIdFrom().getRgdId()+" is "+bean.getRgdIdFrom().getObjectStatus()+"<h5>");
  } else {
%>
<form action="" method="GET">
    <input type="hidden" name="rgdIdFrom" value="<%=bean.getRgdIdFrom().getRgdId()%>"/>
    <input type="hidden" name="rgdIdTo" value="<%=bean.getRgdIdTo().getRgdId()%>"/>
    <input type="hidden" name="action" value="preview" />

<TABLE BORDER="">
    <TR>
        <TH></TH>
        <TH>Merge From (RGD ID:<a href="<%=Link.gene(bean.getRgdIdFrom().getRgdId())%>"><%=bean.getRgdIdFrom().getRgdId()%></a>)</TH>
        <TH>Merge To   (RGD ID:<a href="<%=Link.gene(bean.getRgdIdTo()  .getRgdId())%>"><%=bean.getRgdIdTo()  .getRgdId()%></a>)</TH>
        <TH>New Value</TH>
    </TR>
    <TR>
        <TH colspan="3" style="background-color: #b2d1ff;">GENES</TH>
        <TH><input type="button" value="SWITCH GENES" onclick="document.location.href='/rgdweb/curation/edit/geneMerge.html?rgdIdFrom=<%=bean.getRgdIdTo().getRgdId()%>&rgdIdTo=<%=bean.getRgdIdFrom().getRgdId()%>';return false;" style="background-color: #b2d1ff;font-weight:bold"></TH>
    </TR>
    <TR>
        <TD>Symbol:</TD>
        <TD><%=bean.getGeneFrom().getSymbol()%> [object status:<%=bean.getRgdIdFrom().getObjectStatus()%>]</TD>
        <TD><%=bean.getGeneTo().getSymbol()%> [object status:<%=bean.getRgdIdTo().getObjectStatus()%>]</TD>
        <TD><label for="symbol">Make Alias</label><input type="checkbox" name="symbol" value="<%=bean.getGeneFrom().getSymbol()%>" id="symbol" checked></TD>
    </TR>
    <TR>
        <TD>Name:</TD>
        <TD><%=bean.getGeneFrom().getName()%></TD>
        <TD><%=bean.getGeneTo().getName()%></TD>
        <TD><label for="name">Make Alias</label><input type="checkbox" name="name" value="<%=bean.getGeneFrom().getName()%>" id="name" checked></TD>
    </TR>
    <TR>
        <TD>Gene Type:</TD>
        <TD><%=bean.getGeneFrom().getType()%></TD>
        <TD><%=bean.getGeneTo().getType()%></TD>
        <TD><%=FormUtility.buildSelectDropDown("geneType", bean.getGeneTypes(), bean.getGeneTo().getType())%></TD>
    </TR>

    <TR>
        <TH colspan="3" style="background-color: #b2d1ff;">ALIASES</TH>
    </TR>
    <TR>
        <TH>Type</TH>
        <TH>Value</TH>
        <TH>Notes</TH>
    </TR>
    <%
        // combine new and existing aliases
        List<Alias> aliases = new ArrayList<Alias>(bean.getAliasesInRgd());
        aliases.addAll(bean.getAliasesNew());
        Collections.sort(aliases, new Comparator<Alias>() {
            public int compare(Alias o1, Alias o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getValue(), o2.getValue());
            }
        });
        for( Alias alias: aliases ) {
            boolean isNewAlias = alias.getKey()==0 || alias.getRgdId()==bean.getRgdIdFrom().getRgdId();
    %>
    <TR>
        <TD<%=isNewAlias ? " class=\"gmnew\"" :""%>><%=alias.getTypeName()%></TD>
        <TD<%=isNewAlias ? " class=\"gmnew\"" :""%>><%=alias.getValue()%></TD>
        <TD<%=isNewAlias ? " class=\"gmnew\"" :""%>><%=Utils.defaultString(alias.getNotes())%></TD>
    </TR>
    <% } %>

    <TR>
        <TH colspan="4" style="background-color: #b2d1ff;">NOTES</TH>
    </TR>
    <TR>
        <TH>Note Type</TH>
        <TH>Note Text</TH>
        <TH>Is Public</TH>
    </TR>
    <% // combine all notes; display new notes in red
        List<Note> notes = new ArrayList<Note>(bean.getNotesInRgd());
        notes.addAll(bean.getNotesNew());
        Collections.sort(notes, new Comparator<Note>() {
            public int compare(Note o1, Note o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getNotes(), o2.getNotes());
            }
        });
        for( Note note: notes ) {
            boolean isNew = note.getRgdId()==bean.getRgdIdFrom().getRgdId();
    %>
    <TR>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=note.getNotesTypeName()%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=note.getNotes()%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=note.getPublicYN()%></TD>
    </TR>
    <% } %>

    <TR>
        <TH colspan="4" style="background-color: #b2d1ff;">CURATED REFERENCES</TH>
    </TR>
    <TR>
        <TH>Ref Key</TH>
        <TH>Citation</TH>
        <TH>Ref RGD ID</TH>
    </TR>
    <% // combine all references
        List<Reference> refs = new ArrayList<Reference>(bean.getCuratedRefInRgd());
        refs.addAll(bean.getCuratedRefNew());
        Collections.sort(refs, new Comparator<Reference>() {
            public int compare(Reference o1, Reference o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getCitation(), o2.getCitation());
            }
        });
        for( Reference ref: refs ) {
            boolean isNew = ref.getSpeciesTypeKey()<0;
    %>
    <TR>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=ref.getKey()%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=ref.getCitation()%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=ref.getRgdId()%></TD>
    </TR>
    <% } %>

    <TR>
        <TH colspan="4" style="background-color: #b2d1ff;">MAP DATA</TH>
    </TR>
    <TR>
        <TH>Map</TH>
        <TH>Position</TH>
        <TH>Source</TH>
    </TR>
    <%
        List<MapData> mds = new ArrayList<MapData>(bean.getMapDataInRgd());
        mds.addAll(bean.getMapDataNew());
        Collections.sort(mds, new Comparator<MapData>() {
            public int compare(MapData o1, MapData o2) {
                return o1.getMapKey() - o2.getMapKey();
            }
        });
        for( MapData md: mds ) {
            boolean isNew = bean.getMapDataNew().contains(md);

            Map map = MapManager.getInstance().getMap(md.getMapKey());
            String mapName = map.getName();
            String position = "chr"+Utils.defaultString(md.getChromosome())+": ";
            if( map.getUnit().equals("band") ) // cytomap
                position += Utils.defaultString(md.getFishBand());
            else
            if( map.getUnit().equals("bp") ) // genomic map
                position += Utils.formatThousands(md.getStartPos())+"-"+Utils.formatThousands(md.getStopPos())+" ("+md.getStrand()+")";
            else // genetic map
                position += md.getAbsPosition();
    %>
    <TR>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=mapName%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=position%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=md.getSrcPipeline()%></TD>
    </TR>
    <% } %>

    <TR>
        <TH colspan="4" style="background-color: #b2d1ff;">EXTERNAL DATABASE LINKS</TH>
    </TR>
    <TR>
        <TH>External Db</TH>
        <TH>Acc Id</TH>
        <TH>Src Pipeline</TH>
        <TH>Notes</TH>
    </TR>
    <% // combine all
        List<XdbId> xdbIds = new ArrayList<XdbId>(bean.getXdbidsInRgd());
        xdbIds.addAll(bean.getXdbidsNew());
        Collections.sort(xdbIds, new Comparator<XdbId>() {
            public int compare(XdbId o1, XdbId o2) {
                int r = o1.getXdbKey() - o2.getXdbKey();
                if( r!=0 )
                    return r;
                return Utils.stringsCompareToIgnoreCase(o1.getAccId(), o2.getAccId());
            }
        });
        for( XdbId xdbId: xdbIds ) {
            boolean isNew = xdbId.getRgdId()==bean.getGeneFrom().getRgdId();
    %>
    <TR>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=xdbId.getXdbKeyAsString()%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=xdbId.getAccId()%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=Utils.defaultString(xdbId.getSrcPipeline())%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=Utils.defaultString(xdbId.getNotes())%></TD>
    </TR>
    <% } %>

    <TR>
        <TH colspan="4" style="background-color: #b2d1ff;">NOMENCLATURE EVENTS</TH>
    </TR>
    <TR>
        <TH>Event</TH>
        <TH>Current Info</TH>
        <TH>Previous Info</TH>
        <TH>Notes</TH>
    </TR>
    <% // combine all
        List<NomenclatureEvent> events = new ArrayList<NomenclatureEvent>(bean.getNomenInRgd());
        events.addAll(bean.getNomenNew());
        Collections.sort(events, new Comparator<NomenclatureEvent>() {
            public int compare(NomenclatureEvent o1, NomenclatureEvent o2) {
                return o1.getNomenEventKey() - o2.getNomenEventKey();
            }
        });
        for( NomenclatureEvent ev: events ) {
            boolean isNew = ev.getRgdId()==bean.getGeneFrom().getRgdId();
    %>
    <TR>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>>
            REF_KEY: <%=ev.getRefKey()%><br>
            NOMEN_TYPE: <%=ev.getNomenStatusType()%><br>
            DESC: <%=ev.getDesc()%><br>
            DATE: <%=ev.getEventDate()%>
        </TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>>
            RGD_ID: <%=ev.getRgdId()%><br>
            SYMBOL: <%=ev.getSymbol()%><br>
            NAME: <%=ev.getName()%>
        </TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>>
            RGD_ID: <%=ev.getOriginalRGDId()%><br>
            SYMBOL: <%=ev.getPreviousSymbol()%><br>
            NAME: <%=ev.getPreviousName()%>
        </TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>>
            EVENT_KEY: <%=ev.getNomenEventKey()%><br>
            NOTES: <%=ev.getNotes()%>
        </TD>
    </TR>
    <% } %>

    <TR>
        <TH colspan="4" style="background-color: #b2d1ff;">ANNOTATIONS</TH>
    </TR>
    <TR>
        <TH>Ref Rgd Id<br>Created by<br>Created date</TH>
        <TH>Term<br>Evidence - WithInfo</TH>
        <TH>Data Source - Xref Source</TH>
        <TH>Aspect - Qualifier<br>Notes</TH>
    </TR>
    <% // combine all annotations
        List<Annotation> annots = new ArrayList<Annotation>(bean.getAnnotsInRgd());
        annots.addAll(bean.getAnnotsNew());
        Collections.sort(annots, new Comparator<Annotation>() {
            public int compare(Annotation o1, Annotation o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });
        for( Annotation ann: annots ) {
            boolean isNew = ann.getAnnotatedObjectRgdId()==bean.getGeneFrom().getRgdId();
    %>
    <TR>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=ann.getRefRgdId()%><br><%=ann.getCreatedBy()%><br><%=ann.getCreatedDate()%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=ann.getTermAcc()%>: <%=ann.getTerm()%><br><%=ann.getEvidence()%> - <%=Utils.defaultString(ann.getWithInfo())%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=ann.getDataSrc()%> - <%=ann.getXrefSource()%></TD>
        <TD<%=isNew ? " class=\"gmgreen\"" :""%>><%=ann.getAspect()%> - <%=ann.getQualifier()%><br><%=ann.getNotes()%></TD>
    </TR>
    <% } %>

    <TR>
        <TH colspan="4" align="center"><input type="submit" name="Submit" value="Preview Changes"></TH>
    </TR>
</TABLE>
</form>
<% } %>
</div>
<%@ include file="/common/footerarea.jsp"%>
