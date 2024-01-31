package edu.mcw.rgd.my;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import edu.mcw.rgd.dao.impl.MyDAO;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.datamodel.myrgd.MyUser;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class MyRGDAccountController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;



    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        List errorList = new ArrayList();
        List statusList = new ArrayList();
        HttpRequestFacade req = new HttpRequestFacade(request);


        String creds = request.getParameter("credential");
        System.out.println(creds);

        String token = request.getParameter("g_csrf_token");
        System.out.print("<br><br><br>");
        System.out.print(token);

        String[] chunks = creds.split("\\.");

        Base64.Decoder decoder = Base64.getUrlDecoder();

        String header = new String(decoder.decode(chunks[0]));
        String payload = new String(decoder.decode(chunks[1]));

        java.util.Map jsonJavaRootObject = new Gson().fromJson(payload, java.util.Map.class);
        String email = (String) jsonJavaRootObject.get("email");
        Boolean emailVerified = (Boolean) jsonJavaRootObject.get("email_verified");
        String name = (String) jsonJavaRootObject.get("name");
        String picture = (String) jsonJavaRootObject.get("picture");

        System.out.println("email = " + email);
        System.out.println("emailVerified = " + emailVerified);
        System.out.println("name = " + name);
        System.out.println("picture = " + picture);
        System.out.println("<br><br>" + header);
        System.out.println("<br><br>" + payload);

        String username = email;

        MyDAO mdao = new MyDAO();

        if (mdao.myUserExists(username)) {
            request.getSession().setAttribute("user", username);
        } else {
            MyUser mu = mdao.insertMyUser(username, "unused", true);

            //MyUser mu = mdao.insertMyUser(username, pass1, true);
            mdao.insertMyUserRole(username, "RGD.PUBLIC");
            request.getSession().setAttribute("user", username);

        }


        request.setAttribute("error", errorList);
        request.setAttribute("status", statusList);

        return new ModelAndView("/WEB-INF/jsp/my/account.jsp");

    }
}