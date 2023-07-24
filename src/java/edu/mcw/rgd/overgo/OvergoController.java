package edu.mcw.rgd.overgo;

import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class OvergoController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        HttpRequestFacade req = new HttpRequestFacade(request);

        List<OligoSpawnRequest> oligoSpawnRequests = new ArrayList();

        try {

            String workDirectory = "/rgd/data/overgo/";
            File unixFile = new File(workDirectory);
            File winFile = new File("c:/rgd/data/overgo");

            if (new File(workDirectory).exists()) {

            } else if (new File("c:/" + workDirectory).exists()) {
                workDirectory = "c:/" + workDirectory;
            } else {
                throw new Exception("Can't find file /rgd/data/overgo or c:/rgd/data/overgo");
            }


            workDirectory = workDirectory + "/" + new Date().getTime();
            new File(workDirectory).mkdirs();
            new File(workDirectory + "/in").mkdirs();
            new File(workDirectory + "/out").mkdirs();

//            if (ServletFileUpload.isMultipartContent(request)) {
//                // Create a factory for disk-based file items
//                FileItemFactory factory = new DiskFileItemFactory();
//
//                // Create a new file upload handler
//                ServletFileUpload upload = new ServletFileUpload(factory);
//
//                // Parse the request
//                List items = upload.parseRequest(request);
//
//                // Process the uploaded items
//
//                int contigSize = 25000;
//                List options = new ArrayList();
//                File uploadedFile = null;
//
//                Iterator iter = items.iterator();
//                while (iter.hasNext()) {
//                    FileItem item = (FileItem) iter.next();
//
//                    if (item.isFormField()) {
//                        // Process a regular form field
//                        request.setAttribute(item.getFieldName(), item.getString());
//
//                        String name = item.getFieldName();
//                        String value = item.getString();
//                        if (name.equals("contigSize")) {
//                            contigSize = Integer.parseInt(value + "000");
//                        } else {
//                            options.add(name);
//                            options.add(value);
//                        }
//
//                    } else {
//                        String inputFile = "in";
//                        uploadedFile = new File(workDirectory + "/in/" + inputFile);
//                        item.write(uploadedFile);
//                    }
//                }
//
//                if (uploadedFile.length() > 10000000) {
//                    throw new Exception("FASTA File size must be less than 10 MB");
//                }
//
//                if (contigSize > 1000000) {
//                    throw new Exception("Region size must be <= 1000 (KB)");
//                }
//
//
//                FileInputStream fis = new FileInputStream(uploadedFile);
//
//                String fname = workDirectory + "/out/out";
//
//                BufferedReader br = new BufferedReader(new InputStreamReader(fis));
//                br.readLine();
//
//                int count = 0;
//                int totalCount = 0;
//
//
//                for (int j=0; j< 2000000; j++) {
//                    //System.out.println(j);
//                }
//
//
//                boolean first = true;
//                while (true) {
//                    byte buffer[] = new byte[contigSize];
//                    int i = fis.read(buffer, 0, contigSize);
//
//                    if (i == -1) {
//                        if (first) {
//                            throw new Exception("FASTA sequence size must be greater than 10 KB");
//                        }
//                        break;
//                    }
//
//                    String str = new String(buffer);
//
//                    str = str.replaceAll("[\r]", "");
//                    str = str.replaceAll("[\n]", "");
//                    str = str.trim();
//
//                    StringBuffer sb = new StringBuffer(str);
//
//                    String base = "";
//                    while (sb.length() < contigSize && i != -1) {
//
//                        byte buf2[] = new byte[1];
//                        i = fis.read(buf2, 0, 1);
//
//                        if (i == -1) {
//                            break;
//                        }
//
//                        base = new String(buf2);
//
//                        if (!base.equals("\n") && !base.equals("\r")) {
//                            sb.append(base);
//                        }
//
//                    }
//
//                    str = sb.toString().trim();
//
//                    totalCount += str.length();
//
//                    FileOutputStream fos = new FileOutputStream(fname + count);
//                    long byteStart = totalCount - str.length();
//                    long byteEnd = totalCount;
//
//                    String header = ">" + byteStart + " - " + byteEnd + " (kb)\r\n";
//                    fos.write(header.getBytes());
//
//                    fos.write(str.getBytes());
//                    fos.flush();
//                    fos.close();
//
//                    oligoSpawnRequests.add(new OligoSpawnRequest(str.length(), options, fname + count, count));
//
//                    ++count;
//                }
//            }

        } catch (Exception e) {
            error.add(e.getMessage());
            e.printStackTrace();
        }

        request.setAttribute("requestFacade", req);
        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/overgo/find.jsp", "oligoSpawnRequests", oligoSpawnRequests);
    }


}