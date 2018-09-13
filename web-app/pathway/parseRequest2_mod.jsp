<%@ page language="java" import="java.io.*, java.sql.*, java.util.*" %>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.io.*, org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.servlet.*" %>
<%@ page import="static org.apache.commons.io.FileUtils.*" %>
<%



/**
 * This pages gives a sample of java upload management. It needs the commons FileUpload library, which can be found on apache.org.
 *
 * Note:
 * - putting error=true as a parameter on the URL will generate an error. Allows test of upload error management in the applet. 
 * 
 * 
 * 
 * 
 * 
 * 
 */

    // Directory to store all the uploaded files
    //String ourTempDirectory = (String)session.getAttribute("tempDir");
    String ourTempDirectory = "/rgd/www/pathway/";

    //String ourTempDirectory = "/rgd/www/pathway"; //for the server..
    /*String pathwayFile =  "";*/

    //System.out.println("here is formdata line 27.. ^^^^^^^^^^^^^^^^^^^");

	byte[] cr = {13}; 
	byte[] lf = {10}; 
	String CR = new String(cr);
	String LF = new String(lf);
	String CRLF = CR + LF;
	out.println("Before a LF=chr(10)" + LF 
		+ "Before a CR=chr(13)" + CR 
		+ "Before a CRLF" + CRLF); 


  //Initialization for chunk management.
  boolean bLastChunk = false;
  int numChunk = 0;
  
  //CAN BE OVERRIDEN BY THE postURL PARAMETER: if error=true is passed as a parameter on the URL
  boolean generateError = false;  
  boolean generateWarning = false;
  boolean sendRequest = false;  

  response.setContentType("text/plain");
  
  java.util.Enumeration<String> headers = request.getHeaderNames();
  out.println("[parseRequest.jsp]  ------------------------------ ");
  out.println("[parseRequest.jsp]  Headers of the received request:");
  while (headers.hasMoreElements()) {
  	String header = headers.nextElement();
  	out.println("[parseRequest.jsp]  " + header + ": " + request.getHeader(header));  	  	
  }
  out.println("[parseRequest.jsp]  ------------------------------ "); 
  //System.out.println("[parseRequest.jsp]  ------------------------------ ");
  try{
    // Get URL Parameters.
    //System.out.println("getting parameter names");
    Enumeration paraNames = request.getParameterNames();
    out.println("[parseRequest.jsp]  ------------------------------ ");
    System.out.println("[parseRequest.jsp]  Parameters: ");
    out.println("[parseRequest.jsp]  Parameters: ");
    String pname;
    String pvalue;
    if(paraNames!=null){
    while (paraNames.hasMoreElements()) {
      pname = (String)paraNames.nextElement();
      pvalue = request.getParameter(pname);
      out.println("[parseRequest.jsp] " + pname + " = " + pvalue);
      if (pname.equals("jufinal")) {
      	bLastChunk = pvalue.equals("1");
      } else if (pname.equals("jupart")) {
      	numChunk = Integer.parseInt(pvalue);
      }

      //For debug convenience, putting error=true as a URL parameter, will generate an error
      //in this response.
      if (pname.equals("error") && pvalue.equals("true")) {
      	generateError = true;
      }

      //For debug convenience, putting warning=true as a URL parameter, will generate a warning
      //in this response.
      if (pname.equals("warning") && pvalue.equals("true")) {
      	generateWarning = true;
      }
       
      //For debug convenience, putting readRequest=true as a URL parameter, will send back the request content
      //into the response of this page.
      if (pname.equals("sendRequest") && pvalue.equals("true")) {
      	sendRequest = true;
      }
       
    }
    out.println("[parseRequest.jsp]  ------------------------------ ");

    int ourMaxMemorySize  = 10000000;
    int ourMaxRequestSize = 2000000000;

	///////////////////////////////////////////////////////////////////////////////////////////////////////
	//The code below is directly taken from the jakarta fileupload common classes
	//All informations, and download, available here : http://jakarta.apache.org/commons/fileupload/
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Create a factory for disk-based file items
	DiskFileItemFactory factory = new DiskFileItemFactory();


	// Set factory constraints
	factory.setSizeThreshold(ourMaxMemorySize);
	factory.setRepository(new File(ourTempDirectory));
	
	// Create a new file upload handler
	ServletFileUpload upload = new ServletFileUpload(factory);
	
	// Set overall request size constraint
	upload.setSizeMax(ourMaxRequestSize);
	
	// Parse the request
	if (sendRequest) {
		//For debug only. Should be removed for production systems. 
		out.println("[parseRequest.jsp] ==========================================================================="); 
		out.println("[parseRequest.jsp] Sending the received request content: "); 
		InputStream is = request.getInputStream();
		int c;
		while ( (c=is.read()) >= 0) {
			out.write(c);
		}//while
		is.close();
		out.println("[parseRequest.jsp] ==========================================================================="); 
	} else if (! request.getContentType().startsWith("multipart/form-data")) {
		out.println("[parseRequest.jsp] No parsing of uploaded file: content type is " + request.getContentType()); 
	} else { 
		List /* FileItem */ items = upload.parseRequest(request);
		// Process the uploaded items
		Iterator iter = items.iterator();
		FileItem fileItem;
	    File fout;
        File fout2;
        File formPath = null;
        File cachePath = null;

	    out.println("[parseRequest.jsp]  Let's read the sent data   (" + items.size() + " items)");
		//System.out.println("[parseRequest.jsp]  Let's read the sent data   (" + items.size() + " items)");
        String relpath = "";

	     while (iter.hasNext()) {
		    fileItem = (FileItem) iter.next();
		
		    if (fileItem.isFormField()) {
		        System.out.println("*******[parseRequest.jsp] (form field) " + fileItem.getFieldName() + " = " + fileItem.getString());
                out.println("[parseRequest.jsp] (here is the form field) " + fileItem.getFieldName() + " = " + fileItem.getString());
		        
                if(fileItem.getFieldName().equals("pathwayLoc")){
                        System.out.println("**************session set to " + session.getAttribute("flag")+ "********");
                        System.out.println("FORMDATA HERE!!!");
                        ourTempDirectory = fileItem.getString();
                        System.out.println("################here is the formval:" + ourTempDirectory + "^^^^^^^^^^^");
                        formPath = new File(ourTempDirectory);
                        System.out.println("here is the formpath:" + ourTempDirectory);
                    if(session.getAttribute("flag").equals("0")){
                        if(formPath.exists()&& formPath.isDirectory()){
                            cleanDirectory(formPath);
                            System.out.println("Directory exists .. Cleaning directory");
                        }
                        formPath.mkdirs();
                        System.out.println("cleaned file");
                        session.setAttribute("flag", "1");
                    }
                }
                if(fileItem.getFieldName().equals("cacheImageLoc")){
                    String cacheImg = fileItem.getString();
                    cachePath = new File(cacheImg);
                    if(cachePath.exists()&&cachePath.isDirectory()){
                        cleanDirectory(cachePath);
                    }
                    cachePath.mkdirs();
                }

                if(fileItem.getFieldName().equals("relpathinfo0")) {
				    fout2 = new File(fileItem.getString());
                    relpath = fout2 + "/";
				//System.out.println("relpath = " + relpath);
		        }


		        //If we receive the md5sum parameter, we've read finished to read the current file. It's not
		        //a very good (end of file) signal. Will be better in the future ... probably !
		        //Let's put a separator, to make output easier to read.
		        if (fileItem.getFieldName().equals("md5sum[]")) { 
					out.println("[parseRequest.jsp]  ------------------------------ ");
				}
		    } else {
		        //Ok, we've got a file. Let's process it.
		        //Again, for all informations of what is exactly a FileItem, please
		        //have a look to http://jakarta.apache.org/commons/fileupload/
		        //
		        out.println("[parseRequest.jsp] FieldName: " + fileItem.getFieldName());
		        out.println("[parseRequest.jsp] File Name: " + fileItem.getName());
		        out.println("[parseRequest.jsp] ContentType: " + fileItem.getContentType());
		        out.println("[parseRequest.jsp] Size (Bytes): " + fileItem.getSize());
		        //If we are in chunk mode, we add ".partN" at the end of the file, where N is the chunk number.
		        String uploadedFilename = fileItem.getName() + ( numChunk>0 ? ".part"+numChunk : "") ;

             //System.out.println("here is the temp dir"+ ourTempDirectory + "/"+relpath);
			File f = new File(ourTempDirectory+"/"+relpath);
			f.mkdirs();

			//System.out.println(ourTempDirectory + "/"+relpath + (new File(uploadedFilename)).getName());
            fout = new File(ourTempDirectory + "/"+ relpath + (new File(uploadedFilename)).getName());
            //fout2 = new File(ourTempDirectory + relpath);


                    out.println("[parseRequest.jsp] File Out: " + fout.toString());


                    out.println("[Pushkala Test] this is the fileset: " + uploadedFilename);


                /*if((fout2.exists()) && (fout2.isDirectory())){
                    out.println("[Pushkala Test] this folder exists!!! Do Full Drop and Reload of Folder and its contents!!!");
                    System.out.println("[Pushkala Test] this folder exists!!! Do Full Drop and Reload of Folder and its contents!!!");
                    org.apache.commons.io.FileUtils.cleanDirectory(fout2);
                    fout = new File(fout2 + (new File(uploadedFilename)).getName());
                    fileItem.write(fout);
                }else{*/
                    // write the file
                    fileItem.write(fout);	        
                //}

		        
		        //////////////////////////////////////////////////////////////////////////////////////
		        //Chunk management: if it was the last chunk, let's recover the complete file
		        //by concatenating all chunk parts.
		        //
		        if (bLastChunk) {	        
			        out.println("[parseRequest.jsp]  Last chunk received: let's rebuild the complete file (" + fileItem.getName() + ")");
			        //First: construct the final filename.
			        FileInputStream fis;
			        //System.out.println("here is our temp directory: " + ourTempDirectory + " and here is our fileITEM" + fileItem.getName());
                    FileOutputStream fos = new FileOutputStream(ourTempDirectory + "/"+ relpath + fileItem.getName());
			        int nbBytes;
			        byte[] byteBuff = new byte[1024];
			        String filename;
			        for (int i=1; i<=numChunk; i+=1) {
			        	filename = fileItem.getName() + ".part" + i;
			        	out.println("[parseRequest.jsp] " + "  Concatenating " + filename);
			        	fis = new FileInputStream(ourTempDirectory + "/"+relpath+filename);
			        	while ( (nbBytes = fis.read(byteBuff)) >= 0) {
			        		//out.println("[parseRequest.jsp] " + "     Nb bytes read: " + nbBytes);
			        		fos.write(byteBuff, 0, nbBytes);
			        	}
			        	fis.close();
			        }
			        fos.close();
		        }
		        
		        
		        // End of chunk management
		        //////////////////////////////////////////////////////////////////////////////////////
		        
		        fileItem.delete();
		    }	    
		}//while
	}
	
    if(generateWarning){
    	out.println("WARNING: just a warning message.\\nOn two lines!");
    }

  	out.println("[parseRequest.jsp] " + "Let's write a status, to finish the server response :");
    
    //Let's wait a little, to simulate the server time to manage the file.
    Thread.sleep(500);
    
    //Do you want to test a successful upload, or the way the applet reacts to an error ?
    if (generateError) { 
    	out.println("ERROR: this is a test error (forced in /wwwroot/pages/parseRequest.jsp).\\nHere is a second line!");
    } else {
    	out.println("SUCCESS");
    	//out.println("                        <span class=\"cpg_user_message\">Il y eu une erreur lors de l'exécution de la requête</span>");
    }

  	  //System.out.println("*********************[parseRequest.jsp] " + "End of server treatment ");
      out.println("[parseRequest.jsp] " + "End of server treatment ");

    }
  }catch(Exception e){
    e.printStackTrace();
	out.println("");
    out.println("ERROR: Exception e = " + e.toString());
    out.println("");
  }
  
%>