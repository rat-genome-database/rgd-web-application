<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 2/13/2024
  Time: 1:37 PM
  To change this template use File | Settings | File Templates.
--%>
<tr bgcolor="#CCCCCC">
    <td colspan="2"><b>Options</b></td>
</tr>
<tr>
    <td class=links><a href="javascript:start_help('search')">Search</a> </td>
    <td>
        <select name="search_fields">
            <option value="symbols">Current Symbols</option>
            <option value="symbols_names">Current Symbols/Names</option>
            <option value="active_retired">Current and Withdrawn</option>
            <option value="all_with_aliases" selected>Current &amp; withdrawn &amp;
                Aliases</option>
        </select>
    </td>
</tr>
<tr>
    <td class=links><a href="javascript:start_help('limit_sslps')">Limit to genes with associated
        SSLPs</a></td>
    <td>
        <select name="sslp_limit">
            <option value="yes">Yes</option>
            <option value="no" selected>No</option>
        </select>
    </td>
</tr>
<tr>
    <td class=links><a href="javascript:start_help('limit_homologs')">Limit to genes with
        known homologs</a></td>
    <td>
        <select name="hmlg_limit">
            <option value="yes">Yes</option>
            <option value="no" selected>No</option>
        </select>
    </td>
</tr>
<!-----------add limit to genes with GO id or GO term, Lan Zhao--------------->
<tr valign="top">
    <td class=links><a href="javascript:start_help('limit_ontology')">Limit to genes with
        associated ontology term</a></td>
    <td>
        <select name="ont_type" >
            <option value="GO" selected>Gene Ontology</option>
            <!--<option value="DO">Disease Ontology</option>
            <option value="PO">Phenotype Ontology</option> -->
        </select>
    </td>
</tr>
<tr valign="top">
    <td> &nbsp;</td>
    <td>
        <input type="text" name="ont_value"  size=20 >
    </td>
</tr>
<!--------------------------end of adding limit ---------------------------->
<tr valign="top">
    <td class=links><a href="javascript:start_help('results_ordered_by')">Results ordered
        by</a></td>
    <td>
        <input type="radio" name="order" value="symbol" checked>
        Symbol<br>
        <input type="radio" name="order" value="name">
        Name<br>
        <input type="radio" name="order" value="chromosome">
        Chromosome </td>
</tr>
<tr>
    <td class=links><a href="javascript:start_help('results_per_page')">Records per page</a></td>
    <td>
        <input type="radio" name="num_hits" value="25" checked>
        25
        <input type="radio" name="num_hits" value="50">
        50
        <input type="radio" name="num_hits" value="100">
        100 </td>
</tr>
<tr>
    <td>&nbsp;</td>
    <td>

    </td>
</tr>
