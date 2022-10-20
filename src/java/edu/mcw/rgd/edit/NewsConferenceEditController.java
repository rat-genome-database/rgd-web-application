package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;


public class NewsConferenceEditController implements Controller {

    RGDNewsConfDAO newsConfDAO = new RGDNewsConfDAO();
    String login = "";



    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken")) {
                String accessToken = request.getCookies()[0].getValue();
                if(!checkToken(accessToken)) {
                //    response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
                    response.sendRedirect(RgdContext.getGithubOauthRedirectUrl());

                    return null;
                }
            }
        HttpRequestFacade req = new HttpRequestFacade(request);
        RGDNewsConf inserted = createNewRGDNewsConf(req);

        String mod = req.getParameter("modify");

        if(mod.equals("1")) {
//            response.sendRedirect("/WEB-INF/jsp/curation/edit/editNewsArticle.jsp");
            return new ModelAndView("/WEB-INF/jsp/curation/edit/editNewsArticle.jsp");
        }
        else
            return new ModelAndView("/WEB-INF/jsp/curation/edit/editNewsObject.jsp");

    }

    RGDNewsConf createNewRGDNewsConf(HttpRequestFacade req) throws Exception {
        RGDNewsConf newsConf = new RGDNewsConf();

        try {
            newsConf.setDisplayText(req.getParameter("display"));
            newsConf.setContentType(req.getParameter("type"));
            newsConf.setRedirectLink(req.getParameter("hyperlink"));
            newsConf.setStrongText(req.getParameter("strong"));
            String date = req.getParameter("date");
            try {
                Date d1 = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH).parse(date);
                java.sql.Date d2 = new java.sql.Date(d1.getTime());
                newsConf.setDate(d2);
            }
            catch(Exception e){
                newsConf.setDate(null);
            }

            if(newsConf.getDisplayText().isEmpty() || newsConf.getRedirectLink().isEmpty())
                return null;
            else if(newsConf.getDisplayText().equals("0") && newsConf.getRedirectLink().equals("0"))
            {
                return null;
            }
            else{
                if(checkDb(newsConf, req))
                    return null;
                else {
                    newsConfDAO.insertIntoRGDNewsConf(newsConf);
                    return newsConf;
                }
            }
        }
        catch (Exception e){
            return null;
        }
    }

    protected boolean checkToken(String token) throws Exception{
        if(token == null || token.isEmpty()){
            return false;
        }else {
            URL url = new URL("https://api.github.com/user");
            HttpURLConnection conn = (HttpURLConnection)url.openConnection();
            conn.setRequestProperty("User-Agent", "Mozilla/5.0");
            conn.setRequestProperty("Authorization", "Token "+token);

            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream())) ) {
                String line = in.readLine();
                JSONObject json = new JSONObject(line);
                login = (String)json.get("login");
                if(!login.equals("")){
                    URL checkUrl = new URL("https://api.github.com/orgs/rat-genome-database/members/"+login);
                    HttpURLConnection connection = (HttpURLConnection)checkUrl.openConnection();
                    connection.setRequestProperty("User-Agent", "Mozilla/5.0");
                    connection.setRequestProperty("Authorization", "Token "+token);
                    if(connection.getResponseCode()== 204)
                        return true;
                }
            }

            return false;
        }
    }
    public boolean checkDb(RGDNewsConf nc, HttpRequestFacade req) throws Exception{
        String content = req.getParameter("type");
        List<RGDNewsConf> articles = new ArrayList<>();
        if (content.equals("NEWS"))
            articles = newsConfDAO.getAllNews();
        else if (content.equals("CONFERENCE"))
            articles = newsConfDAO.getAllConferences();
        else
            articles = newsConfDAO.getAllVideos();

        for (RGDNewsConf article : articles){
//            if(article.getDisplayText().equals(nc.getDisplayText()))
//                if(article.getRedirectLink().equals(nc.getRedirectLink()))
//                    if(article.getContentType().equals(nc.getContentType()))
//                        if (article.getStrongText().equals(nc.getStrongText()))
//                            blarg = true;
            if (nc.equals(article))
                return true;
        }
        return false;
    }

}
