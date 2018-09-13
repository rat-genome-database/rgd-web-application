<%@ page import="edu.mcw.rgd.*" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  Created by IntelliJ IDEA.
  User: mtutaj
  Date: June 21, 2010
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String pageTitle = " Phenotype Images Uploader - " + RgdContext.getLongSiteName(request);
    String headContent = "Phenotype Images Uploader";
    String pageDescription = "Phenotype Images Uploader";

%>

<%@ include file="/common/headerarea.jsp"%>

<hr/>
<h3>Upload new image here</h3>
<c:if test="${!empty uploadMsg}" >
    <div style="color:red;border:solid black 1px;font-size:150%;font-weight:bold;">
        File upload message: ${uploadMsg}
    </div>
</c:if>
<div>
<form name="filesForm" action="" method="post" enctype="multipart/form-data">
    Image: <input type="file" name="file1"/>
    <input type="submit" name="submit" value="Upload" />
</form>
</div>
<hr/>
<h3>Contents of directory with phenotype images (${imgDirPath}):</h3>
<h5>Hint: Click an image name to see the image preview below.</h5>
<c:forEach var="f" items="${files}">
    <a href="?show=${f.name}"><c:out value="${f.name}"/></a>
    <br/>
</c:forEach>
<c:if test="${!empty img}">
    <hr/>
    <h3>Image preview -- image public url is <a style="color:#a52a2a;" href="${imgUrl}">${imgUrl}</a></h3>
    <img src="?img=${img}" alt="${img}"/>
</c:if>

<hr/>
<%@ include file="/common/footerarea.jsp"%>