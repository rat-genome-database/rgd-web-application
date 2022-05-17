<%
    String protein = request.getParameter("p");
    String species = request.getParameter("species");

    String pageTitle = "Protein Structure - "+protein+" ("+species+")";
    String headContent = "";
    String pageDescription = "Show protein structure for a protein, from AlphaFold";
%>

<%@ include file="../common/headerarea.jsp" %>

<script type="text/javascript" src="JSmol.min.js"></script>

<script type="text/javascript">

// last update 5/04/2022

var jmolApplet0; // set up in HTML table, below

// logic is set by indicating order of USE -- default is HTML5 for this test page, though

var s = document.location.search;

// Developers: The _debugCode flag is checked in j2s/core/core.z.js, 
// and, if TRUE, skips loading the core methods, forcing those
// to be read from their individual directories. Set this
// true if you want to do some code debugging by inserting
// System.out.println, document.title, or alert commands
// anywhere in the Java or Jmol code.

Jmol._debugCode = (s.indexOf("debugcode") >= 0);

jmol_isReady = function(applet) {
	document.title = (applet._id + " - Jmol " + ___JmolVersion)
	Jmol._getElement(applet, "appletdiv").style.border="1px solid blue"
}		

var Info = {
	width: 500,
	height: 500,
	debug: false,
	color: "0xFFFFFF",
	use: "HTML5",   // JAVA HTML5 WEBGL are all options
	j2sPath: "./j2s", // this needs to point to where the j2s directory is.
	jarPath: "./java",// this needs to point to where the java directory is.
	jarFile: "JmolAppletSigned.jar",
	isSigned: true,
	script: "set antialiasDisplay",
	serverURL: "http://chemapps.stolaf.edu/jmol/jsmol/php/jsmol.php",
	readyFunction: jmol_isReady,
	disableJ2SLoadMonitor: true,
    disableInitialConsole: true,
    allowJavaScript: true
	//defaultModel: "$dopamine",
	//console: "none", // default will be jmolApplet0_infodiv, but you can designate another div here or "none"
}

$(document).ready(function() {
  $("#adiv").html(Jmol.getAppletHtml("jmolApplet0", Info));
    Jmol.loadFile(jmolApplet0,'/jsmol/pdb/alphafold/<%=species%>/<%=protein%>.pdb');
    Jmol.script(jmolApplet0,'select protein or nucleic;cartoons only;color property atomno');
});
var lastPrompt=0;
</script>
</head>
<body>
<table width=1000 cellpadding=10>
<tr>
  <td valign="top">
    <div style="font-size:26px;">Protein - <%=protein%> (<%=species%>)</div>
    <div id="adiv"></div>
  </td>
</tr>
<tr>
  <td>
      <table width="100%">
        <tr>
          <td></td>
          <td colspan="3"><b>Display:</b></td>
        </tr>
        <tr>
          <td rowspan="3" valign="top"><button type="button" onclick="Jmol.script(jmolApplet0,'write PNGJ <%=protein%>_jmol.png')">Save<br>Image</button></td>
          <td><a href="javascript:Jmol.script(jmolApplet0,'select *;cartoons off;spacefill only')">spacefill</a></td>
          <td><a href="javascript:Jmol.script(jmolApplet0,'select protein or nucleic;cartoons only')">cartoons</a></td>
          <td><a href="javascript:Jmol.script(jmolApplet0,'color property atomno')">color:atomno</a></td>
        </tr>
        <tr>
           <td><a href="javascript:Jmol.script(jmolApplet0,'select *;cartoons off;wireframe -0.1')">wire</a></td>
           <td><a href="javascript:Jmol.script(jmolApplet0,'set cartoonFancy true')">fancy</a></td>
           <td><a href="javascript:Jmol.script(jmolApplet0,'color cpk')">color:cpk</a></td>
        </tr>
        <tr>
           <td><a href="javascript:Jmol.script(jmolApplet0,'select *;cartoons off;spacefill 23%;wireframe 0.15')">ball&amp;stick</a></td>
           <td><a href="javascript:Jmol.script(jmolApplet0,'set cartoonFancy false;set hermitelevel 0')">flat</a></td>
           <td><a href="javascript:Jmol.script(jmolApplet0,'color structure')">color:struct</a></td>
        </tr>
      </table>
  </td>
</tr>

</table>

<%@ include file="../common/footerarea.jsp" %>