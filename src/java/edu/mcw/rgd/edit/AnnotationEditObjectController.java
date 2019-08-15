package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.web.HttpRequestFacade;

import javax.servlet.http.HttpServletRequest;
import java.util.Date;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public class AnnotationEditObjectController extends EditObjectController {

    public String getViewUrl() throws Exception {
       return "editAnnotation.jsp";
    }

    public Object getObject(int key) throws Exception{
        return new AnnotationDAO().getAnnotation(key);
    }
    public Object getSubmittedObject(int submissionKey) throws Exception {
       return null;
    }
    public int getObjectTypeKey() {
        return -1;
    }

    public Object newObject() throws Exception{
        return new Annotation();
    }
    
    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);


        AnnotationDAO dao = new AnnotationDAO();
        Annotation annot = dao.getAnnotation(Integer.parseInt(req.getParameter("key")));

        int annotatedObjectId = Integer.parseInt(req.getParameter("annotatedObjectRgdId"));

        Object obj = new RGDManagementDAO().getObject(annotatedObjectId);
        int rgdObjectKey = 0;
        String symbol = "";
        String name = "";

        if (obj instanceof Gene) {
            Gene gene = (Gene) obj;
            symbol = gene.getSymbol();
            name = gene.getName();
            rgdObjectKey = RgdId.OBJECT_KEY_GENES;
        }else if (obj instanceof SSLP) {
            SSLP sslp = (SSLP) obj;
            symbol = "";
            name = sslp.getName();
            rgdObjectKey = RgdId.OBJECT_KEY_SSLPS;
        }else if (obj instanceof Strain) {
            Strain strain = (Strain) obj;
            symbol = strain.getSymbol();
            name = strain.getName();
            rgdObjectKey = RgdId.OBJECT_KEY_STRAINS;
        }else if (obj instanceof QTL) {
            QTL qtl = (QTL) obj;
            symbol = qtl.getSymbol();
            name = qtl.getName();
            rgdObjectKey = RgdId.OBJECT_KEY_QTLS;
        }

        String termAcc = req.getParameter("termAcc");
        Term term = new OntologyXDAO().getTermByAccId(termAcc);

        Integer createdBy = annot.getCreatedBy();


        System.out.println(req.getParameter("act"));

        annot.setTerm(term.getTerm());
        annot.setAnnotatedObjectRgdId(annotatedObjectId);
        annot.setRgdObjectKey(rgdObjectKey);
        annot.setDataSrc(req.getParameter("dataSrc"));
        annot.setObjectSymbol(symbol);
        annot.setWithInfo(req.getParameter("withInfo"));
        annot.setAspect(req.getParameter("aspect"));
        annot.setObjectName(name);
        annot.setNotes(req.getParameter("notes"));
        annot.setQualifier(req.getParameter("qualifier"));
        annot.setRelativeTo(req.getParameter("relativeTo"));

        annot.setLastModifiedDate(new Date());

        annot.setEvidence(req.getParameter("evidence"));
        annot.setTermAcc(termAcc);

        if(createdBy!=null){
            annot.setCreatedBy(createdBy);
        }else{
            annot.setCreatedBy(0);
        }
        if (req.getParameter("lastModifiedBy").length()>0) {
            annot.setLastModifiedBy(Integer.parseInt(req.getParameter(("lastModifiedBy"))));
        }
        annot.setXrefSource(req.getParameter(("xrefSource")));
          if (req.getParameter("act").equals("add")) {
              annot.setRefRgdId(Integer.parseInt(req.getParameter("refRgdId")));
              int key = dao.insertAnnotation(annot);
              annot.setKey(key);
              System.out.println(annot.getKey());
          }
       else {
              annot.setKey(Integer.parseInt(req.getParameter("key")));

              if (req.getParameter("refRgdId").length() > 0) {
                  annot.setRefRgdId(Integer.parseInt(req.getParameter("refRgdId")));
              }
              if (persist) {
                  dao.updateAnnotation(annot);
              }
          }


        return annot;
        }

}