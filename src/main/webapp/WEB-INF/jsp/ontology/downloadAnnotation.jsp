<%@ page import="
edu.mcw.rgd.ontology.OntAnnotation,
edu.mcw.rgd.datamodel.ontologyx.Term,
edu.mcw.rgd.datamodel.SpeciesType,
edu.mcw.rgd.datamodel.RgdId,
java.util.List,
java.util.Map,
edu.mcw.rgd.dao.impl.GeneDAO,
edu.mcw.rgd.dao.impl.StrainDAO,
edu.mcw.rgd.dao.impl.VariantInfoDAO"
%><jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntAnnotBean" /><%

    response.setHeader("Content-Type", "text/tab");
    response.setHeader("Content-Disposition","attachment; filename=annotation.tab" );

    out.println("Species\tTerm Accession\tTerm\tObject\tRGD ID\tSymbol\tName\tType\tQualifiers\tEvidence\tChr\tStart\tStop\tReference(s)\tSource(s)\tOriginal Reference(s)\tNotes");

    for( Map.Entry<Term, List<OntAnnotation>> entry: bean.getAnnots().entrySet() ) {
        Term term = entry.getKey();
        for( OntAnnotation annot: entry.getValue() ) {

            String ref = annot.getReference();
            if( ref!=null ) {
                ref = ref.replaceAll("<BR>", ", ");
                ref = ref.replaceAll("\\<[^>]*>", "");
            }

            String xref = annot.getXrefSource();
            String xref2 = annot.getHiddenPmId();
            if( xref!=null ) {
                xref = xref.replaceAll("\\<[^>]*>", "");
                xref2 = xref2.replaceAll("\\<[^>]*>", "");
            }

            String objectType = ""; // per RGDD-1552: [ genes: gene type;  strain: strain type:  clinvar variant: clinical significance ]
            if( annot.isGene() ) {
                GeneDAO gdao = new GeneDAO();
                objectType = gdao.getGene(annot.getRgdId()).getType();
            } else if( annot.isStrain() ) {
                StrainDAO sdao = new StrainDAO();
                objectType = sdao.getStrain(annot.getRgdId()).getStrainTypeName();
            } else if( annot.getRgdObjectKey()==RgdId.OBJECT_KEY_VARIANTS ) {
                VariantInfoDAO vdao = new VariantInfoDAO();
                objectType = vdao.getVariant(annot.getRgdId()).getClinicalSignificance();
            }

            out.println(SpeciesType.getCommonName(annot.getSpeciesTypeKey()) +"\t" +
                term.getAccId() + "\t" +
                term.getTerm() + "\t" +
                annot.getRgdObjectName() + "\t" +
                annot.getRgdId() + "\t" +
                annot.getSymbol() + "\t" +
                annot.getName() + "\t" +
                objectType + "\t" +
                annot.getQualifier().replaceAll("<BR>",",") + "\t" +
                annot.getEvidence().replaceAll("<BR>",",") + "\t" +
                annot.getChr() + "\t" +
                annot.getStartPos() + "\t" +
                annot.getStopPos() + "\t" +
                ref + "\t" +
                annot.getDataSource().replaceAll("<BR>",",") + "\t" +
                xref + " " + xref2 + "\t" +
                annot.getNotes().replaceAll("<BR>",","));
        }
    }
%>