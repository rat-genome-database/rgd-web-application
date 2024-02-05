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

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;


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

        //verify the token
        //https://oauth2.googleapis.com/tokeninfo?id_token=
        /*
        URL url = new URL("https://oauth2.googleapis.com/tokeninfo");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");

        HashMap parameters = new HashMap();
        parameters.put("id_token", "val");

        con.setDoOutput(true);
        DataOutputStream out = new DataOutputStream(con.getOutputStream());
        out.writeBytes("id_token=" + token);
        out.flush();
        out.close();

        BufferedReader in = new BufferedReader(
                new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuffer content = new StringBuffer();
        while ((inputLine = in.readLine()) != null) {
            content.append(inputLine);
        }
        in.close();

        con.disconnect();

        System.out.println(content.toString());
*/
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

        String thisPage = request.getParameter("page");
        if (thisPage != null && thisPage.indexOf("homepage") == -1) {

            response.sendRedirect(thisPage);
            return null;
        }else {

            request.setAttribute("error", errorList);
            request.setAttribute("status", statusList);

            return new ModelAndView("/WEB-INF/jsp/my/account.jsp");
        }
    }
}