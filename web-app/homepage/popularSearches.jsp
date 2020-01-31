<style>
.searchCard {
    line-height:63px;
    text-align: center;
    height:63px;
z-index:30;
opacity:1;
    font-size:14px;
    text-decoration:none;
    padding-left:6px;
    padding-right:6px;
}

.searchCard p {
    line-height: 1.3;
    display: inline-block;
    ertical-align: middle;
}

.searchCard:hover p {
    color:white;
}

.searchCard:hover {
opacity:.5;
cursor:pointer;
    background-color:#2865a3;
    color:white;

}
</style>

<div style="font-family: 'Source Code Pro', monospace; font-size: 20px;">Search</div>
<div style="background-color:#eaf2f8; order:2px solid #c5c9cf" >
    <table align="center" border="0">
        <tr>
            <td>
                <div class="searchCard" onclick="location.href='/rgdweb/search/genes.html'">Genes</div>
            </td>
            <td><img src="/rgdweb/common/images/dnaSeperator.png" border="0"  /></td>
            <td>
                <div class="searchCard" onclick="location.href='/rgdweb/search/strains.html'">Strains</div>
            </td>
            <td><img src="/rgdweb/common/images/dnaSeperator.png" border="0" /></td>
            <td>
                <div class="searchCard" onclick="location.href='/rgdweb/ontology/search.html'"><p style="margin-top:10px;">Ontology<br>&<br> Annotation</p></div>
            </td>
            <td><img src="/rgdweb/common/images/dnaSeperator.png" border="0" /></td>
            <td>
                <div class="searchCard" onclick="location.href='/QueryBuilder/'">
                    <p style="margin-top:15px;">Ontomate<br> (Literature)</p>
                </div>
            </td>
            <td><img src="/rgdweb/common/images/dnaSeperator.png" border="0" /></td>
            <td>
                <div class="searchCard" onclick="location.href='/rgdweb/search/qtls.html'">QTL</div>
            </td>
            <td><img src="/rgdweb/common/images/dnaSeperator.png" border="0" /></td>
            <td>
                <div class="searchCard" onclick="location.href='/rgdweb/ortholog/start.html'">Orthologs</div>
            </td>
            <td><img src="/rgdweb/common/images/dnaSeperator.png" border="0" /></td>
            <td>
                <div class="searchCard" onclick="location.href='/wg/data-menu/'"><p style="margin-top:15px;">Genetic<br>Models</p></div>
            </td>
            <td><img src="/rgdweb/common/images/dnaSeperator.png" border="0" /></td>
            <td>
                <div class="searchCard" onclick="location.href='/wg/data-menu/'">More..</div>
            </td>
        </tr>
    </table>
</div>
