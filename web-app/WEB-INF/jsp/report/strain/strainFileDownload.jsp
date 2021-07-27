<%@ page import="java.sql.Blob" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="edu.mcw.rgd.dao.impl.StrainDAO" %><%

    StrainDAO dao =new StrainDAO();
    int id = Integer.parseInt(request.getParameter("id"));
    String type = request.getParameter("type");
    Blob data =  dao.getStrainAttachment(id,type);

    String contentType = dao.getContentType(id,type);
    String fileName = dao.getFileName(id,type);
   response.setHeader("Content-Type", contentType);
    response.setHeader("Content-disposition","attachment;filename=\""+fileName+"\"");
   InputStream is = data.getBinaryStream();

    byte[] bytes = new byte[1024];
    int bytesRead = -1;
    while ((bytesRead = is.read(bytes)) != -1) {
         response.getOutputStream().write(bytes,0,bytesRead);
    }
    is.close();
    response.getOutputStream().flush();
    response.getOutputStream().close();
%>