<%@ page import="java.util.StringTokenizer" %>
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
                    <td><img src="head.png"/></td>
                </tr>
                <tr>
                    <td><img src="variants.png"/></td>
                </tr>
                <tr>
                    <td>
                        <div style="margin-left:10px;height: 200px; overflow: auto;">

                        <table width="100%" cellpadding="0" cellspacin="0">
                            <tr>
                                <td class="header"><br>Variants</td>
                            </tr>
                            </table>

                            <table width="100%" cellpadding="0" cellspacin="0">
                            <tr>
                                <td class="subHeader">Variant Name</td>
                                <td class="subHeader">ID</td>
                                <td class="subHeader">Variant Type</td>
                                <td class="subHeader">Chromosome:position</td>
                                <td class="subHeader">Nucleotide Change</td>
                                <td class="subHeader">Most Severe<br>Consequence</td>
                                <td class="subHeader">Most Severe<br>Protein Consequence</td>
                            </tr>

                                <tr>
                                    <td class="cell"><a href="../variant/">HGVS Name</a></td>
                                    <td class="cell"></td>
                                    <td class="cell">deletion</td>
                                    <td class="cell">12:46493042</td>
                                    <td class="cell">C/-</td>
                                    <td class="cell"></td>
                                    <td class="cell"></td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td><img src="pheno.png"/></td>
                </tr>
                <tr>
                    <td><img src="do1.png"/></td>
                </tr>


            </table>




        </td>
    </tr>
</table>