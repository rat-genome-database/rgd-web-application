<%@ page import="edu.mcw.rgd.ontology.OntDagNode" %>
<%@ page import="java.util.List" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntViewBean" />
<div id="term_paths">
<p><a name="top"/>
<h4>Term paths:</h4>
To access information on a term, click the item in the <i>Term</i> column.  To browse the ontology at a particular
point, click the corresponding <img src=/common/images/tree2.gif border=0> in the second column. The <b>R</b>
column indicates the number of rat objects annotated to the term, the <b>C</b>
column indicates the number of all objects annotated to the term, while the <b>T</b> column indicates the number of
annotations to the term and its descendants.<br/>
</p>
<table width="700" border="1"><caption align="top">Immediate child terms</caption>
<tr><td><b>Term</b></td><td><b>Acc Id</b></td><td>&nbsp;</td><td><b>C</b></td><td><b>T</b></td></tr>
<%
       for( OntDagNode node: bean.getChilds() ) {

          // term relation image -- could be null
          String image = bean.getRelationImage(node.getOntRel());

          // 1st column: show relation image followed by term
          out.append("<tr><td> &nbsp; ");
          if( image!=null ) {
              out.append(" &nbsp; <img width='10' height='10' src='/common/images/").append(image).append("'> ");
          }
          out.append("<a href='annot.html?acc_id=").append(node.getTermAcc()).append("'>")
                  .append(node.getTerm()).append("</a></td>\n<td>");

          // 2nd column: show term acc id
          out.append(node.getTermAcc())
             .append("</td><td>")
             .append("<a href=\"view.html?acc_id=").append(node.getTermAcc()).append("\"><img src=/common/images/tree2.gif border='0'></a>")
             .append("</td></tr>\n");
       }
%>
</table>
<table width="700" border="1"><caption align="top">Paths to parent terms</caption>
<% int pathCount = bean.getPaths().size();
   StringBuffer pathCrossLinks = new StringBuffer("Go to path: ");
   for( int i=1; i<=pathCount; i++ ) {
       pathCrossLinks.append(" [ <a href='#").append(i).append("'>").append(i).append("</a> ]");
   }
   pathCrossLinks.append(" [ <a href='#top'>back&nbsp;to&nbsp;top</a> ]");
   pathCrossLinks.append("</th></tr>\n");
   pathCrossLinks.append("<tr><td><b>Term</b></td><td><b>Acc Id</b></td><td>&nbsp;</td><td><b>R</b></td><td><b>C</b></td><td><b>T</b></td></tr>\n");

 
%></table>
</div>