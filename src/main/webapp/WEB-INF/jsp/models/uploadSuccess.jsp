<%
    String filepath= (String) request.getAttribute("filePath");
    String msg= (String) request.getAttribute("message");
    System.out.println(msg);
    if(filepath!=null){
%>

<div><span style="color:green">Selected file uploaded successfully.</span><input type="hidden" name="fileLocation" value="<%=filepath%>"/></div>

<%}else{%>


<div><span style="color:red"><%=msg%></span></div>

<%}%>