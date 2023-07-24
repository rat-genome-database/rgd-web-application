package edu.mcw.rgd.security;

import java.util.HashMap;

public class UserManager {

    private static UserManager um= null;
    private HashMap users = new HashMap();
    public static UserManager getInstance() {
        if (um == null) {
            um = new UserManager();
        }
        return um;
    }

 //   public void addUser(String accessToken, HttpServletRequest request) throws Exception{
 //       User u = new User(accessToken,request);
 //       users.put(accessToken,u);

 //   }

    public User getUser(String accessToken) throws Exception{
        return new User(accessToken);
    }

}
