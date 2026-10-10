<%@ page import="edu.mcw.rgd.datamodel.TestPlanItem" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%
    String pageTitle = "PostgreSQL Site Test Plan";
    String headContent = "";
    String pageDescription = "Every page and tool on the PostgreSQL build, checked by a person and signed off before production switches.";

    List<TestPlanItem> items = (List<TestPlanItem>) request.getAttribute("items");
    Map<String, String> testers = (Map<String, String>) request.getAttribute("testers");
    String login = (String) request.getAttribute("login");
    String historyFor = (String) request.getAttribute("historyFor");
    List<String[]> history = (List<String[]>) request.getAttribute("history");
    String msg = request.getParameter("msg");
    SimpleDateFormat df = new SimpleDateFormat("MMM d, yyyy h:mm a");

    // summary counts
    Map<String, Integer> byStatus = new LinkedHashMap<>();
    for (String s : TestPlanItem.STATUSES) byStatus.put(s, 0);
    int signed = 0, unassigned = 0;
    Map<String, int[]> byTester = new TreeMap<>();
    List<String> areas = new ArrayList<>();
    for (TestPlanItem i : items) {
        byStatus.merge(i.getStatus(), 1, Integer::sum);
        if (i.getSignedBy() != null) signed++;
        if (i.getAssignee() == null) unassigned++;
        else {
            int[] c = byTester.computeIfAbsent(i.getAssignee(), k -> new int[2]);
            c[0]++;
            if (i.getSignedBy() != null) c[1]++;
        }
        if (!areas.contains(i.getArea())) areas.add(i.getArea());
    }
    Map<String, String> statusClass = new HashMap<>();
    statusClass.put("Not started", "none"); statusClass.put("In progress", "prog"); statusClass.put("Passed", "pass");
    statusClass.put("Failed", "fail"); statusClass.put("Blocked", "block");
%>
<%!
    String h(String s) { return s == null ? "" : StringEscapeUtils.escapeHtml4(s); }
    String who(Map<String, String> testers, String login) {
        if (login == null) return "";
        String n = testers.get(login);
        return h(n == null ? login : n);
    }
%>
<%@ include file="/common/headerarea.jsp" %>

