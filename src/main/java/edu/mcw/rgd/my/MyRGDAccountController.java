package edu.mcw.rgd.my;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import com.google.gson.reflect.TypeToken;
import edu.mcw.rgd.dao.impl.MyDAO;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.datamodel.myrgd.MyUser;
import edu.mcw.rgd.security.UserManager;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import java.util.stream.Collectors;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;


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

        String creds = "";
        try {
            String requestData = (String) request.getReader().lines().collect(Collectors.joining());

            Gson gson = new Gson();
            Type type = new TypeToken<HashMap<String, String>>() {
            }.getType();

            HashMap<String, String> map = gson.fromJson(requestData, type);

            creds = map.get("credential");
        }catch (Exception notLogin) {
            request.setAttribute("error", errorList);
            request.setAttribute("status", statusList);

            return new ModelAndView("/WEB-INF/jsp/my/account.jsp");
        }

        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), new GsonFactory())
                // Specify the CLIENT_ID of the app that accesses the backend:
                .setAudience(Collections.singletonList("833037398765-po85dgcbuttu1b1lco2tivl6eaid3471.apps.googleusercontent.com"))
                // Or, if multiple clients access the backend:
                //.setAudience(Arrays.asList(CLIENT_ID_1, CLIENT_ID_2, CLIENT_ID_3))
                .build();

        String email = "";
        GoogleIdToken idToken = verifier.verify(creds);
        if (idToken != null) {
            Payload p = idToken.getPayload();

            // Print user identifier
            String userId = p.getSubject();
            //System.out.println("User ID: " + userId);

            // Get profile information from payload
            email = p.getEmail();
            boolean emailVerified = Boolean.valueOf(p.getEmailVerified());
            String name = (String) p.get("name");
            String pictureUrl = (String) p.get("picture");
            String locale = (String) p.get("locale");
            String familyName = (String) p.get("family_name");
            String givenName = (String) p.get("given_name");

        } else {
            throw new Exception("Invalid ID token.");
        }


        UserManager.getInstance().myLogin(request,email);


        response.getWriter().println("{\"username\":\"" + email + "\"}");

        return null;

    }


}