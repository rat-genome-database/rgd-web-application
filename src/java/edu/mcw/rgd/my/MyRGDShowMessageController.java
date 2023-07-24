package edu.mcw.rgd.my;

import edu.mcw.rgd.dao.impl.MyDAO;
import edu.mcw.rgd.datamodel.MessageCenterMessage;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class MyRGDShowMessageController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        List errorList = new ArrayList();
        List statusList = new ArrayList();
        HttpRequestFacade req = new HttpRequestFacade(request);

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth.getName().equals("anonymousUser")) {
            return new ModelAndView("/WEB-INF/jsp/my/login.jsp");
        }

        Integer mid = Integer.parseInt(req.getParameter("mid"));

        MyDAO mdao = new MyDAO();

        List<MessageCenterMessage> messages = mdao.getMessagesFromMessageCenter(mid, auth.getName());

        System.out.println("here 1");

        if (messages.size()==1) {
            //request.setAttribute("message", messages.get(0));
            response.getOutputStream().print(messages.get(0).getMessage());
        }

        request.setAttribute("error",errorList);
        request.setAttribute("status",statusList);

        return null;
        //return new ModelAndView("");

    }

  
}