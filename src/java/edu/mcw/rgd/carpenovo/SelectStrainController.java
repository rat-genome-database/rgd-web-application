package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.Sample;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.StringTokenizer;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/25/11
 * Time: 10:32 AM
 * <p>
 * Controller class for the strain selection screen
 */
public class SelectStrainController extends HaplotyperController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        SampleDAO sampleDAO = new SampleDAO();
        sampleDAO.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
        List<Sample> sampleList= new ArrayList<>();
        String strainRgdIds=request.getParameter("rgdIds");

        if(strainRgdIds!=null){
            if(strainRgdIds!=""){
                List<Integer> strainIds= new ArrayList<>();
                StringTokenizer tokens= new StringTokenizer(strainRgdIds, ",");
                while (tokens.hasMoreTokens()){
                    strainIds.add(Integer.valueOf(tokens.nextToken()));
                }
               for(int id:strainIds){
                   Sample s= new Sample();
                   s=sampleDAO.getSampleByStrainRgdId(id, 600);
                   if(s!=null){
                    System.out.println("sample id:"+ s.getId());
                   sampleList.add(s);}
                   else{
                       System.out.println("No Samples");
                  }
               }
                if(sampleList.size()>0){
                    request.setAttribute("mapKey",360);
                    request.setAttribute("sampleList", sampleList);
                    return new ModelAndView("/WEB-INF/jsp/haplotyper/select.jsp");
                }else{
                    return null;
                }
            }
        }


        int mapKey = 60;

        try {
            mapKey = Integer.parseInt(request.getParameter("mapKey"));
        }catch (Exception ignored) {
        }
        request.setAttribute("mapKey", mapKey);

		request.setAttribute("sampleList", sampleDAO.getSamplesByMapKey(mapKey));

        return new ModelAndView("/WEB-INF/jsp/haplotyper/select.jsp");
    }
}
