<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div id="app">

    <table width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td align="center">
                <div class="container-fluid" id="container" style="background-color:#d6e5ff;padding-top:3px;padding-bottom:0px;">
                    <div class="row">
            <form  name="elasticSearchForm" class="form-inline" action="/rgdweb/elasticResults.html" id="elasticSearchForm" role="search" method="post">
                    <input type="hidden" name="log" value="true" />
                    <table border="0">
                        <tr>
                            <input type="hidden" name="category" id="category" value="General"/>
                            <td>
                                <input type=text class="searchgroup" id="term" name=term size="60" placeholder="Enter Search Term..." value="${model.term}" style="border:1px solid #2865A3">
                            </td>
                            <td>
                                <input type="image" src="/rgdweb/common/images/searchGlass.gif" class="searchButtonSmall"/>
                            </td>
                            <td colspan="2"  align="center"><br><a href="/rgdweb/generator/list.html" >Advanced Search (OLGA)</a></td>
                        </tr>
                    </table>

                    </form>
                </div>

            </td>
        </tr>
    </table>

    </div>
</div>
