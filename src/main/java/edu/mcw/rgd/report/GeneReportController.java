package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GeneDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;
import org.springframework.web.servlet.ModelAndView;

import java.io.ByteArrayOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

/**
 * GeneReportController — renders JSP with buffered response to enable Apache mod_cache to store output.
 */
public class GeneReportController extends ReportController {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        // Parse RGD ID and fetch data
        int rgdId = Integer.parseInt(request.getParameter("id"));
        Object gene = getObject(rgdId);
        request.setAttribute("gene", gene);

        // Resolve JSP path
        String jspPath = "/WEB-INF/jsp/" + getViewUrl();

        // Buffer output to memory
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        PrintWriter writer = new PrintWriter(new OutputStreamWriter(buffer, response.getCharacterEncoding()), true);

        // Wrap the response to intercept output
        HttpServletResponseWrapper wrappedResponse = new HttpServletResponseWrapper(response) {
            @Override
            public PrintWriter getWriter() {
                return writer;
            }

            @Override
            public ServletOutputStream getOutputStream() {
                return new ServletOutputStream() {
                    @Override
                    public void write(int b) {
                        buffer.write(b);
                    }

                    @Override
                    public boolean isReady() {
                        return true;
                    }

                    @Override
                    public void setWriteListener(WriteListener listener) {
                        // Not used
                    }
                };
            }
        };

        // Forward JSP to wrapped response
        RequestDispatcher dispatcher = request.getRequestDispatcher(jspPath);
        dispatcher.include(request, wrappedResponse);

        writer.flush();
        byte[] content = buffer.toByteArray();

        // Finalize and send response
        response.setContentLength(content.length);
        response.setContentType("text/html;charset=UTF-8");
        response.getOutputStream().write(content);

        // We handled the response directly
        return null;
    }

    public String getViewUrl() {
        return "gene/main.jsp";
    }

    public Object getObject(int rgdId) throws Exception {
        return new GeneDAO().getGene(rgdId);
    }
}
