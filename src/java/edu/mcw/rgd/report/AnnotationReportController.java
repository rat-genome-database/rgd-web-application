package edu.mcw.rgd.report;

import edu.mcw.rgd.datamodel.ontology.Annotation;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class AnnotationReportController extends ReportController {

    public String getViewUrl() throws Exception {
       return "annotation/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        //return new AnnotationDAO().getAnnotation(rgdId);
        return new Annotation();
    }
}