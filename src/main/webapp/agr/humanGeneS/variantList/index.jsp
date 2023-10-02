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
  String vars = "12,119697755,119697755,G,T,CV204138,point mutation,GRCh38,long QT syndrome,Ventriculomegaly | Failure to thrive,uncertain significance\n" +
"12,119697758,119697758,G,A,CV204139,point mutation,GRCh38,long QT syndrome,,uncertain significance\n" +
"12,119701858,119701858,G,A,CV583114,point mutation,GRCh38,primary autosomal recessive microcephaly 17,Hypoplasia of the frontal lobes | Intellectual disability,uncertain significance\n" +
"12,119710275,119710275,G,T,CV677369,point mutation,GRCh38,Marfanoid Mental Retardation Syndrome, Autosomal,Intellectual disability, severe,uncertain significance\n" +
"12,119710363,119710363,T,G,CV511976,point mutation,GRCh38,genetic disease,,uncertain significance\n" +
"12,119713601,119713601,T,G,CV788863,point mutation,GRCh38,primary autosomal recessive microcephaly 17,,uncertain significance\n" +
"12,119718283,119718283,G,A,CV551309,point mutation,GRCh38,primary autosomal recessive microcephaly 17,,uncertain significance\n" +
"12,119718401,119718401,G,A,CV511977,point mutation,GRCh38,genetic disease,,uncertain significance\n" +
"12,119728602,119728602,T,C,CV624054,point mutation,GRCh38,primary autosomal recessive microcephaly 17,,likely benign|uncertain significance\n" +
"12,119734159,119734159,C,T,CV583115,point mutation,GRCh38,primary autosomal recessive microcephaly 17,Microcephaly,uncertain significance\n" +
"12,119822819,119822819,C,T,CV247394,point mutation,GRCh38,primary autosomal recessive microcephaly | primary autosomal recessive microcephaly 17,Cerebellar hypoplasia,pathogenic\n" +
"12,119832768,119832768,T,A,CV248606,point mutation,GRCh38,primary autosomal recessive microcephaly 17,Microcephaly,pathogenic\n" +
"12,119832835,119832835,T,A,CV248603,point mutation,GRCh38,primary autosomal recessive microcephaly 17,,pathogenic\n" +
"12,119834093,119834093,C,T,CV624055,point mutation,GRCh38,primary autosomal recessive microcephaly 17,,uncertain significance\n" +
"12,119850217,119850217,G,C,CV247395,point mutation,GRCh38,primary autosomal recessive microcephaly,Intellectual disability, severe,pathogenic\n" +
"12,119857525,119857525,G,A,CV247396,point mutation,GRCh38,primary autosomal recessive microcephaly,Microcephaly,pathogenic\n" +
"12,119857561,119857561,T,G,CV248602,point mutation,GRCh38,primary autosomal recessive microcephaly 17,Sloping forehead | Seizures,pathogenic\n" +
"12,119857620,119857620,C,A,CV248601,point mutation,GRCh38,primary autosomal recessive microcephaly 17,Microcephaly,pathogenic\n" +
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
                        <table width="100%" cellpadding="0" cellspacin="0">
                            <tr>
                                <td class="header"><br>Variants/Alleles&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a style="font-size:14px;" href="variantList">Analyze Variants/Alleles</a></td>
                            </tr>
                        </table>


                        <div style="height: 600px; overflow: auto;">


                            <table width="100%" cellpadding="6" cellspacing="0">
                                <tr>

                                    <td class="subHeader">Variant/allele symbol</td>
                                    <td class="subHeader">Type</td>
                                    <td class="subHeader">Genomic alteration</td>
                                    <td class="subHeader">Genomic alteration type</td>
                                    <td class="subHeader">Molecular consequence</td>
                                    <td class="subHeader">Has phenotype/Disease annotations</td>

                                    <!--
                                    <td class="subHeader">ID</td>
                                    <td class="subHeader">Variant/allele symbol</td>
                                    <td class="subHeader">Variant Type</td>
                                    <td class="subHeader">Chromosome:position</td>
                                    <td class="subHeader">Nucleotide Change</td>
                                    <td class="subHeader">Most Severe<br>Consequence</td>
                                    <td class="subHeader">Most Severe<br>Protein Consequence</td>
                                    -->
                                    <!--
                                    <td class="subHeader">Disease<br> Association</td>
                                    <td class="subHeader">Phenotype<br> Association</td>
                                    -->
                                </tr>



                                <%
                                    BufferedReader br = new BufferedReader(new StringReader(vars));
                                    String line = null;
                                %>


                                <%
                                    int i=0;
                                    while ((line=br.readLine()) != null) {
                                        i++;
                                        String[] cols = line.split(",");

                                %>
                                <tr>
                                    <td class="cell"><a href="variant/"><%=cols[5]%></a></td>
                                    <!--<td class="cell"><a href="variant/">HGVS Name</a></td>-->
                                    <td class="cell">variant</td>
                                    <td class="cell">Chr<%=cols[0]%>:<%=cols[1]%></td>
                                    <td class="cell"><%=cols[6]%></td>

                                    <% if (i==3 || i==5 || i==15 || i==25) { %>
                                    <td class="cell">missense</td>
                                    <% } else if (i==4 || i==9) { %>
                                    <td class="cell">stop gain</td>
                                    <% } else { %>
                                    <td class="cell">point mutation</td>
                                    <% }  %>


                                    <td class="cell"><a href="variant/">D</a> <a href="variant/">P</a></td>

                                    <!--
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
                                    -->
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