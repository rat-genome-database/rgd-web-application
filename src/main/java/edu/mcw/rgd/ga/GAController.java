package edu.mcw.rgd.ga;

import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 5/8/12
 * Time: 2:32 PM
 * To change this template use File | Settings | File Templates.
 */
public abstract class GAController implements Controller {

    HttpServletRequest request = null;
    HttpServletResponse response = null;
    HttpRequestFacade req = null;
    int speciesTypeKey=-1;
    List symbols=null;

    protected void init(HttpServletRequest request, HttpServletResponse response) {

        this.request = request;
        this.response = response;
        req=new HttpRequestFacade(request);
        //speciesTypeKey = Integer.parseInt(req.getParameter("species"));


        if (!req.getParameter("species").equals("")) {
            speciesTypeKey = Integer.parseInt(req.getParameter("species"));

        }else {
            if(request.getParameter("mapKey")!=null) {
                int mapKey = Integer.parseInt(request.getParameter("mapKey"));
                speciesTypeKey = SpeciesType.getSpeciesTypeKeyForMap(mapKey);
            }
        }

        if(req.getParameter("genes")!=null) {
            symbols = Utils.symbolSplit(req.getParameter("genes"));
            request.setAttribute("symbols", this.symbols);
        }
    }

    protected ObjectMapper buildMapper(String integerIdType) throws Exception{
        ObjectMapper om = new ObjectMapper();
        om.mapSymbols(symbols, speciesTypeKey, integerIdType);

        if (req.isSet("chr") && req.isSet("start") && req.isSet("stop") && req.isSet("mapKey")) {
            om.mapPosition(req.getParameter("chr"), Integer.parseInt(req.getParameter("start")), Integer.parseInt(req.getParameter("stop")), Integer.parseInt(req.getParameter("mapKey")));
        }

        return om;
    }

}
