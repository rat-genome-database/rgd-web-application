package edu.mcw.rgd.nomenclatureinterface;

import edu.mcw.rgd.dao.impl.NomenclatureDAO;
import org.springframework.web.context.support.XmlWebApplicationContext;
import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

import edu.mcw.rgd.web.HttpRequestFacade;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jan 24, 2008
 * Time: 10:56:55 AM
 * <p>
 * Controller class used by the nomenclature interface
 */
public class NomenclatureUpdateController implements Controller {

    SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy");
    ArrayList error;
    ArrayList warning;
    ArrayList status;

    /**
     * Entry point for request
     * <p>
     * This method sets request attributes NomenclatureManager and SearchResult for use
     * by the view jsp.  Need to look at this in the future.  Should be sending this
     * back in ModelAndView object
     *
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        try {
            String path = "/WEB-INF/jsp/curation/nomen/";

            error = new ArrayList();
            warning = new ArrayList();
            status = new ArrayList();

            XmlWebApplicationContext ctx = new XmlWebApplicationContext();
            ctx.setServletContext(request.getSession().getServletContext());
            ctx.refresh();

            NomenclatureManager manager = (edu.mcw.rgd.nomenclatureinterface.NomenclatureManager)
                    (ctx.getBean("nomenclatureManager"));
            request.setAttribute("NomenclatureManager", manager);

            //check request object for updates to nomenclature
            updateGeneNomenclature(request, manager);

            HttpRequestFacade req = new HttpRequestFacade(request);
            String from = req.getParameter("from");
            String to = req.getParameter("to");
            String dateSearch=req.getParameter("dateSearch");
            String keywordSearch=req.getParameter("keywordSearch");
            String keyword = req.getParameter("keyword").toLowerCase();

            int pageNo = 1;
            try {
                pageNo = Integer.parseInt(request.getParameter("pageNo"));
            } catch (Exception e) {
            }

            //run a new search following the update
            if (!keywordSearch.equals("")) {
                keyword = keyword.trim();
                request.setAttribute("SearchResult",manager.findGenesByKeyword(keyword, pageNo, 10));
            } else if (!dateSearch.equals("")) {
                request.setAttribute("SearchResult",manager.findGenesByNomenclatureReviewDate(format.parse(from), format.parse(to), pageNo, 10));
            }else {
                //error.add("Search Type Not Specified");
            }

            SearchResult result = (SearchResult) request.getAttribute("SearchResult");
            if (result != null && result.getTotalCount() == 0 ) {
               status.add("O results returned");
            }

            //set the error and status for this request
            request.setAttribute("error", error);
            request.setAttribute("status", warning);

            String page = request.getRequestURL().substring(request.getRequestURL().lastIndexOf("/") + 1);
            page = page.substring(0, page.indexOf("."));
            return new ModelAndView(path + page + ".jsp");
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
            throw e;
        }
    }

    /**
     * Process form submit from nomenEvents.jsp.  Update nomenclature accordingly
     * 
     * @param request HTTP request
     * @param manager NomenclatureManager object
     * @throws Exception
     */
    private void updateGeneNomenclature(HttpServletRequest request, NomenclatureManager manager) throws Exception{
        if (request.getParameter("c0") != null) {
            int count=0;
            while (request.getParameter("c" + count) != null) {
              String choice = request.getParameter("c" + count);
              String symbol = request.getParameter("symbol" + count);
              String name = request.getParameter("name" + count);
              String review = request.getParameter("reviewDate" + count);
              int rgdId = Integer.parseInt(request.getParameter("rgdId" + count));

              try {
                  if (choice.equals("reject")) {
                      manager.rejectChange(rgdId, format.parse(review));
                  }else if (choice.equals("accept")) {
                      manager.acceptChange(rgdId, name, symbol, NomenclatureDAO.NOMENDATE_REVIEWABLE);
                  }else if (choice.equals("update")) {
                      manager.acceptChange(rgdId, name, symbol, format.parse(review));
                  }
              } catch (Exception e) {
                  error.add(e.getMessage());
                  e.printStackTrace();
              }
             count++;
            }
        }
    }

}
