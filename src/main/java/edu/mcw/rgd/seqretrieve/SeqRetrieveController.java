package edu.mcw.rgd.seqretrieve;

import edu.mcw.rgd.process.FastaParser;
import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;

public class SeqRetrieveController implements Controller{

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/seqretrieve/retrieve.jsp");

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        // PARAM format {'html','text'}
        //  'text' - return fast sequence as 'text/plain'
        //  'html' - return fast sequence as 'text/html'
        String format = Utils.defaultString(request.getParameter("format"));

        // validate mapKey parameter
        String mapKeyStr = Utils.defaultString(request.getParameter("mapKey"));
        if( Utils.isStringEmpty(mapKeyStr) ) {
            // initial page load (no form submitted yet) -- just show the empty form
            if( request.getParameterMap().isEmpty() ) {
                return mv;
            }
            error.add("ERROR: missing mapKey parameter");
            return mv;
        }
        int mapKey = Integer.parseInt(mapKeyStr);

        FastaParser parser = new FastaParser();
        parser.setMapKey(mapKey);
        if( parser.getLastError()!=null ) {
            error.add(parser.getLastError());
            return mv;
        }

        parser.setChr(Utils.defaultString(request.getParameter("chr")));

        int startPos = Integer.parseInt(Utils.defaultString(request.getParameter("startPos")));
        int stopPos = Integer.parseInt(Utils.defaultString(request.getParameter("stopPos")));

        String fasta = parser.getSequence(startPos, stopPos);
        if( parser.getLastError()!=null ) {
            error.add(parser.getLastError());
        }
        if( fasta == null ) {
            return mv;
        }

        if( format.equals("text") ) {
            // return string of raw nucleotides
            String fastaNormalized = fasta.replaceAll("[\\s]","");
            response.setContentType("text/plain");
            response.setContentLength(fastaNormalized.length());
            response.getOutputStream().print(fastaNormalized);
            return null;
        } else {
            mv.addObject("mapKey", mapKey);
            mv.addObject("chr", parser.getChr());
            mv.addObject("startPos", startPos);
            mv.addObject("stopPos", stopPos);
            mv.addObject("fasta", fasta);
            return mv;
        }
    }
}
