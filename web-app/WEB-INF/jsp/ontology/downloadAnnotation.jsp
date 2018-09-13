<%@ page import="
edu.mcw.rgd.ontology.OntAnnotation,
edu.mcw.rgd.datamodel.ontologyx.Term,
edu.mcw.rgd.datamodel.SpeciesType,
java.util.List,
java.util.Map
"
%><jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntAnnotBean" /><%

    response.setHeader("Content-Type", "text/tab");
    response.setHeader("Content-Disposition","attachment; filename=" + "annotation.tab" );

    out.println("Species\tAccession ID\tTerm\tObject Name\tSymbol\tName\tQualifiers\tEvidence\tChr\tStart\tStop\tReference(s)\tSource(s)\tOriginal Reference(s)\tNotes");

    for( Map.Entry<Term, List<OntAnnotation>> entry: bean.getAnnots().entrySet() ) {
        Term term = entry.getKey();
        for( OntAnnotation annot: entry.getValue() ) {

            String ref = annot.getReference();
            if( ref!=null ) {
                ref = ref.replaceAll("<BR>", ", ");
                ref = ref.replaceAll("\\<[^>]*>", "");
            }

            String xref = annot.getXrefSource();
            if( xref!=null )
                xref = xref.replaceAll("\\<[^>]*>","");

            out.println(SpeciesType.getCommonName(annot.getSpeciesTypeKey()) +"\t" +
                term.getAccId() + "\t" +
                term.getTerm() + "\t" +
                annot.getRgdObjectName() + "\t" +
                annot.getSymbol() + "\t" +
                annot.getName() + "\t" +
                annot.getQualifier().replaceAll("<BR>",",") + "\t" +
                annot.getEvidence().replaceAll("<BR>",",") + "\t" +
                annot.getChr() + "\t" +
                annot.getStartPos() + "\t" +
                annot.getStopPos() + "\t" +
                ref + "\t" +
                annot.getDataSource().replaceAll("<BR>",",") + "\t" +
                xref + "\t" +
                annot.getNotes().replaceAll("<BR>",","));
        }
    }
%>