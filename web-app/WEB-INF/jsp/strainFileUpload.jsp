
<%
    String pageTitle = "Upload Strain Files";
    String headContent = "";
    String pageDescription = "Upload Strain Files";
%>
<%@ include file="/common/headerarea.jsp"%>

<script type="text/javascript" src="/rgdweb/js/util.js"></script>

<link rel="stylesheet" href="/rgdweb/js/windowfiles/dhtmlwindow.css" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/windowfiles/dhtmlwindow.js">
    /***********************************************
     * DHTML Window Widget- � Dynamic Drive (www.dynamicdrive.com)
     * This notice must stay intact for legal use.
     * Visit http://www.dynamicdrive.com/ for full source code
     ***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/js/lookup.js"></script>
<html>
<head>
    <title>Upload files</title>
</head>
<body>

<h2>Upload Files</h2>

<div class="container-fluid">
<form method="POST" action="strainFileUpload.html" enctype="multipart/form-data">

            <label for="rgdId1" style="color: #24609c; font-weight: bold;">Select a Strain Id:</label>
            <input type="text" id="rgdId1" name="strainId" />
     <a href="javascript:lookup_render('rgdId1')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
<br><br>
            <label for="file" style="color: #24609c; font-weight: bold;">Select file to upload:</label>
            <input type="file" id="file" name="file"  />
<br><br>
           <label for="fileType" style="color: #24609c; font-weight: bold;">Select FileType:</label>
    <select id="fileType" name="fileType">
    <option  value="Genotype">Genotype</option>
    <option  value="Highlights">Highlights</option>
    <option  value="Supplemental">Supplemental</option>
    </select>
<br><br>

            <input type="submit" value="Upload" />

</form>
</div>
</body>
</html>