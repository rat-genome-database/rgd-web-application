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
%>
<%@ page import="edu.mcw.rgd.dao.impl.QTLDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.QTL" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntAnnotBean" /><%

    response.setHeader("Content-Type", "text/tab");
    response.setHeader("Content-Disposition","attachment; filename=annotation.tab" );
    if(bean.getObjectKey()==6){
        out.println("Species\tTerm Accession\tTerm\tObject\tRGD ID\tSymbol\tName\tType\tQualifiers\tEvidence\tP Value\tLOD Score\tChr\tStart\tStop\tReference(s)\tSource(s)\tOriginal Reference(s)\tNotes");
    }
    else {
        out.println("Species\tTerm Accession\tTerm\tObject\tRGD ID\tSymbol\tName\tType\tQualifiers\tEvidence\tChr\tStart\tStop\tReference(s)\tSource(s)\tOriginal Reference(s)\tNotes");
    }
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
                var variant = vdao.getVariant(annot.getRgdId());
                if (variant != null) {
                    objectType = variant.getClinicalSignificance();
                } else {
                    objectType = "";
                }
//                System.out.println(annot.getRgdId());
//                objectType = vdao.getVariant(annot.getRgdId()).getClinicalSignificance();
            }

            StringBuilder sb = new StringBuilder();
            sb.append(SpeciesType.getCommonName(annot.getSpeciesTypeKey())).append("\t")
                    .append(term.getAccId()).append("\t")
                    .append(term.getTerm()).append("\t")
                    .append(annot.getRgdObjectName()).append("\t")
                    .append(annot.getRgdId()).append("\t")
                    .append(annot.getSymbol()).append("\t")
                    .append(annot.getName()).append("\t")
                    .append(objectType).append("\t")
                    .append(annot.getQualifier().replaceAll("<BR>",",")).append("\t")
                    .append(annot.getEvidence().replaceAll("<BR>",",")).append("\t");

            // Add P Value and LOD score for QTLs
            if(bean.getObjectKey()==6) {
                try {
                    QTL qtl = new QTLDAO().getQTL(annot.getRgdId());
                    String pValueStr = "";

                    if ((qtl.getPValue() == null || qtl.getPValue() == 0) && qtl.getpValueMlog() != null) {
                        double w = qtl.getpValueMlog();
                        int x = (int) Math.ceil(w);
                        double y = x - w;
                        int z = (int) Math.round(Math.pow(10, y));
                        pValueStr = z + "E-" + x;
                    } else {
                        pValueStr = qtl.getPValue() != null ? qtl.getPValue().toString() : "";
                    }

                    sb.append(pValueStr).append("\t")
                            .append(qtl.getLod() != null ? qtl.getLod().toString() : "").append("\t");
                } catch (Exception e) {
                    sb.append("\t\t");
                }
            }

            sb.append(annot.getChr()).append("\t")
                    .append(annot.getStartPos()).append("\t")
                    .append(annot.getStopPos()).append("\t")
                    .append(ref).append("\t")
                    .append(annot.getDataSource().replaceAll("<BR>",",")).append("\t")
                    .append(xref).append(" ").append(xref2).append("\t")
                    .append(annot.getNotes().replaceAll("<BR>",","));

            out.println(sb.toString());
//            out.println(SpeciesType.getCommonName(annot.getSpeciesTypeKey()) +"\t" +
//                term.getAccId() + "\t" +
//                term.getTerm() + "\t" +
//                annot.getRgdObjectName() + "\t" +
//                annot.getRgdId() + "\t" +
//                annot.getSymbol() + "\t" +
//                annot.getName() + "\t" +
//                objectType + "\t" +
//                annot.getQualifier().replaceAll("<BR>",",") + "\t" +
//                annot.getEvidence().replaceAll("<BR>",",") + "\t" +
//                annot.getChr() + "\t" +
//                annot.getStartPos() + "\t" +
//                annot.getStopPos() + "\t" +
//                ref + "\t" +
//                annot.getDataSource().replaceAll("<BR>",",") + "\t" +
//                xref + " " + xref2 + "\t" +
//                annot.getNotes().replaceAll("<BR>",","));
        }
    }
%>