package edu.mcw.rgd.webservice;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.http.protocol.HTTP;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 9/26/13
 * Time: 12:49 PM
 * To change this template use File | Settings | File Templates.
 */
public class OntologyServiceController implements Controller {

    HttpServletRequest request = null;
    HttpServletResponse response = null;



    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        this.request = httpServletRequest;
        this.response=httpServletResponse;

        //String method = request.getParameter("method");

        //System.out.println(this.getClass());

        System.out.println(request.getParameter("method"));


        Method method = this.getClass().getMethod(request.getParameter("method"));
        method.invoke(this);

        return null;

    }

    public void getChildrenWithRecords() throws Exception {

        PrintWriter out = response.getWriter();

        OntologyXDAO xdao = new OntologyXDAO();
        String t = request.getParameter("terms");

        String[] terms = t.split(",");
        HttpRequestFacade req = new HttpRequestFacade(request);

        PhenominerDAO pdao = new PhenominerDAO();
        List accIds = pdao.getTermIdsAndChildrenWithRecords(terms[0], terms[1], 0);

        Iterator it = accIds.iterator();
        boolean first = true;
        while (it.hasNext()) {
            String acc = (String) it.next();
            if (first) {
                out.print(acc);
                first=false;
            }else {
                out.print("," + acc);
            }
        }

        /*
        for (int i=0; i< terms.length; i++) {

            if (i > 0) {
                out.print(",");
            }

            String term = terms[i];


            String[] termParts = term.split(":");

            String part2 = termParts[1];

            while (part2.length() < 7) {
                part2 = "0" + part2;
            }

            term = termParts[0] + ":" + part2;

            int part2Min = Integer.parseInt(part2);
            String termMin = termParts[0] + ":" + part2Min;

            System.out.println("term = " + term);
            System.out.println("termMin = " + termMin);


            PhenominerDAO pdao = new PhenominerDAO();
         */


               /*
             for (Term t1: xdao.getAllActiveTermDescendants(term)) {

                 String childTerm = t1.getAccId();
                 if (minimize) {
                     termParts = childTerm.split(":");
                     part2 = termParts[1];
                     int childPart2Min = Integer.parseInt(part2);
                     childTerm = termParts[0] + ":" + childPart2Min;
                 }

                 out.print("," + childTerm);
             }
             */

      //  }



    }


}
