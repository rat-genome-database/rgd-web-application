<%@ include file="carpeHeader.jsp" %>
<%@ include file="menuBar.jsp" %>
<br>
<%
    boolean isHuman = (Boolean)request.getAttribute("isHuman");
    String ppText = isHuman ? "Clinical Significance" : "Polyphen Prediction";
    String snText = isHuman ? "Sample Names" : "Strain Names";
%>
<div style="font-weight:700; font-size:20px; background-color:#CCCCCC; color:#01224B;">Download Annotated File</div>

An annotated file will be generated for this region.

Select annotation to include in your download.
<br>
<br>
<form action="download.html">
    <table align="center">
        <tr>
            <td>
                <table>
                    <tr>
                        <td><input type='checkbox' name="c" checked>Chromosome</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="p" checked>Position</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="cs" checked>Conservation Score</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="gs" checked>Gene Symbol</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="st" checked>Gene Strand</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="rn" checked>Reference Nucleotide</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="sn" checked><%=snText%></td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="vl" checked>Variant Location</td>
                    </tr>
                 </table>
            </td>
            <td>&nbsp;&nbsp;&nbsp;</td>
            <td valign="top">
                <table>

                    <tr>
                        <td><input type='checkbox' name="aac" checked>Amino Acid Change</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="tai" checked>Transcript Accession IDs</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="raa" checked>Reference Amino Acid</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="vaa" checked>Variant Amino Acid</td>
                    </tr>
                    <tr>
                        <td><input type='checkbox' name="pp" checked><%=ppText%></td>
                    </tr>
                    <tr><td>&nbsp;</td></tr>
                    <tr>
                        <td align="center"><input type='submit' value="Generate File"></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>



    <input type="hidden" name="download" value="1"/>
    <%
        out.print(fu.buildHiddenFormFieldsFromQueryString(request.getQueryString()));
    %>
</form>


<div style="font-weight:700; font-size:20px; background-color:#CCCCCC; color:#01224B;">RGD VCF Repository</div>

The VCF repository contains files used to populate the variant visualizer
<br><br>
<a href="ftp://ftp.rgd.mcw.edu/pub/strain_specific_variants" style="font-size:16px;">Browse the VCF File Repository</a>
