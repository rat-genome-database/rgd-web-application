<%@ page import="java.util.StringTokenizer" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.StringReader" %>
<style>
 .header{
     color: #212529;
     font-size: 30.2px;
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
                    <td>
                        <table width="100%" cellpadding="0" cellspacing="0" style="margin-left:10px;">
                            <tr><td style="color:#919796;font-family: Lato,Helvetica, sans-serif;">ALLELE/VARIANT</td></tr>
                            <tr style="border:1px solid black;">
                                <td class="header" >Cit<sup>fhJjlo</sup></td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr>
                                <td>
                                    <table >
                                        <tr>
                                            <td class="subHeader" width="300">Species</td>
                                            <td class="cell">Rattus norvegicus</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Symbol</td>
                                            <td class="cell">Cit<sup>fhJjlo</sup></td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Type</td>
                                            <td class="cell">allele with 1 known variant</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Affected Region</td>
                                            <td class="cell"><a href="../">Cit</a></td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Construct inserted/present</td>
                                            <td class="cell">N/A</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Genomic Variation Type</td>
                                            <td class="cell">deletion</td>
                                        </tr>

                                        <tr>
                                            <td class="subHeader" width="300">Synonyms</td>
                                            <td class="cell">CitfhJjlo</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Description</td>
                                            <td class="cell">Not Available</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Source/Cross Ref</td>
                                            <td class="cell"></td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Variation Pathogenicity</td>
                                            <td class="cell">Pathogenic</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Reference/Literature</td>
                                            <td class="cell"></td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Additional Information</td>
                                            <td class="cell">Not Available</td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
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
                                <td class="subHeader">Genomic Variation</td>
                                <td class="subHeader">Variantion Type</td>
                                <td class="subHeader">Genomic Location</td>
                                <td class="subHeader">Nucleotide Change</td>
                                <td class="subHeader">Most Severe<br>Consequence</td>
                                <td class="subHeader">HGVS names</td>
                                <td class="subHeader">Xreference,Provenance</td>
                            </tr>

                                <tr>
                                    <td class="cell"><a href="../variant/">HGVS Name</a></td>
                                    <td class="cell">deletion</td>
                                    <td class="cell">12:46493042..46493043</td>
                                    <td class="cell">C/-</td>
                                    <td class="cell">stop gain</td>
                                    <td class="cell"><a href="../variant/">HGVS Name</a></td>
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