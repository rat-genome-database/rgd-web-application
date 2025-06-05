package edu.mcw.rgd.report;

import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.web.HttpRequestFacade;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;

import java.io.ByteArrayOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.ArrayList;

/**
 * Buffered ReportController to support Apache mod_cache by setting Content-Length
 */
public abstract class ReportController implements Controller {

    public abstract String getViewUrl() throws Exception;
    public abstract Object getObject(int rgdId) throws Exception;

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        this.request = request;
        this.response = response;

        ArrayList<String> error = new ArrayList<>();
        ArrayList<String> warning = new ArrayList<>();
        ArrayList<String> status = new ArrayList<>();
        String path = "/WEB-INF/jsp/report/";

        HttpRequestFacade req = new HttpRequestFacade(request);

        String strRgdId = req.getParameter("id");
        strRgdId = strRgdId.replaceAll("RGD:", "");
        strRgdId = strRgdId.replaceAll("\\)", "");

        int rgdId = 0;
        Object object = null;

        try {
            rgdId = Integer.parseInt(strRgdId);

            try {
                object = this.getObject(rgdId);
                if (object == null) {
                    error.add("Invalid RGD ID for this type of object!");
                }
            } catch (Exception e) {
                error.add(e.getMessage());
            }
        } catch (Exception e) {
            error.add("RGD ID must be Numeric. Please Search Again.");
        }

        request.setAttribute("reportObject", object);
        request.setAttribute("requestFacade", req);
        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        String jspPath = (error.size() > 0)
                ? "/WEB-INF/jsp/search/searchByPosition.jsp"
                : path + getViewUrl();

        // === Begin buffering logic to set Content-Length ===
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        PrintWriter writer = new PrintWriter(new OutputStreamWriter(buffer, response.getCharacterEncoding()), true);

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
                        // Not needed for synchronous IO
                    }
                };
            }
        };

        // Render the JSP view into the buffer
        RequestDispatcher dispatcher = request.getRequestDispatcher(jspPath);
        dispatcher.include(request, wrappedResponse);

        writer.flush();
        byte[] content = buffer.toByteArray();


        // Set Content-Length and finalize response
        response.setContentLength(content.length);
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Set-Cookie", null);  // removes the header
        // response.getOutputStream().write(content);

        // Return null: response already sent
        return null;
    }
}
