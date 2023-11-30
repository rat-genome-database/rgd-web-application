<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: 11/17/23
  Time: 9:34 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>

<script>
    fetch('https://alpha-curation.alliancegenome.org/health', {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
        }
    })
        .then(response => response.json())
        .then(data => {
            alert(data);
            // do something with the data
        });
</script>



</body>
</html>
