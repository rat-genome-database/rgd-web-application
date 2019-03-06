<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div id="app">

    <div id="test" style="width:100%;height:10px">

    </div>

    <div class="container-fluid" id="container" style="height:36px;background-color:#d6e5ff;">

            <div class="row" style=";margin-top:2px;margin-left:35%;margin-bottom:2px;width:100%">
            <form  name="elasticSearchForm" class="form-inline" action="/rgdweb/elasticResults.html" id="elasticSearchForm" role="search" method="post">
                <input type="hidden" name="log" value="true"/>
               <table>
                   <tr>
                       <!--td>
                           <label for="category" style="color:#24609c">Select Database: </label>&nbsp;<select id="category" class="searchgroup category" name="category" >
                               <option >Gene</option>
                               <option>QTL</option>
                               <option>Strain</option>
                               <option>SSLP</option>
                               <option>Reference</option>
                               <option>Ontology</option>
                               <option selected>General</option>
                           </select>

                       </td-->
                       <input type="hidden" name="category" id="category" value="General"/>
                       <td>
                          <input type=text class="searchgroup" id="term" name=term size="50" placeholder="Enter Search Term..." value="${model.term}">
                       </td>
                       <td>
                           <input type="image" src="/rgdweb/common/images/searchGlass.gif" class="searchButtonSmall"/>
                       </td>
                       <td colspan="2"  align="center"><br><a href="/rgdweb/generator/list.html" >Advanced Search (OLGA)</a></td>
                   </tr>
               </table>

            </form>
            </div>


            </div>

</div>
