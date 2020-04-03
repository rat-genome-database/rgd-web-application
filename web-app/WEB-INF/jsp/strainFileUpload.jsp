<!DOCTYPE >
<html>
<head>
    <title>Upload files</title>
</head>
<body>

<h2>Upload Files</h2>

<div class="container-fluid">
<form method="POST" action="strainFileUpload.html" enctype="multipart/form-data">

            <label for="strainId" style="color: #24609c; font-weight: bold;">Select a Strain Id:</label>
            <input type="text" id="strainId" name="strainId" />
<br><br>
            <label for="file" style="color: #24609c; font-weight: bold;">Select file to upload:</label>
            <input type="file" id="file" name="file"  />
<br><br>
           <label for="fileType" style="color: #24609c; font-weight: bold;">Select FileType:</label>
                <input type="text" id = "fileType" name="fileType" />
<br><br>
                <label for="description" style="color: #24609c; font-weight: bold;"> Description:</label>
                <input type="text" id="description" name="description" size="100" />
 <br><br>
            <input type="submit" value="Upload" />

</form>
</div>
</body>
</html>