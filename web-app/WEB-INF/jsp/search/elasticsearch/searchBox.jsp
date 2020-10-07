<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div id="app">

    <div id="test" style="width:100%;height:10px">

    </div>

    <div class="container-fluid" id="container" style="height:36px;">

            <div class="row" style=";margin-top:2px;margin-left:35%;margin-bottom:2px">
            <form  name="elasticSearchForm" class="form-inline" action="/rgdweb/elasticResults.html" id="elasticSearchForm" role="search" method="post">
                <input type="hidden" name="log" value="true"/>
                <input type="hidden" name="category" id="category" value="General"/>

                <div class="form-row row">
                <div class="form-group">
                    <div class="input-group" >
                        <input   class="searchgroup" id="term" name=term size="50" placeholder="Enter Search Term..." value="${model.term}" type="search"  />

                        <div class="input-group-append">

                            <button class="btn btn-primary" type="submit">
                                <i class="fa fa-search"></i>
                            </button>&nbsp;&nbsp;
                        </div>
                    </div>
                    <small class="form-text text-muted"><a href="/rgdweb/generator/list.html" >Advanced Search (OLGA)</a></small>
                </div>
                </div>
            </form>
            </div>


            </div>

</div>
