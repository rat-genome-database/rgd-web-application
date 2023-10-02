package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.report.GenomeModel.AnnotatedObjectsDAO;
import edu.mcw.rgd.report.GenomeModel.DiseaseObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 * Created by jthota on 11/28/2017.
 */
public class DiseaseGenesController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String term_acc=request.getParameter("accId");
        String map_key= request.getParameter("mapKey");
        String chromosome=request.getParameter("chr");
        AnnotatedObjectsDAO dao= new AnnotatedObjectsDAO();
        int mapKey=0;
        if(map_key!=null){
            mapKey=Integer.parseInt(map_key);
        }
        List<DiseaseObject> objects=dao.getAnnotatedObjects(term_acc, "D", mapKey, chromosome);
     //   System.out.println(chromosome+ "    "+ term_acc + " "+ objects.size()+ "\n=====================================================================");
        for(DiseaseObject o: objects){
    //        System.out.println(o.getGeneRgdId()+"   "+ o.getGeneSymbol() + "    "+ o.getStartPos() + "  "+ o.getStopPos()+ "    "+ o.getStrand());
        }

     //   System.out.println(term_acc + " || " + map_key + " || " + chromosome);

        response.setContentType("application/text");
        response.setHeader( "Content-Disposition", "attachment;filename="+"CHR"+"_" +chromosome + ".tab" );
        response.getWriter().write("RGD_ID\tGENE_SYMBOL\tSTART_POS\tSTOP_POS\tSTRAND\n");
        for(DiseaseObject o:objects){
            response.getWriter().write(o.getGeneRgdId()+"\t"+ o.getGeneSymbol() + "\t"+ o.getStartPos() + "\t"+ o.getStopPos()+ "\t"+ o.getStrand() +"\n");
        }

        return null;
    }
}
