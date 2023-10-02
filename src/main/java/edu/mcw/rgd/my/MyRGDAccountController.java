package edu.mcw.rgd.my;

import edu.mcw.rgd.dao.impl.MyDAO;
import edu.mcw.rgd.datamodel.myrgd.MyUser;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.UI;
import edu.mcw.rgd.web.VerifyRecaptcha;
import org.apache.commons.collections4.functors.ExceptionPredicate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
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

    private void checkPassword(String pass1, String pass2) throws Exception {
        if (pass1.length() < 8) {
            throw new Exception("Password must be at least 8 characters");
        }

        if (!pass1.equals(pass2)) {
            throw new Exception("Password 1 and Password 2 do not match");
        }

    }


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        List errorList = new ArrayList();
        List statusList = new ArrayList();
        HttpRequestFacade req = new HttpRequestFacade(request);

try {

    String action = req.getParameter("submit");
    //create account request
    if (action.equals("Create Account")) {

        //need to verify recaptcha response
        String capcha = req.getParameter("g-recaptcha-response");
        if (!VerifyRecaptcha.verify(capcha)) {
            throw new Exception("ReCaptcha Validation Failed.  Please try again.");

        }

        String username = req.getParameter("j_username");

        String pass1 = req.getParameter("pass1");
        String pass2 = req.getParameter("pass2");

        if (!UI.isValidEmailAddress(username)) {
            throw new Exception("A Valid Email Address Is Required");
        }

        this.checkPassword(pass1,pass2);

        MyDAO mdao = new MyDAO();

        if (mdao.myUserExists(username)) {
            throw new Exception("Username " + username + " already exists.  Please select a new username.");
        }


        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

        String encoded = passwordEncoder.encode(pass1);

        MyUser mu = mdao.insertMyUser(username, encoded, true);

        //MyUser mu = mdao.insertMyUser(username, pass1, true);
        mdao.insertMyUserRole(username,"RGD.PUBLIC");
        Authentication auth = new UsernamePasswordAuthenticationToken(username, pass1, mu.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);


    } else if (action.equals("Update Password")) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth.getName().equals("anonymousUser")) {
            return new ModelAndView("/WEB-INF/jsp/my/login.jsp");
        }



            String pass1 = req.getParameter("pass1");
        String pass2 = req.getParameter("pass2");

        this.checkPassword(pass1,pass2);


        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        String encoded = passwordEncoder.encode(pass1);


        MyDAO mdao = new MyDAO();

        mdao.updatePassword(auth.getName(),encoded);

        statusList.add("Password has been updated");

    } else if (action.equals("Create")) {
        return new ModelAndView("/WEB-INF/jsp/my/account.jsp");
    }

} catch(Exception e) {
    errorList.add(e.getMessage());

}

        request.setAttribute("error",errorList);
        request.setAttribute("status",statusList);

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth.getName().equals("anonymousUser")) {
            return new ModelAndView("/WEB-INF/jsp/my/login.jsp");

        }else {
            return new ModelAndView("/WEB-INF/jsp/my/account.jsp");
        }



    }

  
}