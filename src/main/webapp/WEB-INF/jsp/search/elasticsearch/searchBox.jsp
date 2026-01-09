
   <div class="row" style="width: 100%;float: right">
       <div class="col-9">
       <form name="elasticSearchForm"  action="/rgdweb/elasticResults.html" id="elasticSearchForm" role="search" method="post">
           <%
               if(RgdContext.isProduction()){
           %>
           <input type="hidden" name="log" value="true"/>
           <%}%>
          <input type="hidden" name="category" id="category" value="General"/>
    <div class="input-group">

        <input class="form-control border-end-0 border searchgroup" type="text"  id="term" name="term" value="${model.term}">
        <span class="input-group-append">
                <button class="btn btn-outline-secondary bg-light border-start-0 border  ms-n3" type="submit">
                    <i class="fa fa-search"></i>
                </button>
            </span>

    </div>
       </form>
       </div>
       <div class="col-3">

               <small class="form-text text-muted"><a href="/rgdweb/generator/list.html" >Advanced Search (OLGA)</a></small>


       </div>
   </div>




