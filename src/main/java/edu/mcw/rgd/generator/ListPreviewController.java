package edu.mcw.rgd.generator;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.collections4.ListUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class ListPreviewController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);


        return new ModelAndView("/WEB-INF/jsp/generator/preview.jsp");


    }

  
}