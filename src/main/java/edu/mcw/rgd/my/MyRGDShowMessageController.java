package edu.mcw.rgd.my;

import edu.mcw.rgd.dao.impl.MyDAO;
import edu.mcw.rgd.datamodel.MessageCenterMessage;
import edu.mcw.rgd.datamodel.myrgd.MyUser;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.UI;
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
public class MyRGDShowMessageController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        List errorList = new ArrayList();
        List statusList = new ArrayList();
        HttpRequestFacade req = new HttpRequestFacade(request);

        String user = (String) request.getSession().getAttribute("user");

        if (user.equals("anonymousUser")) {
            return new ModelAndView("/WEB-INF/jsp/my/login.jsp");
        }

        Integer mid = Integer.parseInt(req.getParameter("mid"));

        MyDAO mdao = new MyDAO();

        List<MessageCenterMessage> messages = mdao.getMessagesFromMessageCenter(mid, user);

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