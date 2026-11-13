<%-- AI Mode: a button in the search box that sends what is typed to RatChat, in a new tab, instead of
     searching. On the page types RatChat knows it also passes this page as the question's context:
     the page type and the record's RGD ID or ontology accession (see rgd-ai-chatbot's page-context.json). --%>
<style>
    /* The text box, AI Mode and the search button read as one box: no borders between them, one
       border around the three. Bootstrap's .border and .bg-light are !important, hence these. */
    #elasticSearchForm .input-group { height: 34px; flex-wrap: nowrap; }
    #elasticSearchForm #term { height: 34px; font-size: 14px; padding: 6px 12px;
                               border-color: #ced4da !important; border-right: 0 !important; box-shadow: none; }
    #elasticSearchForm .input-group-append > button[type=submit] { height: 34px; padding: 0 12px; font-size: 14px;
                               border-color: #ced4da !important; border-left: 0 !important; background: #fff !important; }
    #elasticSearchForm .input-group:focus-within #term,
    #elasticSearchForm .input-group:focus-within .ai-mode-wrap,
    #elasticSearchForm .input-group:focus-within button[type=submit] { border-color: #2865A3 !important; }
    .ai-mode-wrap { display: flex; align-items: center; padding: 0 4px; background: #fff;
                    border-top: 1px solid #ced4da; border-bottom: 1px solid #ced4da; }
    .ai-mode-wrap[hidden] { display: none; }
    .ai-mode-button { display: flex; align-items: center; gap: 5px; padding: 4px 12px; border: 0; border-radius: 14px;
                      background: #e3edf8; color: #1e4f82; font-size: 13px; font-weight: bold; line-height: 1.3;
                      white-space: nowrap; cursor: pointer; }
    .ai-mode-button:hover, .ai-mode-button:focus { background: #cfe0f2; outline: none; }
    .ai-mode-button:focus-visible { box-shadow: 0 0 0 2px rgba(40, 101, 163, 0.4); }
    @media (max-width: 768px) {
        .ai-mode-label { display: none; }
        .ai-mode-button { padding: 4px 9px; }
    }
</style>
   <div class="row" style="width: 100%;float: right;margin:0;">
       <div class="col-12 col-md-9">
       <form name="elasticSearchForm"  action="/rgdweb/elasticResults.html" id="elasticSearchForm" role="search" method="post">
           <%
               if(RgdContext.isProduction()){
           %>
           <input type="hidden" name="log" value="true"/>
           <%}%>
          <input type="hidden" name="category" id="category" value="General"/>
    <div class="input-group">

        <input class="form-control border-end-0 border searchgroup" type="text"  id="term" name="term" value="${model.term}">
        <span class="input-group-append ai-mode-wrap" id="aiModeWrap" hidden>
                <button class="ai-mode-button" id="aiModeButton" type="button" title="Ask RatChat (opens in a new tab)">
                    <span aria-hidden="true">&#10022;</span><span class="ai-mode-label">AI Mode</span>
                </button>
            </span>
        <span class="input-group-append">
                <button class="btn btn-outline-secondary bg-light border-start-0 border  ms-n3" type="submit">
                    <i class="fa fa-search"></i>
                </button>
            </span>

    </div>
       </form>
       </div>
       <div class="col-12 col-md-3">

               <small class="form-text text-muted"><a href="/rgdweb/generator/list.html" >Advanced Search (OLGA)</a></small>


       </div>
   </div>
<script>
    (function () {
        // A page shown inside another one (the ontology browser's mode=iframe) gets no button.
        if (window.self !== window.top) return;
        var wrap = document.getElementById('aiModeWrap');
        var button = document.getElementById('aiModeButton');
        var input = document.getElementById('term');
        if (!wrap || !button || !input) return;
        var path = window.location.pathname.replace(/^\/rgdweb\//, '');
        var params = new URLSearchParams(window.location.search);
        // [path, page type, ID parameter, page type when the ID is absent]
        var pages = [
            [/^report\/gene\/main\.html$/, 'gene-report', 'id'],
            [/^report\/qtl\/main\.html$/, 'qtl-report', 'id'],
            [/^report\/strain\/main\.html$/, 'strain-report', 'id'],
            [/^report\/reference\/main\.html$/, 'reference-report', 'id'],
            [/^report\/marker\/main\.html$/, 'marker-report', 'id'],
            [/^report\/cellline\/main\.html$/, 'cellline-report', 'id'],
            [/^ontology\/(annot|view)\.html$/, 'ontology-report', 'acc_id', 'ontology-browser'],
            [/^ontology\/search\.html$/, 'ontology-browser'],
            [/^pathway\/pathwayRecord\.html$/, 'pathway-diagram', 'acc_id'],
            [/^search\/genes\.html$/, 'gene-search'],
            [/^search\/markers\.html$/, 'marker-search'],
            [/^elasticResults\.html$/, 'site-search'],
            [/^generator\//, 'olga'],
            [/^(gviewer\/|ga\/gviewer\.html$)/, 'gviewer'],
            [/^phenominer\//, 'phenominer'],
            [/^enrichment\//, 'moet'],
            [/^portal\//, 'disease-portal']
        ];
        var context = '';
        for (var i = 0; i < pages.length; i++) {
            if (!pages[i][0].test(path)) continue;
            var id = pages[i][2] ? params.get(pages[i][2]) : null;
            var page = id || !pages[i][3] ? pages[i][1] : pages[i][3];
            context = 'page=' + encodeURIComponent(page)
                + (id && page === pages[i][1] ? '&id=' + encodeURIComponent(id) : '');
            button.title = 'Ask RatChat about this page (opens in a new tab)';
            // Name the record or tool in the tooltip, as RatChat will see it.
            fetch('/assistant/chat-openai/page-context?' + context)
                .then(function (r) { return r.ok ? r.json() : {}; })
                .then(function (d) {
                    if (d.subject) button.title = 'Ask RatChat about ' + d.subject + ' or this page (opens in a new tab)';
                    else if (d.label) button.title = 'Ask RatChat about the ' + d.label + ' (opens in a new tab)';
                })['catch'](function () {});
            break;
        }
        // An empty box opens RatChat with just the page's context and its suggested questions.
        button.addEventListener('click', function () {
            var q = input.value.trim().substring(0, 1000);
            var query = [context, q ? 'q=' + encodeURIComponent(q) : ''].filter(Boolean).join('&');
            window.open('/assistant/chat' + (query ? '?' + query : ''), '_blank', 'noopener');
        });
        wrap.hidden = false;
    })();
</script>
