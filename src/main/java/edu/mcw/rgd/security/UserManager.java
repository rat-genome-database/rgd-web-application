package edu.mcw.rgd.security;

import edu.mcw.rgd.dao.impl.MyDAO;
import edu.mcw.rgd.datamodel.myrgd.MyUser;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.util.HashMap;

public class UserManager {

    private static UserManager um= null;
    private HashMap users = new HashMap();
    private MyDAO mdao = new MyDAO();
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

    public MyUser myLogin(HttpServletRequest request, String username) throws Exception{
        MyUser user = null;
        if (mdao.myUserExists(username)) {
            user = mdao.getMyUser(username);
            request.getSession().setAttribute("myUser", user);
            return user;
        } else {
            MyUser mu = mdao.insertMyUser(username, "unused", true);

            //MyUser mu = mdao.insertMyUser(username, pass1, true);
            mdao.insertMyUserRole(username, "RGD.PUBLIC");
            request.getSession().setAttribute("myUser", mu);
            return user;
        }


    }
    public void myLogout(HttpServletRequest request) {
        request.getSession().setAttribute("myUser", null);
    }
    public MyUser getMyUser(HttpServletRequest request) {
        return (MyUser) request.getSession().getAttribute("myUser");
    }

}
