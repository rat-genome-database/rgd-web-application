package edu.mcw.rgd.edit;


import edu.mcw.rgd.process.FileDownloader;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class CurationLoginController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        if (request.getParameter("code") != null) {
            System.out.println("Got the code");
            String accessToken = getAccessToken(request.getParameter("code"));
            request.setAttribute("accessToken",accessToken);
            System.out.println(accessToken);
            return new ModelAndView("redirect:home.html?accessToken=" + accessToken);
        } else {
            System.out.println("In Login block");
            return new ModelAndView("/WEB-INF/jsp/curation/login.jsp","hello", null);
        }

    }
    public String getAccessToken(String code) throws Exception {
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
}