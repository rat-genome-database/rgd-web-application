package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: 2/13/12
 * Time: 2:57 PM
 * To change this template use File | Settings | File Templates.
 */
public class GbrowseTracksAssocController implements Controller {

    ArrayList error = new ArrayList();
    ArrayList warning = new ArrayList();
    ArrayList status = new ArrayList();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        String id  =  req.getParameter("rgd_id");
        String aspect = req.getParameter("aspect");

        String htmlContent = generateAssociation(id, aspect);

        if(htmlContent.equals("")){
            response.getWriter().write("No Annotations Available.");
            return null;
        }else{
            response.getWriter().write(htmlContent);
            return null;
        }
    }


    public String generateAssociation(String acc_id, String asp) throws Exception {


        AnnotationFormatter af = new AnnotationFormatter();
        String content = "";
        AnnotationDAO annotationDAO = new AnnotationDAO();
        List<Annotation> annotList = annotationDAO.getAnnotations(Integer.parseInt(acc_id));

        if (annotList.size() == 0) {
            annotList = annotationDAO.getAnnotationsByReference(Integer.parseInt(acc_id));
        }

        // sort annotations by TERM_ACC, then by EVIDENCE code
        // to enable createGridFormatAnnotations() to group evidence codes properly
        Collections.sort(annotList, new Comparator<Annotation>() {

        public int compare(Annotation o1, Annotation o2) {

            int result = Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            if( result!=0 )
                return result;
                return o1.getEvidence().compareTo(o2.getEvidence());
            }
        });

         if (!acc_id.equals(null)) {
            if(asp.equals("D")){
                List<Annotation> filteredList = af.filterList(annotList, "D");
                if (filteredList.size() > 0){
                    content = af.createGridFormatAnnotations(filteredList, Integer.parseInt(acc_id), 3);
                }
            }
            if(asp.equals("N")){
                List<Annotation> filteredList = af.filterList(annotList, "N");
                if (filteredList.size() > 0){
                    content = af.createGridFormatAnnotations(filteredList, Integer.parseInt(acc_id), 3);
                }
            }
         }
         else {
            throw new Exception("null RGDId: "+acc_id);
         }

         return content;

    }

}
