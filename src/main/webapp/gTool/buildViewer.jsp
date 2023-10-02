



<%
    String pageTitle = "Web Genome Viewer - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Gviewer provides users with complete genome view of gene and QTL annotated to a function, biological process, cellular component, phenotype, disease, or pathway. The tool will search for matching terms from the Gene Ontology, Mammalian Phenotype Ontology, Disease Ontology or Pathway Ontology.";

%>

<%@ include file="../common/headerarea.jsp" %>

<h1>Genome Viewer Builder</h1>

<form action="displayViewer.jsp">

<table>
    <tr>
        <td>
            <table style="border: 1px dotted black;padding: 5px;">
    <tr>
        <td><b>Object Information</b></td>
    </tr>
    <tr>
        <td valign="top">
            Gene Symbol List
        </td>
        <td>
            <textarea name="genes" rows="4" cols=30>a2m, lepr</textarea>
        </td>
    </tr>
    <tr>
        <td>Gene Color: </td> <td><input type="text" name="geneColor" value="blue" /></td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td valign="top">
            QTL Symbol List
        </td>
        <td>
            <textarea name="qtls"  rows="4" cols=30>bp100,Mcs13</textarea>
        </td>
    </tr>
    <tr>
        <td>QTL Color: </td> <td><input name="qtlColor" type="text" value="red" /></td>
    </tr>

<!--
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td>
            Marker Symbol List
        </td>
        <td>
            <textarea name="markers"></textarea>
        </td>
    </tr>
    <tr>
        <td>Marker Color: </td> <td><input type="text" value="orange" /></td>
    </tr>
-->
</table>
</td>
        <td valign="top">
            <table style="border: 1px dotted black; padding:5px;">
    <tr>
        <td>
            Select a Species:
        </td>
        <td>
            <select name="species">
                <option value="3">Rat</option>
                <option value="2">Mouse</option>
                <option value="1">Human</option>
            </select>
        </td>
    </tr>
                <tr>
                    <td>
                        Select an Assembly:
                    </td>
                    <td>
                        <select name="assembly">
                            <option value="60">Rat 3.4</option>
                            <option value="13">Human 36</option>
                            <option value="17">Human 37</option>
                            <option value="18">Mouse 37</option>
                        </select>
                    </td>
                </tr>
    <tr>
        <td>
            Viewer Height (pixels):
        </td>
        <td>
            <input type="text" value=200 name="height"/>
        </td>
    </tr>
    <tr>
        <td>
            Viewer Width (pixels):
        </td>
        <td>
            <input type="text" value=700 name="width"/>
        </td>
    </tr>
</table></td>
    </tr>
</table>







    <input type=submit value=submit />
</form>

<%@ include file="../common/footerarea.jsp" %>