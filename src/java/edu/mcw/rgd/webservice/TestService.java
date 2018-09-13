package edu.mcw.rgd.webservice;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

/**
 * Created by jdepons on 1/14/2016.
 */
@Controller
@RequestMapping("/hello")
public class TestService {

    @RequestMapping(method = RequestMethod.GET)
    public String printHello(ModelMap model) {
        System.out.println("hy;aljasdlkfjalksjdflasdkflajskdfjl");

        model.addAttribute("message", "Hello Spring MVC Framework!");
        return "hello";
    }

}
