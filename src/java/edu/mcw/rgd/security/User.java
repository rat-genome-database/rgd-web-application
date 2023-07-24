package edu.mcw.rgd.security;

import org.json.JSONObject;

import javax.servlet.http.HttpServletRequest;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

public class User {

    private String username;
    private String accessToken;

    public User(String accessToken) throws Exception{
        this.authenticate(accessToken);
    }

    private void authenticate(String accessToken) throws Exception{
        this.accessToken = accessToken;


        URL myURL = new URL("https://api.github.com/user");
        URLConnection connection = myURL.openConnection();

        connection.setRequestProperty("Authorization","Token " + accessToken);
        InputStream is = connection.getInputStream();
        BufferedReader br = new BufferedReader(new InputStreamReader(is));

        String line="";
        String jsonString= "";
        while ((line=br.readLine()) !=null) {
            jsonString+=line;
        }

        JSONObject obj = new JSONObject(jsonString);
        this.username = (String) obj.get("login");

    }

    public String getUsername() {
        return username;
    }

    public String getAccessToken() {
        return accessToken;
    }

}
