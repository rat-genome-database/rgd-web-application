package edu.mcw.rgd.edit;


import edu.mcw.rgd.process.FileDownloader;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;


public class CurationLoginController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        if (request.getParameter("code") != null) {
            String accessToken = getAccessToken(request.getParameter("code"));
            request.setAttribute("accessToken",accessToken);
            if(checkAccess(accessToken))
                return new ModelAndView("redirect:home.html?accessToken=" + accessToken);
            else response.sendRedirect("https://github.com/login/oauth/authorize?client_id=7de10c5ae2c3e3825007&scope=user&redirect_uri=https://dev.rgd.mcw.edu/rgdweb/curation/login.html");
            return null;
        } else {
             response.sendRedirect("https://github.com/login/oauth/authorize?client_id=7de10c5ae2c3e3825007&scope=user&redirect_uri=https://dev.rgd.mcw.edu/rgdweb/curation/login.html");
             return null;
        }

    }
    private String getAccessToken(String code) throws Exception {
        FileDownloader downloader = new FileDownloader();
        downloader.setExternalFile("https://github.com/login/oauth/access_token?client_id=7de10c5ae2c3e3825007&client_secret=0bf648f790ad12f2be1d54dcb0a9f57972289fd0&code="+code);
        downloader.setLocalFile(null);

        String token =downloader.download();
        String[] tokens = token.split("&");
        for(int i = 0; i< tokens.length; i++){
            if(tokens[i].startsWith("access_token")) {
                token = tokens[i].replace("access_token=", "");
            }else if(tokens[i].startsWith("scope"))
                System.out.println(tokens[i]);
        }
        return token;
    }
    private boolean checkAccess(String token) throws Exception{

            URL url = new URL("https://api.github.com/user");
            HttpURLConnection conn = (HttpURLConnection)url.openConnection();
            conn.setRequestProperty("User-Agent", "Mozilla/5.0");
            conn.setRequestProperty("Authorization", "Token "+token);

            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream())) ) {
                String line = in.readLine();
                JSONObject json = new JSONObject(line);
                String login = (String)json.get("login");
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