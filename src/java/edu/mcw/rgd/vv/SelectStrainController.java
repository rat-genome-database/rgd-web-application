package edu.mcw.rgd.vv;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.Sample;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Arrays;
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
        String map=request.getParameter("mapKey");

        if(strainRgdIds!=null ){

            if(!strainRgdIds.equals("")){
                List<Integer> strainIds= new ArrayList<>();
                StringTokenizer tokens= new StringTokenizer(strainRgdIds, ",");
                while (tokens.hasMoreTokens()){
                    strainIds.add(Integer.valueOf(tokens.nextToken()));
                }
               for(int id:strainIds){
                   Sample s= new Sample();
                   s=sampleDAO.getSampleByStrainRgdIdNMapKey(id, Integer.parseInt(map));
                   if(s!=null){
                    System.out.println("sample id:"+ s.getId());
                   sampleList.add(s);}

               }
               if(sampleList.size()==0){

                       sampleList= sampleDAO.getSamplesByMapKey(Integer.parseInt(map));
               }
                if(sampleList.size()>0){
                    request.setAttribute("mapKey",Integer.parseInt(map));
                    request.setAttribute("sampleList", sampleList);
                    return new ModelAndView("/WEB-INF/jsp/vv/select.jsp");
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
       if(mapKey==17) {
            request.setAttribute("sampleList",sampleDAO.getSamplesByMapKey(mapKey, "ClinVar"));
        }
        else
            request.setAttribute("sampleList", sampleDAO.getSamplesByMapKey(mapKey));
        return new ModelAndView("/WEB-INF/jsp/vv/select.jsp");
    }
}
