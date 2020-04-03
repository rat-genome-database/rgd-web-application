<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.StringReader" %>
<style>
 .header{
     color: #212529;
     font-size: 25.2px;
     font-family: Lato,Helvetica, sans-serif;
     border-bottom:1px solid #dddddd;

 }
 .subHeader{
     color: #212529;
     font-size: 14.4px;
     font-family: Lato,Helvetica, sans-serif;
     font-weight:600;
     border-bottom:1px solid #dddddd;
     height:40px;
 }
 .cell {
     color: #212529;
     font-size: 14.4px;
     font-family: Lato,Helvetica, sans-serif;
     border-bottom:1px solid #dddddd;
     height:30px;


 }

 <%
  String vars = "12,119697755,119697755,G,T,CV204138,SNV,GRCh38,long QT syndrome,Ventriculomegaly | Failure to thrive,uncertain significance\n" +
"12,119697758,119697758,G,A,CV204139,SNV,GRCh38,long QT syndrome,,uncertain significance\n" +
"12,119701858,119701858,G,A,CV583114,SNV,GRCh38,primary autosomal recessive microcephaly 17,Hypoplasia of the frontal lobes | Intellectual disability,uncertain significance\n" +
"12,119710275,119710275,G,T,CV677369,SNV,GRCh38,Marfanoid Mental Retardation Syndrome, Autosomal,Intellectual disability, severe,uncertain significance\n" +
"12,119710363,119710363,T,G,CV511976,SNV,GRCh38,genetic disease,,uncertain significance\n" +
"12,119713601,119713601,T,G,CV788863,SNV,GRCh38,primary autosomal recessive microcephaly 17,,uncertain significance\n" +
"12,119718283,119718283,G,A,CV551309,SNV,GRCh38,primary autosomal recessive microcephaly 17,,uncertain significance\n" +
"12,119718401,119718401,G,A,CV511977,SNV,GRCh38,genetic disease,,uncertain significance\n" +
"12,119728602,119728602,T,C,CV624054,SNV,GRCh38,primary autosomal recessive microcephaly 17,,likely benign|uncertain significance\n" +
"12,119734159,119734159,C,T,CV583115,SNV,GRCh38,primary autosomal recessive microcephaly 17,Microcephaly,uncertain significance\n" +
"12,119822819,119822819,C,T,CV247394,SNV,GRCh38,primary autosomal recessive microcephaly | primary autosomal recessive microcephaly 17,Cerebellar hypoplasia,pathogenic\n" +
"12,119832768,119832768,T,A,CV248606,SNV,GRCh38,primary autosomal recessive microcephaly 17,Microcephaly,pathogenic\n" +
"12,119832835,119832835,T,A,CV248603,SNV,GRCh38,primary autosomal recessive microcephaly 17,,pathogenic\n" +
"12,119834093,119834093,C,T,CV624055,SNV,GRCh38,primary autosomal recessive microcephaly 17,,uncertain significance\n" +
"12,119850217,119850217,G,C,CV247395,SNV,GRCh38,primary autosomal recessive microcephaly,Intellectual disability, severe,pathogenic\n" +
"12,119857525,119857525,G,A,CV247396,SNV,GRCh38,primary autosomal recessive microcephaly,Microcephaly,pathogenic\n" +
"12,119857561,119857561,T,G,CV248602,SNV,GRCh38,primary autosomal recessive microcephaly 17,Sloping forehead | Seizures,pathogenic\n" +
"12,119857620,119857620,C,A,CV248601,SNV,GRCh38,primary autosomal recessive microcephaly 17,Microcephaly,pathogenic\n" +
"12,119876131,119876140,ATCCTTTGGA,,CV222995,deletion,GRCh38,primary autosomal recessive microcephaly | primary autosomal recessive microcephaly 17,Abnormal cortical bone morphology | Agenesis of corpus callosum | Intellectual disability, severe,pathogenic\n";
%>
</style>

<table>
    <tr>
        <td colspan="2"><img src="top.png"/></td>
    </tr>
    <tr>
        <td valign="top">
            <img src="left.png"/>
        </td>
        <td>
            <table>
                <tr>
                    <td><img src="search.png"/></td>
                </tr>

                <tr>
                    <td>
                        <div style="height: 600px; overflow: auto;">

                            <table width="100%" cellpadding="0" cellspacin="0">
                                <tr>
                                    <td class="header"><br>Variants</td>
                                </tr>
                            </table>




                            <table width="100%" cellpadding="2" cellspacing="2">
                                <tr>

                                    <td class="subHeader">Variant Name</td>
                                    <td class="subHeader">ID</td>
                                    <td class="subHeader">Variant Type</td>
                                    <td class="subHeader">Chromosome:position</td>
                                    <td class="subHeader">Nucleotide Change</td>
                                    <td class="subHeader">Clinical Significance</td>
                                    <td class="subHeader">Disease<br> Association</td>
                                    <td class="subHeader">Phenotype<br> Association</td>
                                    <td class="subHeader">Most Severe<br>Consequence</td>
                                    <td class="subHeader">Most Severe<br>Protein Consequence</td>

                                </tr>


                                <%
                                    BufferedReader br = new BufferedReader(new StringReader(vars));
                                    String line = null;
                                %>


                                <% while ((line=br.readLine()) != null) {
                                    String[] cols = line.split(",");

                                %>
                                <tr>
                                    <td class="cell" align="center"><a href="../../humanGene/variant/">HGVS Name</a></td>
                                    <td class="cell" align="center"><%=cols[5]%></td>
                                    <td class="cell" align="center"><%=cols[6]%></td>
                                    <td class="cell" align="center"><%=cols[0]%>:<%=cols[1]%></td>
                                    <td class="cell" align="center"><%=cols[3]%>/<%=cols[4]%></td>

                                    <% if (cols.length >=11) {%>
                                    <td class="cell"><%=cols[10]%></td>
                                    <% } else {%>
                                    <td class="cell"></td>
                                    <% } %>

                                    <% if (cols.length >=9) {%>
                                    <td class="cell"><%=cols[8]%></td>
                                    <% } else {%>
                                    <td class="cell"></td>
                                    <% } %>

                                    <% if (cols.length >=10) {%>
                                    <td class="cell"><%=cols[9]%></td>
                                    <% } else {%>
                                    <td class="cell"></td>
                                    <% } %>
                                    <td class="cell"></td>
                                    <td class="cell"></td>

                                </tr>
                                <% } %>
                            </table>
                        </div>

                    </td>
                </tr>


            </table>




        </td>
    </tr>
</table>