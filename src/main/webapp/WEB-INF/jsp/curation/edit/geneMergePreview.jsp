<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.ontology.Annotation" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.edit.GeneMergeBean" />
<% String headContent = "\n" +
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/common/search.css\">\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/css/ontology.css\">\n";

   String pageTitle = "Gene Merge Preview - Object Edit - Rat Genome Database";
   String pageDescription = pageTitle;
%>
<%@ include file="/common/headerarea.jsp"%>
<style>
    .gminrgd {
        color: black;
        font-weight: normal;
    }
    .gmnew {
        color: green;
        font-weight: bold;
    }
    .gmignored {
        color: red;
        font-weight: bold;
        text-decoration: line-through;
    }
</style>
<div style="margin-left:10px;">
<h2>GENE MERGE TOOL - STEP 2 - PREVIEW </h2>

<form action="" method="GET">
    <input type="hidden" name="rgdIdFrom" value="<%=bean.getRgdIdFrom().getRgdId()%>"/>
    <input type="hidden" name="rgdIdTo" value="<%=bean.getRgdIdTo().getRgdId()%>"/>
    <input type="hidden" name="action" value="commit" />

<TABLE BORDER="">
    <TR>
        <TH></TH>
        <TH>Merge From (RGD ID:<%=bean.getRgdIdFrom().getRgdId()%>)</TH>
        <TH>Merge To (RGD ID:<%=bean.getRgdIdTo().getRgdId()%>)</TH>
    </TR>
    <TR>
        <TH colspan="3" style="background-color: #b2d1ff;">GENES</TH>
    </TR>
    <TR>
        <TD>Symbol:</TD>
        <TD><%=bean.getGeneFrom().getSymbol()%> [object status:<%=bean.getRgdIdFrom().getObjectStatus()%>]</TD>
        <TD><%=bean.getGeneTo().getSymbol()%> [object status:<%=bean.getRgdIdTo().getObjectStatus()%>]</TD>
    </TR>
    <TR>
        <TD>Name:</TD>
        <TD><%=bean.getGeneFrom().getName()%></TD>
        <TD><%=bean.getGeneTo().getName()%></TD>
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
            boolean isNew = alias.getKey()==0 || alias.getRgdId()==bean.getRgdIdFrom().getRgdId();
            boolean isIgnored = isNew && bean.getAliasesNewIgnored().contains(alias);
            String aClass = isIgnored ? "gmignored" : isNew ? "gmnew" : "gminrgd";
    %>
    <TR>
        <TD class="<%=aClass%>"><%=alias.getTypeName()%></TD>
        <TD class="<%=aClass%>"><%=alias.getValue()%></TD>
        <TD class="<%=aClass%>"><%=Utils.defaultString(alias.getNotes())%></TD>
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
        notes.addAll(bean.getNotesNewIgnored());
        Collections.sort(notes, new Comparator<Note>() {
            public int compare(Note o1, Note o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getNotes(), o2.getNotes());
            }
        });
        for( Note note: notes ) {
            boolean isNewNote = note.getRgdId()==bean.getRgdIdFrom().getRgdId();
            boolean isIgnored = isNewNote && bean.getNotesNewIgnored().contains(note);
            String noteClass = isIgnored ? "gmignored" : isNewNote ? "gmnew" : "gminrgd";
    %>
    <TR>
        <TD class="<%=noteClass%>"><%=note.getNotesTypeName()%></TD>
        <TD class="<%=noteClass%>"><%=note.getNotes()%></TD>
        <TD class="<%=noteClass%>"><%=note.getPublicYN()%></TD>
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
        refs.addAll(bean.getCuratedRefIgnored());
        Collections.sort(refs, new Comparator<Reference>() {
            public int compare(Reference o1, Reference o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getCitation(), o2.getCitation());
            }
        });
        for( Reference ref: refs ) {
            boolean isNew = ref.getSpeciesTypeKey()<0;
            boolean isIgnored = isNew && bean.getCuratedRefIgnored().contains(ref);
            String refClass = isIgnored ? "gmignored" : isNew ? "gmnew" : "gminrgd";
    %>
    <TR>
        <TD class="<%=refClass%>"><%=ref.getKey()%></TD>
        <TD class="<%=refClass%>"><%=ref.getCitation()%></TD>
        <TD class="<%=refClass%>"><%=ref.getRgdId()%></TD>
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
        mds.addAll(bean.getMapDataIgnored());
        Collections.sort(mds, new Comparator<MapData>() {
            public int compare(MapData o1, MapData o2) {
                return o1.getMapKey() - o2.getMapKey();
            }
        });
        for( MapData md: mds ) {
            boolean isNew = bean.getMapDataNew().contains(md);
            boolean isIgnored = isNew && bean.getMapDataIgnored().contains(md);
            String mdClass = isIgnored ? "gmignored" : isNew ? "gmnew" : "gminrgd";

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
        <TD class="<%=mdClass%>"><%=mapName%></TD>
        <TD class="<%=mdClass%>"><%=position%></TD>
        <TD class="<%=mdClass%>"><%=md.getSrcPipeline()%></TD>
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
        xdbIds.addAll(bean.getXdbidsIgnored());
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
            boolean isIgnored = isNew && bean.getXdbidsIgnored().contains(xdbId);
            String xdbClass = isIgnored ? "gmignored" : isNew ? "gmnew" : "gminrgd";
    %>
    <TR>
        <TD class="<%=xdbClass%>"><%=xdbId.getXdbKeyAsString()%></TD>
        <TD class="<%=xdbClass%>"><%=xdbId.getAccId()%></TD>
        <TD class="<%=xdbClass%>"><%=Utils.defaultString(xdbId.getSrcPipeline())%></TD>
        <TD class="<%=xdbClass%>"><%=Utils.defaultString(xdbId.getNotes())%></TD>
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
        events.addAll(bean.getNomenIgnored());
        Collections.sort(events, new Comparator<NomenclatureEvent>() {
            public int compare(NomenclatureEvent o1, NomenclatureEvent o2) {
                return o1.getNomenEventKey() - o2.getNomenEventKey();
            }
        });
        for( NomenclatureEvent ev: events ) {
            boolean isNew = ev.getRgdId()==bean.getGeneFrom().getRgdId();
            boolean isIgnored = isNew && bean.getNomenIgnored().contains(ev);
            String nomClass = isIgnored ? "gmignored" : isNew ? "gmnew" : "gminrgd";
    %>
    <TR>
        <TD class="<%=nomClass%>">
            REF_KEY: <%=ev.getRefKey()%><br>
            NOMEN_TYPE: <%=ev.getNomenStatusType()%><br>
            DESC: <%=ev.getDesc()%><br>
            DATE: <%=ev.getEventDate()%>
        </TD>
        <TD class="<%=nomClass%>">
            RGD_ID: <%=ev.getRgdId()%><br>
            SYMBOL: <%=ev.getSymbol()%><br>
            NAME: <%=ev.getName()%>
        </TD>
        <TD class="<%=nomClass%>">
            RGD_ID: <%=ev.getOriginalRGDId()%><br>
            SYMBOL: <%=ev.getPreviousSymbol()%><br>
            NAME: <%=ev.getPreviousName()%>
        </TD>
        <TD class="<%=nomClass%>">
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
        annots.addAll(bean.getAnnotsIgnored());
        Collections.sort(annots, new Comparator<Annotation>() {
            public int compare(Annotation o1, Annotation o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });
        for( Annotation ann: annots ) {
            boolean isNew = ann.getAnnotatedObjectRgdId()==bean.getGeneFrom().getRgdId();
            boolean isIgnored = isNew && bean.getAnnotsIgnored().contains(ann);
            String annClass = isIgnored ? "gmignored" : isNew ? "gmnew" : "gminrgd";
    %>
    <TR>
        <TD class="<%=annClass%>"><%=ann.getRefRgdId()%><br><%=ann.getCreatedBy()%><br><%=ann.getCreatedDate()%></TD>
        <TD class="<%=annClass%>"><%=ann.getTermAcc()%>: <%=ann.getTerm()%><br><%=ann.getEvidence()%> - <%=Utils.defaultString(ann.getWithInfo())%></TD>
        <TD class="<%=annClass%>"><%=ann.getDataSrc()%> - <%=ann.getXrefSource()%></TD>
        <TD class="<%=annClass%>"><%=ann.getAspect()%> - <%=ann.getQualifier()%><br><%=ann.getNotes()%></TD>
    </TR>
    <% } %>

    <TR>
        <TH colspan="4" align="center"><input type="submit" name="Submit" value="Commit Changes"></TH>
    </TR>
</TABLE>
</form>
</div>
<%@ include file="/common/footerarea.jsp"%>
