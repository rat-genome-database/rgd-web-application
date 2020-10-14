package edu.mcw.rgd.carpenovo;

import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/21/11
 * Time: 9:53 AM
 * To change this template use File | Settings | File Templates.
 */
public class SearchTypeController extends HaplotyperController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        return new ModelAndView("/WEB-INF/jsp/haplotyper/searchType.jsp");
    }
}
