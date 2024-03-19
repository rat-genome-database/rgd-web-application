<style type="text/css">
/* PIP-eline logs specific styles */
h2.pip a { color: #2865A3; text-decoration:underline; font-size: 14pt;}
h2.pip a:hover { color: blue; text-decoration:underline overline; }

table.pip {
    border: 1px solid black;
    border-collapse:collapse;
}
table.pip th {
  border:1px solid black;
  background-image:url('/common/images/gradient.jpg');
  color:#f4f1d9;
  font-size:12px;
  height:18px;
}
table.pip td {
  border:1px solid black;
  padding:3px 7px 2px 7px;
  vertical-align: top;
  font-family: monospace;
  /*white-space:pre;*/
}
table.pip tr.red td {
    color:red;
    background-color:#EAF2D3;
    font-weight:bold;
}
table.pip tr.green td {
    color:green;
}
table.pip td.wrapped {
    white-space:normal;
}

/*Credits: Dynamic Drive CSS Library */
/*URL: http://www.dynamicdrive.com/style/ */

a.squarebutton{
    background: transparent url('/rgdweb/images/square-blue-left.gif') no-repeat top left;
    display: block;
    float: left;
    font: normal 12px Arial; /* Change 12px as desired */
    line-height: 15px; /* This value + 4px + 4px (top and bottom padding of SPAN) must equal height of button background (default is 23px) */
    height: 23px; /* Height of button background height */
    padding-left: 9px; /* Width of left menu image */
    text-decoration: none;
}
a:link.squarebutton, a:visited.squarebutton, a:active.squarebutton{
    color: #494949; /*button text color*/
}
a.squarebutton span{
    background: transparent url('/rgdweb/images/square-blue-right.gif') no-repeat top right;
    display: block;
    padding: 4px 9px 4px 0; /*Set 9px below to match value of 'padding-left' value above*/
}
a.squarebutton:hover{ /* Hover state CSS */
    background-position: bottom left;
}
a.squarebutton:hover span{ /* Hover state CSS */
    background-position: bottom right;
    color: black;
}
.buttonwrapper{ /* Container you can use to surround a CSS button to clear float */
    overflow: hidden; /*See: http://www.quirksmode.org/css/clearing.html */
    width: 100%;
}
/* example:
<div class="buttonwrapper">
  <a class="squarebutton" href="#"><span>button-text</span></a>
</div> */

/* pipeline record set */
.piprecset {
    border:solid red 1px;
}
.piprec { /* single pipeline record */
    width:100%;
    display:block;
}
.piprecyell { /* single pipeline record with yellow background */
    width:100%;
    display:block;
    background-color:yellow;
}
.piprecleft { /* left pane of a pipeline record */
    float:left;
    width:190px;
    padding-left:10px;
}
.piprecmain { /* main content of a pipeline record */
    float:left;
}
.piprecrow { /* a row being part of record main content */
    display:block;
    width:100%;
    border-bottom:solid 1px gray;
    padding:3px;
}

/** navigation bar: result paging */
.pipnav {
    border: solid 1px purple;    
}
.pipnav a {
    background-color: cornflowerblue;    
}
.pipnav span {
    background-color: mediumturquoise;
}
/* link that looks like a 3D button: code usage:
<div id="buttonA">
<ul>
<li><a href="link1.html">Button 1</a></li>
</ul>
</div>
*/
div#buttonA {
    margin-left: 8px;
}
div#buttonA ul {
    margin: 0px;
    padding: 0px;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-size: 10px;
    line-height: 22px;
}
div#buttonA li {
    list-style-type: none;
    height: 22px;
    width: 100px;
    margin: 8px;
    text-align:center;
}
div#buttonA li a {
    height: 100%;
    width: 100%;
    display: block;
    text-decoration: none;
    border-width: 4px;
}
div#buttonA li a:link {
    color: #000000;
    font-weight: bold;
    background-color: #CCCCCC;
    border-style: outset;
}
div#buttonA li a:visited {
    color: #000000;
    font-weight: normal;
    background-color: #CCCCCC;
    border-style: outset;
}
div#buttonA li a:hover {
    font-weight: bold;
    color: #FFFFFF;
    background-color: #999999;
    border-style: outset;
}
div#buttonA li a:active {
    font-weight: bold;
    color: #FFFFFF;
    background-color: #666666;
    border-style: inset;
}

/* used to show a table with labels and values */
.infobox_wrapper {
    border: 1px solid black;
    background-color:#f9f9f9;
    /*width: 95%;*/
}
.infobox_header {
    background-color: #2865a3;
    color: white;
    font-weight: bold;
}
</style>