package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.RGDNewsConfDAO;
import edu.mcw.rgd.datamodel.RGDNewsConf;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.text.SimpleDateFormat;
import java.util.*;

public class EditNewsArticleController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        RGDNewsConfDAO ndao = new RGDNewsConfDAO();

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        String[] content = request.getParameterValues("contentType");
        List<RGDNewsConf> articles = new ArrayList<>();
        if (content[0].equals("NEWS"))
            articles = ndao.getAllNews();
        else if (content[0].equals("CONFERENCE"))
            articles = ndao.getAllConferences();
        else
            articles = ndao.getAllVideos();

        List<RGDNewsConf> incoming = parseArticles(request, content[0]);
        insertAndDeleteArticles(incoming,articles, ndao);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/editNewsArticle.jsp");
    }

    List<RGDNewsConf> parseArticles(HttpServletRequest request, String content) throws Exception {

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
        String[] displayNames = request.getParameterValues("displayTxt");
        String[] redirectText = request.getParameterValues("redirectLink");
        String[] contentType = request.getParameterValues("contentList");
        String[] strongText = request.getParameterValues("Strong");
        String[] dates = request.getParameterValues("releaseDate");


        int rowCnt = displayNames.length;

        List<RGDNewsConf> current = new ArrayList<RGDNewsConf>(rowCnt);

        for (int i = 0; i < rowCnt; i++) {
            RGDNewsConf nc = new RGDNewsConf();
            nc.setDisplayText(displayNames[i]);
            nc.setRedirectLink(redirectText[i]);
            nc.setContentType(contentType[i]);
            if (strongText[i].isEmpty() || strongText[i].trim().isEmpty())
                nc.setStrongText(null);
            else
                nc.setStrongText(strongText[i]);
            if(dates != null) {
                Date d1 = sdf.parse(dates[i]);
                java.sql.Date d2 = new java.sql.Date(d1.getTime());
                nc.setDate(d2);
            }
            else
                nc.setDate(null);
            current.add(nc);
        }

        return current;
    }
    public void insertAndDeleteArticles(List<RGDNewsConf> incoming, List<RGDNewsConf> inDb, RGDNewsConfDAO ndao) throws Exception{

        Collection<RGDNewsConf> addMe = CollectionUtils.subtract(incoming,inDb);
        Collection<RGDNewsConf> deleteMe = CollectionUtils.subtract(inDb,incoming);
        if(!addMe.isEmpty()){
            for (RGDNewsConf add : addMe){
                ndao.insertIntoRGDNewsConf(add);
            }
        }
        if (!deleteMe.isEmpty()){
            for (RGDNewsConf delete : deleteMe){
                ndao.deleteRGDNewsConf(delete.getNewsId());
            }
        }
        return;

    }
}