<style>
    .tp { --ink:#1b2a33; --muted:#5d6f7a; --line:#d9e1e6; --soft:#eef3f6; --accent:#0f6e7c;
          --pass:#2f7d4a; --pass-bg:#e3f2e8; --fail:#b3362b; --fail-bg:#fbe7e4; --block:#9a6a00; --block-bg:#fbf0d5;
          --prog:#2d5fa8; --prog-bg:#e3ecf9; --none:#7a8a94; --none-bg:#edf1f3; --signed:#5b3fa0; --signed-bg:#ece6f8;
          color:var(--ink); font-size:14px; max-width:1200px; margin:0 auto; padding:8px 16px 40px; }
    .tp h1 { margin:0 0 4px; font-size:24px; }
    .tp .sub { color:var(--muted); margin:0 0 12px; }
    .tp .msg { background:var(--block-bg); border-radius:6px; padding:8px 12px; margin:8px 0; }
    .tp .who { float:right; color:var(--muted); }
    .tp .summary { border:1px solid var(--line); border-radius:8px; padding:12px; margin:12px 0; }
    .tp .bar { display:flex; height:12px; border-radius:6px; overflow:hidden; background:var(--none-bg); margin-bottom:8px; }
    .tp .bar span { display:block; height:100%; }
    .tp .legend, .tp .people { display:flex; flex-wrap:wrap; gap:4px 16px; }
    .tp .people { margin-top:8px; gap:6px; }
    .tp .chip { background:var(--soft); border-radius:12px; padding:2px 10px; font-size:13px; cursor:pointer; border:0; }
    .tp .dot { display:inline-block; width:9px; height:9px; border-radius:50%; margin-right:5px; }
    .tp .filters { position:sticky; top:0; background:#fff; z-index:5; display:flex; flex-wrap:wrap; gap:8px; padding:8px 0; border-bottom:1px solid var(--line); }
    .tp .filters input[type=search] { flex:1 1 220px; }
    .tp .filters input, .tp .filters select { padding:5px 8px; border:1px solid var(--line); border-radius:6px; }
    .tp .area { margin-top:20px; }
    .tp .areahead { display:flex; align-items:baseline; gap:12px; border-bottom:2px solid var(--ink); padding-bottom:4px; }
    .tp .areahead h2 { margin:0; font-size:18px; }
    .tp .areahead .count { color:var(--muted); font-size:13px; }
    .tp .row { display:grid; grid-template-columns:minmax(0,1fr) 190px 150px 200px; gap:10px; align-items:center; padding:8px 0; border-bottom:1px solid var(--line); }
    .tp .row .name { min-width:0; }
    .tp .row .name a.toggle { font-weight:bold; color:var(--ink); text-decoration:none; cursor:pointer; }
    .tp .path { font-family:Menlo,Consolas,monospace; font-size:12px; color:var(--muted); overflow-wrap:anywhere; }
    .tp .links a { font-size:12px; margin-right:10px; }
    .tp .tag { font-size:10px; text-transform:uppercase; letter-spacing:.04em; background:var(--soft); color:var(--muted); border-radius:4px; padding:1px 5px; margin-left:6px; }
    .tp select.status { border-radius:12px; padding:3px 8px; font-weight:bold; border:1px solid transparent; width:100%; }
    .tp .s-none { background:var(--none-bg); color:var(--none); } .tp .s-prog { background:var(--prog-bg); color:var(--prog); }
    .tp .s-pass { background:var(--pass-bg); color:var(--pass); } .tp .s-fail { background:var(--fail-bg); color:var(--fail); }
    .tp .s-block { background:var(--block-bg); color:var(--block); }
    .tp .pill { display:inline-block; border-radius:12px; padding:3px 10px; font-weight:bold; font-size:13px; }
    .tp .signed { background:var(--signed-bg); color:var(--signed); border-radius:6px; padding:4px 8px; font-size:13px; }
    .tp .signed small { display:block; color:var(--muted); }
    .tp button.btn { border:1px solid var(--line); background:#fff; border-radius:6px; padding:3px 10px; cursor:pointer; }
    .tp button.primary { background:var(--accent); border-color:var(--accent); color:#fff; font-weight:bold; }
    .tp button.link { border:0; background:none; color:var(--accent); text-decoration:underline; padding:0; cursor:pointer; }
    .tp .muted { color:var(--muted); font-size:13px; }
    .tp .detail { grid-column:1/-1; background:var(--soft); border-radius:8px; padding:12px; display:none; }
    .tp .detail.open { display:block; }
    .tp .detail h3 { font-size:11px; text-transform:uppercase; letter-spacing:.05em; color:var(--muted); margin:8px 0 2px; }
    .tp .detail p { margin:0; max-width:75ch; }
    .tp .detail textarea { width:100%; min-height:70px; }
    .tp .hist { margin:4px 0 0; padding-left:18px; color:var(--muted); }
    @media (max-width:820px) { .tp .row { grid-template-columns:1fr 1fr; } .tp .row .name { grid-column:1/-1; } }
</style>

<div class="tp">
    <div class="who">
        <% if (login != null) { %>Signed in as <b><%=who(testers, login)%></b> (<%=h(login)%>)
        <% } else { %><a href="<%=h((String) request.getAttribute("signInUrl"))%>">Sign in with GitHub</a> to assign, record results and sign off
        <% } %>
    </div>
    <h1>PostgreSQL Site Test Plan</h1>
    <p class="sub">Every page and tool on the PostgreSQL build, checked by a person and signed off before production switches.
        Test on this server; compare with <a href="https://rgd.mcw.edu" target="_blank">rgd.mcw.edu</a> (curation items: with the current Oracle curation tools).</p>

    <% if (msg != null) { %><div class="msg"><%=h(msg)%></div><% } %>

    <div class="summary">
        <div class="bar">
            <% String[] colors = {"var(--none)", "var(--prog)", "var(--pass)", "var(--fail)", "var(--block)"};
               int ci = 0;
               for (Map.Entry<String, Integer> e : byStatus.entrySet()) {
                   if (e.getValue() > 0) { %><span style="width:<%=100.0 * e.getValue() / items.size()%>%;background:<%=colors[ci]%>" title="<%=e.getKey()%>: <%=e.getValue()%>"></span><% }
                   ci++;
               } %>
        </div>
        <div class="legend">
            <span><b><%=signed%> of <%=items.size()%></b> signed off</span>
            <% ci = 0; for (Map.Entry<String, Integer> e : byStatus.entrySet()) { %>
            <span><i class="dot" style="background:<%=colors[ci++]%>"></i><%=e.getKey()%> <b><%=e.getValue()%></b></span>
            <% } %>
        </div>
        <div class="people">
            <% for (Map.Entry<String, int[]> e : byTester.entrySet()) { %>
            <button class="chip" type="button" onclick="filterWho('<%=h(e.getKey())%>')"><%=who(testers, e.getKey())%> <b><%=e.getValue()[1]%>/<%=e.getValue()[0]%></b></button>
            <% } %>
            <span class="chip" style="cursor:default">Unassigned <b><%=unassigned%></b></span>
        </div>
    </div>

    <div class="filters">
        <input id="q" type="search" placeholder="Filter by page, tool or URL" aria-label="Filter">
        <select id="fArea" aria-label="Area"><option value="">All areas</option>
            <% for (String a : areas) { %><option><%=h(a)%></option><% } %></select>
        <select id="fStatus" aria-label="Status"><option value="">Any status</option>
            <% for (String s : TestPlanItem.STATUSES) { %><option><%=s%></option><% } %>
            <option value="signed">Signed off</option><option value="unsigned">Not signed off</option></select>
        <select id="fWho" aria-label="Assignee"><option value="">Everyone</option>
            <% if (login != null) { %><option value="<%=h(login)%>">Assigned to me</option><% } %>
            <option value="-">Unassigned</option>
            <% for (String t : byTester.keySet()) { %><option value="<%=h(t)%>"><%=who(testers, t)%></option><% } %></select>
        <label class="muted"><input type="checkbox" id="fCur" checked> Curation tools</label>
    </div>

    <% for (String area : areas) {
        int total = 0, areaSigned = 0;
        for (TestPlanItem i : items) if (i.getArea().equals(area)) { total++; if (i.getSignedBy() != null) areaSigned++; }
    %>
    <section class="area" data-area="<%=h(area)%>">
        <div class="areahead"><h2><%=h(area)%></h2><span class="count"><%=areaSigned%> of <%=total%> signed off</span></div>
        <% for (TestPlanItem i : items) {
            if (!i.getArea().equals(area)) continue;
            String id = h(i.getItemId());
            boolean mine = login != null && login.equals(i.getAssignee());
            boolean open = i.getItemId().equals(historyFor);
        %>
        <div class="row" id="<%=id%>" data-area="<%=h(area)%>" data-status="<%=h(i.getStatus())%>" data-signed="<%=i.getSignedBy() != null ? "y" : "n"%>"
             data-who="<%=h(i.getAssignee() == null ? "-" : i.getAssignee())%>" data-cur="<%=i.isCuration() ? "y" : "n"%>"
             data-text="<%=h((i.getName() + " " + i.getPath() + " " + (i.getCovers() == null ? "" : i.getCovers()) + " " + area).toLowerCase())%>">
            <div class="name">
                <a class="toggle" onclick="toggle('<%=id%>')"><%=h(i.getName())%></a><% if (i.isCuration()) { %><span class="tag">curation</span><% } %>
                <div class="path"><%=h(i.getPath())%></div>
                <div class="links"><a href="<%=h(i.getPath())%>" target="_blank">Test &#8599;</a><% if (!i.isNoCompare()) { %><a href="https://rgd.mcw.edu<%=h(i.getPath())%>" target="_blank">Production &#8599;</a><% } %></div>
            </div>

            <div>
                <% if (login != null) { %>
                <form method="post" action="testPlan.html">
                    <input type="hidden" name="itemId" value="<%=id%>"><input type="hidden" name="action" value="assign">
                    <select name="assignee" onchange="this.form.submit()" aria-label="Assignee for <%=h(i.getName())%>">
                        <option value=""><%=i.getAssignee() == null ? "Assign..." : "(clear)"%></option>
                        <% for (Map.Entry<String, String> t : testers.entrySet()) { %>
                        <option value="<%=h(t.getKey())%>"<%=t.getKey().equals(i.getAssignee()) ? " selected" : ""%>><%=h(t.getValue())%></option>
                        <% } %>
                    </select>
                </form>
                <% if (i.getAssignee() == null) { %>
                <form method="post" action="testPlan.html"><input type="hidden" name="itemId" value="<%=id%>"><input type="hidden" name="action" value="take"><button class="link" type="submit">Take this one</button></form>
                <% } %>
                <% } else { %>
                <span class="muted"><%=i.getAssignee() == null ? "Unassigned" : who(testers, i.getAssignee())%></span>
                <% } %>
            </div>

            <div>
                <% if (mine) { %>
                <form method="post" action="testPlan.html" onsubmit="return needsNote(this)">
                    <input type="hidden" name="itemId" value="<%=id%>"><input type="hidden" name="action" value="status"><input type="hidden" name="notes" value="">
                    <select name="status" class="status s-<%=statusClass.get(i.getStatus())%>" onchange="if (needsNote(this.form)) this.form.submit()" aria-label="Status of <%=h(i.getName())%>">
                        <% for (String s : TestPlanItem.STATUSES) { %><option<%=s.equals(i.getStatus()) ? " selected" : ""%>><%=s%></option><% } %>
                    </select>
                </form>
                <% } else { %>
                <span class="pill s-<%=statusClass.get(i.getStatus())%>"><%=h(i.getStatus())%></span>
                <% } %>
            </div>

            <div>
                <% if (i.getSignedBy() != null) { %>
                <div class="signed">Signed off by <b><%=who(testers, i.getSignedBy())%></b><small><%=i.getSignedDate() == null ? "" : df.format(i.getSignedDate())%></small>
                    <% if (login != null && (login.equals(i.getSignedBy()) || mine)) { %>
                    <form method="post" action="testPlan.html" style="display:inline"><input type="hidden" name="itemId" value="<%=id%>"><input type="hidden" name="action" value="withdraw"><button class="link" type="submit">Undo</button></form>
                    <% } %>
                </div>
                <% } else if (mine && "Passed".equals(i.getStatus())) { %>
                <form method="post" action="testPlan.html" onsubmit="return confirm('Sign off: I tested this page and it matches production.')">
                    <input type="hidden" name="itemId" value="<%=id%>"><input type="hidden" name="action" value="signoff">
                    <button class="btn primary" type="submit">Sign off</button>
                </form>
                <% } else { %>
                <span class="muted"><%="Passed".equals(i.getStatus()) ? "Waiting for the tester" : "Pass first, then sign off"%></span>
                <% } %>
            </div>

            <div class="detail<%=open ? " open" : ""%>" id="d-<%=id%>">
                <h3>What to check</h3><p><%=h(i.getCheckText())%></p>
                <h3>Every page</h3><p>Loads without an error or blank section; data matches production (allow for records added since the 2026-09-14 data load); links and downloads stay on this server; nothing takes more than 10 seconds.</p>
                <% if (i.getCovers() != null) { %><h3>Also covers</h3><p class="path"><%=h(i.getCovers())%></p><% } %>
                <h3>Notes</h3>
                <% if (mine) { %>
                <form method="post" action="testPlan.html">
                    <input type="hidden" name="itemId" value="<%=id%>"><input type="hidden" name="action" value="notes">
                    <textarea name="notes" id="n-<%=id%>" placeholder="What you saw: the URL, the ID you used, the error or the difference from production."><%=h(i.getNotes())%></textarea>
                    <button class="btn" type="submit">Save notes</button>
                </form>
                <% } else { %>
                <p><%=i.getNotes() == null ? "<span class=\"muted\">No notes yet.</span>" : h(i.getNotes())%></p>
                <% } %>
                <h3>History</h3>
                <% if (open && history != null) {
                    if (history.isEmpty()) { %><p class="muted">No changes yet.</p><% }
                    else { %><ul class="hist"><% for (String[] e : history) { %><li><%=h(e[0])%> &middot; <%=who(testers, e[1])%> <%=h(e[2])%></li><% } %></ul><% }
                } else { %>
                <a href="testPlan.html?history=<%=id%>#<%=id%>">Show history</a>
                <% } %>
            </div>
        </div>
        <% } %>
    </section>
    <% } %>
</div>

<script>
    function toggle(id) { document.getElementById('d-' + id).classList.toggle('open'); }

    // Failed or Blocked needs a note; ask for it and send it with the status
    function needsNote(form) {
        var s = form.status.value;
        if (s !== 'Failed' && s !== 'Blocked') return true;
        var existing = document.getElementById('n-' + form.itemId.value);
        var note = window.prompt(s + ': what went wrong? Include the URL and the ID you used.', existing ? existing.value : '');
        if (note === null || note.trim() === '') { location.reload(); return false; }
        form.notes.value = note;
        return true;
    }

    var prefsKey = 'rgdTestPlanFilters';
    function applyFilters() {
        var q = document.getElementById('q').value.trim().toLowerCase(),
            a = document.getElementById('fArea').value, s = document.getElementById('fStatus').value,
            w = document.getElementById('fWho').value, cur = document.getElementById('fCur').checked;
        document.querySelectorAll('.tp .row').forEach(function (r) {
            var d = r.dataset, show = true;
            if (!cur && d.cur === 'y') show = false;
            if (a && d.area !== a) show = false;
            if (s === 'signed' && d.signed !== 'y') show = false;
            else if (s === 'unsigned' && d.signed === 'y') show = false;
            else if (s && s !== 'signed' && s !== 'unsigned' && d.status !== s) show = false;
            if (w && d.who !== w) show = false;
            if (q && d.text.indexOf(q) < 0) show = false;
            r.style.display = show ? '' : 'none';
        });
        document.querySelectorAll('.tp section.area').forEach(function (sec) {
            var any = Array.prototype.some.call(sec.querySelectorAll('.row'), function (r) { return r.style.display !== 'none'; });
            sec.style.display = any ? '' : 'none';
        });
        try { localStorage.setItem(prefsKey, JSON.stringify({q: q, a: a, s: s, w: w, cur: cur})); } catch (e) {}
    }
    function filterWho(w) { document.getElementById('fWho').value = w; applyFilters(); }
    ['q', 'fArea', 'fStatus', 'fWho', 'fCur'].forEach(function (id) {
        var el = document.getElementById(id);
        el.addEventListener(id === 'q' ? 'input' : 'change', applyFilters);
    });
    try {
        var p = JSON.parse(localStorage.getItem(prefsKey) || '{}');
        if (p.q) document.getElementById('q').value = p.q;
        if (p.a) document.getElementById('fArea').value = p.a;
        if (p.s) document.getElementById('fStatus').value = p.s;
        if (p.w) document.getElementById('fWho').value = p.w;
        if (p.cur === false) document.getElementById('fCur').checked = false;
    } catch (e) {}
    applyFilters();
</script>

<%@ include file="/common/footerarea.jsp" %>
