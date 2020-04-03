<%@ page import="java.sql.Blob" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="edu.mcw.rgd.dao.impl.StrainDAO" %><%

    StrainDAO dao =new StrainDAO();
    System.out.println(request.getParameter("id"));
    int id = Integer.parseInt(request.getParameter("id"));
    String type = request.getParameter("type");
    Blob data =  dao.getStrainAttachment(id,type);

    String contentType = "text/csv";//"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
   response.setHeader("Content-Type", contentType);
    response.setHeader("Content-disposition","attachment;filename=\""+id+"Genotype.docx\"");
   InputStream is = data.getBinaryStream();

    byte[] bytes = new byte[1024];
    int bytesRead;
out.println("Running");
    while ((bytesRead = is.read(bytes)) != -1) {
         response.getOutputStream().write(bytes);
    }
    is.close();

%>