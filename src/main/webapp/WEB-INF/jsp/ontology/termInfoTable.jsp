<%@ page import="edu.mcw.rgd.pathway.PathwayDiagramController" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.datamodel.XdbId" %>
<%@ page import="edu.mcw.rgd.datamodel.XDBIndex" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%-- to be included into the master page --%>
<table style="width:800px"><!-- START TERM INFORMATION SECTION -->
    <tr><td valign="top">
        <table><%-- VARIOUS INFORMATION TO THE LEFT: term, acc id, definition, synonyms --%>
        <tr><td class="colh">Term:</td><td><b><%=bean.getTerm().getTerm()%></b></td>
            <td>
                <form name="searchForm1" action="/rgdweb/elasticResults.html">
                    <input type="text" name="term" class="searchTerm" value=""/>
                    <input type="hidden" name="category" value="Ontology"/>
                    <input type="image" class="searchButtonSmall" title="search" src="/common/images/searchGlass.gif" onclick="document.searchForm1.submit();"/>
                    <a href="search.html">go back to main search page</a>
                </form>
            </td>
        </tr>
        <tr><td class="colh">Accession:</td><td>${bean.accId}
        <%--  // link out to Comparative Toxicogenomics Database, if applicable
            if( bean.getCtdAccId()!=null ) {
                String url = "http://ctd.mdibl.org/detail.go?type=disease&db=" + bean.getCtdAccId().substring(0, 4)
                    + "&acc=" + bean.getCtdAccId().substring(5);

                out.print("<br/><a href='"+url+"' title='View term at CTD' alt='View term at CTD'>");
                out.print("view term at <img src='/rgdweb/images/CTD.gif' border='0'> Comparative Toxicogenomics Database");
                out.print("</a> &nbsp; ");
            }
            // and linkout to ChEBI when applicable
            else if( bean.getAccId().startsWith("CHEBI:") ) {

                String url = "http://www.ebi.ac.uk/chebi/searchId.do?chebiId=" + Integer.parseInt(bean.getAccId().substring(6), 10);
                out.print("<br/><a href='"+url+"' title='View term at EMBL-EBI' alt='View term at EMBL-EBI'>");
                out.print("view term at <img src='/rgdweb/common/images/ebi_logo.png' border='0'> EMBL-EBI");
                out.print("</a> &nbsp; ");
            }
        --%>
        </td>
            <td valign="top">
                <a href="view.html?acc_id=${bean.term.accId}"><img border="0" alt="term browser" title="click to browse the term" src="/rgdweb/common/images/tree.png">&nbsp;browse&nbsp;the&nbsp;term</a>
              <% if( ((TermWithStats)bean.getTerm()).getAnnotObjectCountForTermAndChildren()>0
                        // do not show link to ont annotations page when annotations page is being shown!
                       && !request.getServletPath().endsWith("annot.jsp")
                      ) {

                    if( bean.getCtdAccId()!=null ) {
                        out.println("<br/>");
                    } else {
                        out.println(" &nbsp; &nbsp; ");
                    }
                %>
                <a href="annot.html?acc_id=${bean.term.accId}"><img border="0" alt="term annotations" title="click to view term annotations" src="/rgdweb/images/icon-a.gif">&nbsp;&nbsp;view&nbsp;annotations</a>
              <%}%>
            </td>
        </tr>
        <% if( bean.getTerm().isObsolete() ) { %>
        <tr><td class="colh">Status:</td>
            <td colspan="2">
            <div style="border:2px solid #f00; background-color:#fcc; margin-bottom:10px">
            <img src="/common/images/icons/exclamation.png"> This term is obsolete.
            We suggest searching for the text of the ontology term or for a keyword rather than searching for the ontology ID.
            For more information, please <a href="/contact/index.shtml" title="go to contact us form" alt="contact us form">contact us</a>.
            </div>
            </td>
        </tr>
        <% } %>
            <%if (bean.getTerm().getDefinition() != null && !bean.getTerm().getDefinition().isEmpty()) {%>
          <tr><td class="colh">Definition:</td><td colspan="2"><%=bean.getTerm().getDefinition()%></td></tr>
            <% } %>
            <%if (bean.getTerm().getComment() != null && !bean.getTerm().getComment().isEmpty()) {%>
          <tr><td class="colh">Comment:</td><td colspan="2"><%=bean.getTerm().getComment()%></td></tr>
        <% } %>
            <%if (!bean.getTermSynonyms().isEmpty()){%>
          <tr>
            <% String prevType = "";
            int synonymsPerType = 0;
            int rowCount = 0;
          for( TermSynonym syn: bean.getTermSynonyms() ) {

              if( !prevType.equals(syn.getType()) ) {
                  // finish prev row
                  if( !prevType.isEmpty() ) {
                    out.print("</td></tr>\n");
                  }
                  // start new row with alternating background
                  if( ++rowCount%2 == 1 )
                    out.print("<tr class='oddRow'>");
                  else
                    out.print("<tr class='evenRow'>");
                  // setup first row
                  if( prevType.isEmpty() )
                    out.print("<td class=\"colh\">Synonyms:</td>");
                  else
                    out.print("<td class='colh'>&nbsp;</td>");

                  // show synonym type
                  out.print("<td valign='top' style='color:#555555'><b>"+syn.getType()+":</b> </td><td style='padding:3px;'>");
                  synonymsPerType = 0;
                  prevType = syn.getType();
              }
              synonymsPerType++;
              if( synonymsPerType>1 )
                out.print("; &nbsp; ");

              // turn synonym name into a link from MESH and OMIM ids
              if( syn.getName().startsWith("MESH:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(47).getUrl())
                     .append(syn.getName().substring(5))
                     .append("\" title=\"view term at MESH\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("MIM:PS") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(66).getUrl())
                     .append(syn.getName().substring(4))
                     .append("\" title=\"view term at OMIM\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("MIM:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_OMIM).getUrl())
                     .append(syn.getName().substring(4))
                     .append("\" title=\"view term at OMIM\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("GARD:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(67).getUrl().replace("#ID#",syn.getName().substring(5)))
                     .append("\" title=\"view term at GARD\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("ORDO:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(62).getUrl())
                     .append(syn.getName().substring(5))
                     .append("\" title=\"view term at Orphanet\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("NCI:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(74).getUrl())
                     .append(syn.getName().substring(4))
                     .append("\" title=\"view term at NCI Thesaurus\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("ICD10CM:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(129).getUrl())
                     .append(syn.getName().substring(8))
                     .append("\" title=\"view term at ICD-10\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("ICD9CM:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(130).getUrl())
                     .append(syn.getName().substring(7))
                     .append("\" title=\"view term at ICD-9\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("EFO:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(93).getUrl())
                     .append("EFO_").append(syn.getName().substring(4))
                     .append("\" title=\"view term at EBI\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("MONDO:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(145).getUrl())
                     .append("MONDO_").append(syn.getName().substring(6))
                     .append("\" title=\"view term at EBI\">").append(syn.getName()).append("</a>");
              }
              else if( syn.getName().startsWith("OBA:") ) {
                  out.append("<a href=\"").append(XDBIndex.getInstance().getXDB(159).getUrl())
                     .append("OBA_").append(syn.getName().substring(4))
                     .append("\" title=\"view term at EBI\">").append(syn.getName()).append("</a>");
              }
              
              // link outs to strain report pages for rat strain ontology terms having assigned rgd ids
              else if( syn.getName().startsWith("RGD ID:") ) {
                  out.append("<a href=\"").append(Link.strain(Integer.parseInt(syn.getName().substring(8))))
                     .append("\" title=\"view strain report\">")
                     .append(syn.getName())
                     .append("</a>");
              }
              // link outs to gene report page
              else if( syn.getType().startsWith("omim_gene") ) {
                  List<Gene> omimGenes = new GeneDAO().getActiveGenes(SpeciesType.HUMAN, syn.getName());
                  if( !omimGenes.isEmpty() ) {
                  out.append("<a href=\"").append(Link.gene(omimGenes.get(0).getRgdId()))
                     .append("\" title=\"view gene report\">")
                     .append(syn.getName())
                     .append("</a>");
                  } else {
                      out.append(syn.getName());
                  }
              }
              else {
                  // create pattern based on ontology id
                  int pos = bean.getAccId().indexOf(":");
                  String ontId = !syn.getType().equals("alt_id") && pos>0 ? bean.getAccId().substring(0, pos) : null;
                  if( ontId!=null ) {
                      Pattern p = Pattern.compile("\\b("+ontId+"\\:\\d{7})\\b");
                      StringBuffer sb = new StringBuffer();
                      Matcher m = p.matcher(syn.getName());
                      while( m.find() ) {
                          m.appendReplacement(sb, "<a href=\""+Link.ontView(m.group(1))+"\">"+syn.getName()+"</a>");
                      }
                      m.appendTail(sb);
                      out.append(sb.toString());
                  }
                  else
                    out.append(syn.getName());
              }
          }
          // terminate table row
            out.append("</td></tr>\n");


          } // end if
        %>

        <%-- DO disease link to AGR --%>
        <% if( bean.getAccId().startsWith("DOID:") ) {
            String doPlus = bean.getAccId().substring(5);
//            System.out.println(doPlus);
            if (!doPlus.startsWith("9") && doPlus.length() != 7){
        %>
        <tr><td colspan="3" align="center" style="padding-top: 12px; font-weight: bolder">
                For additional species annotation, visit the
                <a href="<%=XDBIndex.getInstance().getXDB(64).getUrl()+bean.getAccId()%>" title="Alliance of Genome Resources" style="color:#0275d8; font-weight: bolder">Alliance of Genome Resources</a>.
            </td></tr>
        <% } } %>
    </table></td>
    <td valign="top">
        <%-- PATHWAY SMALL IMAGE - TO THE RIGHT --%>
        <% if( bean.getAccId().startsWith("PW") ) {
            String diagramImageUrl = new PathwayDiagramController().generateContent("small", bean.getAccId());
            if( !diagramImageUrl.isEmpty() ) {
            %>
        <a href="/rgdweb/pathway/pathwayRecord.html?acc_id=<%=bean.getAccId()%>" title="view interactive pathway diagram">
            <img src="<%=diagramImageUrl%>" alt="" style="width:150px;" border="1"/><br/>
            View Interactive Diagram
        </a>
        <%}}%>
    </td>
    </tr>
</table><!-- END TERM INFORMATION SECTION -->
