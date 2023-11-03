<div style="border:1px solid #2865A3;margin-top:30px;margin-bottom:30px; padding:10px;">
<a name="pheno"></a>
<h3>Related Phenotype Data for Term "<%=bean.getTerm().getTerm()%>" (<%=bean.getAccId()%>)</h3>
  <table cellspacing='3px' border='0'>
  <tr>
    <td valign='top' style='vertical-align: top;'>
      <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Rat Strains:</div>
      <ul>
          <% if( bean.getAccId().startsWith("RS:") ) {
                for( Term term: bean.getPhenoStrains() ) { %>
            <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>" title="view strain phenotype data"><%=term.getTerm()%></a></li>
          <%    }
              } else {
                for( Term term: bean.getPhenoStrains() ) { %>
            <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>,<%=bean.getAccId()%>" title="view strain phenotype data for term '<%=bean.getTerm().getTerm()%>'"><%=term.getTerm()%></a></li>
        <% }
        }%>
      </ul>
    </td>

    <td valign='top' style='vertical-align: top;'>
      <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Clinical Measurements:</div>
      <ul>
          <% if( bean.getAccId().startsWith("CMO:") ) {
            for( Term term: bean.getPhenoCmoTerms() ) { %>
          <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>" title="view clinical measurement phenotype data"><%=term.getTerm()%></a></li>
          <%    }
              } else {
                for( Term term: bean.getPhenoCmoTerms() ) { %>
            <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>,<%=bean.getAccId()%>" title="view clinical measurement phenotype data for term '<%=bean.getTerm().getTerm()%>'"><%=term.getTerm()%></a></li>
        <% }
        }%>
      </ul>
    </td>
    <td valign='top' style='vertical-align: top;'>
      <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Experimental Conditions:</div>
      <ul>
          <% if( bean.getAccId().startsWith("XCO:") ) {
            for( Term term: bean.getPhenoXcoTerms() ) { %>
          <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>" title="view experimental condition phenotype data"><%=term.getTerm()%></a></li>
          <%    }
              } else {
                for( Term term: bean.getPhenoXcoTerms() ) { %>
            <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>,<%=bean.getAccId()%>" title="view experimental condition phenotype data for term '<%=bean.getTerm().getTerm()%>'"><%=term.getTerm()%></a></li>
        <% }
        }%>
      </ul>
    </td>
    <td valign='top' style='vertical-align: top;'>
      <div style='font-weight: 700; border-bottom: 2px solid #2865a3;'>Measurement Methods:</div>
      <ul>
          <% if( bean.getAccId().startsWith("MMO:") ) {
            for( Term term: bean.getPhenoMmoTerms() ) { %>
          <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>" title="view measurement method phenotype data"><%=term.getTerm()%></a></li>
          <%    }
              } else {
                for( Term term: bean.getPhenoMmoTerms() ) { %>
            <li><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=term.getAccId()%>,<%=bean.getAccId()%>" title="view measurement method phenotype data for term '<%=bean.getTerm().getTerm()%>'"><%=term.getTerm()%></a></li>
        <% }
        }%>
      </ul>
    </td>
  </tr>
</table>
</div>
