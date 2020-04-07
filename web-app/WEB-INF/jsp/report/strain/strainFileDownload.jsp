<%@ page import="java.sql.Blob" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="edu.mcw.rgd.dao.impl.StrainDAO" %><%

    StrainDAO dao =new StrainDAO();
    int id = Integer.parseInt(request.getParameter("id"));
    String type = request.getParameter("type");
    Blob data =  dao.getStrainAttachment(id,type);

    String contentType = dao.getContentType(id,type);
    String ext;
   response.setHeader("Content-Type", contentType);
   if(contentType.endsWith("document"))
       ext = "docx";
   else {
       ext = "."+contentType.substring(contentType.indexOf("/")+1);
   }
    response.setHeader("Content-disposition","attachment;filename=\""+id+type+ext+"\"");
   InputStream is = data.getBinaryStream();


    byte[] bytes = new byte[1024];
    int bytesRead;
    while ((bytesRead = is.read(bytes)) != -1) {
         response.getOutputStream().write(bytes);
    }

    response.getOutputStream().flush();
    response.getOutputStream().close();
%>