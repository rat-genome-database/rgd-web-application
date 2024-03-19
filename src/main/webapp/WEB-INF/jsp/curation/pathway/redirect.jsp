<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.datamodel.Pathway" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%
    Term newPwObj = (Term) request.getAttribute("createPwObj");
    //System.out.println("creating PwObj:" + newPwObj.getAccId());
    String newpathwayID = "";

    if((newPwObj != null) || (!(newPwObj.equals("")))){
        newpathwayID = newPwObj.getAccId();
        //System.out.println("here is the newPathwayID:" + newpathwayID);
    }

    //session.setAttribute("newId", newpathwayID);
    String uploadDir = (String) request.getAttribute("uploadingDir");
    //System.out.println("the uploading dir can be accessed by REDIRECT.JSP:" + uploadDir);
    String redirectURL="";
     if(newpathwayID.length()>1){
         redirectURL = "2;url=/rgdweb/curation/pathway/pathwayCreate.html?term_acc="+newpathwayID+"&upload="+uploadDir+">";
     }else
     if(newpathwayID.equals("")){
         redirectURL = "2;url=/rgdweb/curation/pathway/error.html?errVal=1&upload="+uploadDir+">";
     }

%>

<html>
<head>
<title>Redirecting...</title>
<meta http-equiv="REFRESH" content="<%=redirectURL%>"
</HEAD>
<BODY>
This Pathway Object has to be created...
You will be redirected to a new page to create Pathway Object.. <%=newPwObj.getAccId()%>
</BODY>
</HTML>