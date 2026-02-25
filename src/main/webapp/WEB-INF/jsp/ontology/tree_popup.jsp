<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.ontology.OntBrowser" %>
<!DOCTYPE html>
<link href="/rgdweb/css/ontology.css" rel="stylesheet" type="text/css" >
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.12/dist/vue.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/axios/1.1.3/axios.js"></script>

<%
    OntologyXDAO xdao = new OntologyXDAO();
    boolean nestedWindows = false;

    if (request.getParameter("nestedWindows") != null) {
        nestedWindows=true;
    }

    // if acc_id parameter is not given, use 'ont' parameter to determine ontology root term
    // for browsing
    response.setHeader("Access-Control-Allow-Origin", "*.mcw.edu");
    String accId = request.getParameter("acc_id");
    if( Utils.isStringEmpty(accId) ) {
        String ontId = request.getParameter("ont");
        if( !Utils.isStringEmpty(ontId) ) {

            // try a term parameter
            String termName = request.getParameter("term");
            if( !Utils.isStringEmpty(termName) ) {
                Term term = xdao.getTermByTermName(termName, ontId);
                if( term!=null )
                    accId = term.getAccId();
            }

            if( Utils.isStringEmpty(accId) )
                accId = xdao.getRootTerm(ontId);
        }
    }

    // url for browsing the tree should include 'sel_acc_id' and 'sel_term' parameters if available
    String selAccId = request.getParameter("sel_acc_id");
    String selTerm = request.getParameter("sel_term");
    String termName="";
    if (selTerm !=null && !selTerm.equals("")) {
        termName = xdao.getTerm(accId).getTerm();
    }
    String curationTool = request.getParameter("curation");
    String url = "/rgdweb/ontology/view.html?mode=popup";
    if( !Utils.isStringEmpty(selAccId) )
        url += "&sel_acc_id="+selAccId;
    if( !Utils.isStringEmpty(selTerm) )
        url += "&sel_term="+selTerm;
    if (!Utils.isStringEmpty(curationTool))
        url += "&curation="+curationTool;
    if( Utils.NVL(request.getParameter("dia"),"0").equals("1") ) {
        url += "&dia=1";
    }
%>

<style>
    .ontologySearchInputBox {
        font-family:arial;
        cursor:pointer;
        postion:absolute;
        display:none;
        overflow:scroll;
        height:400px;
        width:605px;
        border: 1px solid black;"
        display:none;
        top:0;
        left:0;
        background-color:white;
    }
    .ontologySearchInputBox hover {
        diplay:block;
    }
</style>

<script>
    function postMessage(accIdAndTerm, str) {
        var returnArr = accIdAndTerm.split("|");
        var accId = returnArr[0];
        var term = returnArr[1];

        try {
            window.opener.postMessage(window.opener.document.getElementById('<%=request.getParameter("sel_acc_id")%>'),accId, term);
        }catch {
        }

        window.opener.document.getElementById('<%=request.getParameter("sel_acc_id")%>').value=accId;
        window.opener.document.getElementById('<%=request.getParameter("sel_term")%>').value=term;
        <% if (selTerm != null && selTerm.toLowerCase().startsWith("uberon")) { %>
        window.opener.document.getElementById('<%=request.getParameter("sel_term")%>').dispatchEvent(new Event('input', { bubbles: true }));
        <% } %>

        window.close();

    }


    //       ".document.getElementById('"+this.opener_sel_acc_id+"').value=accId;\n");

</script>

<% if (nestedWindows) { %>

<div id="ontSearchBox" >

<table align="center" border="0">
    <tr>
        <td>
            Search:
        </td>
        <td>
            <input  id="termSearch" :placeholder="examples" v-model="searchTerm" size="60" style="border: 3px solid black;height:30px;width:600px;" v-on:input="search()"/></td>
    </td>
    </tr>
    <tr>
        <td>
            &nbsp;
        </td>
    <td>
        <div id="searchResult" class="ontologySearchInputBox" >
            <h3 v-if="optionsNotEmpty"><br>&nbsp;0 Records found for Term: <b>{{searchTerm}}</b></h3>
            <table>
                <tr>
                    <td align="right">
                        <a @click="hideSearchWindow()"  href="#">Close Search Window</a>&nbsp;&nbsp;&nbsp;
                    </td></tr>
                <tr v-for="(key, value) in options" >
                    <td style="font-size:16px;" align="left"><div @click="selectByTermId(value)"><span style="font-weight:500;font-family:arial;">{{key}}</span>&nbsp;({{value}}}</div></td>
                </tr>
            </table>
        </div>

    </td>
</tr>


        </td>
    </tr>
</table>
</div>
<% } %>

<%
    if (nestedWindows) {
    //if (request.getParameter("nestedWindows") != null) {
%>

    <iframe style="height:500px; width:100%;" id="treeWindow" src="/rgdweb/ontology/view.html?mode=iframe&ont=<%=request.getParameter("ont")%>&sel_term=<%=selTerm%>&sel_acc_id=<%=selAccId%>&curationTool=1&acc_id=<%=accId%>">
<% } %>

<%
    OntBrowser ontBrowser = new OntBrowser();
    ontBrowser.setAcc_id( accId, request );
    ontBrowser.setUrl(url);
    ontBrowser.setOffset(request.getParameter("offset"));
    ontBrowser.setOpener_sel_acc_id(selAccId);
    ontBrowser.setOpener_sel_term(selTerm);
    ontBrowser.setFilter(request.getParameter("filter"));

    ontBrowser.doTag(request, out);

%>

<% if (nestedWindows) {%>
    </iframe>
<% } %>

<script>
    var div = '#ontSearchBox';

    var host = window.location.protocol + window.location.host;

    if (window.location.host.indexOf('localhost') > -1) {
        host =  'http://localhost:8080';
    } else if (window.location.host.indexOf('dev.rgd') > -1) {
        host = window.location.protocol + '//dev.rgd.mcw.edu';
    }else if (window.location.host.indexOf('test.rgd') > -1) {
        host = window.location.protocol + '//test.rgd.mcw.edu';
    }else if (window.location.host.indexOf('pipelines.rgd') > -1) {
        host = window.location.protocol + '//pipelines.rgd.mcw.edu';
    }else {
        host = window.location.protocol + '//rgd.mcw.edu';
    }

    var v = new Vue({
        el: div,
        data: {
            optionsNotEmpty:  false,
            title: "",
            searchTerm: "",
            hostName: host,
            options:{},
            symbolHash: {},
            keyMap: {},
            currentOnt: "<%=request.getParameter("ont")%>",
            examples: "",
            axiosRequest: new AbortController(),
        },
        methods: {
            hideSearchWindow: function() {
                document.getElementById("searchResult").style.display="none";
                v.searchTerm="";
            },

            selectByTermId: function(val) {
                document.getElementById("searchResult").style.display="none";

                var url = "/rgdweb/ontology/view.html?mode=iframe&ont=" + v.currentOnt + "&sel_term=<%=request.getParameter("sel_term")%>&sel_acc_id=<%=request.getParameter("sel_acc_id")%>&curationTool=1&acc_id=" + val;
                //document.getElementById("treeWindow").location.href=url;

                document.getElementById("treeWindow").src= url;

                },
            search: function () {

                this.axiosRequest.abort();

                v.options={};

                v.optionsNotEmpty = true;



                var subCat = 'RS:%20Rat%20Strains';
                if (this.currentOnt === "MMO") {
                    var subCat = 'MMO:%20Measurement%20Methods';

                }else if (this.currentOnt === "XCO") {
                    var subCat = 'XCO:%20Experimental%20Condition';

                }else if (this.currentOnt === "CMO") {
                    var subCat = 'CMO:%20Clinical%20Measurement';
                }
                else if (this.currentOnt === "UBERON"){
                    var subCat = 'UBERON:%20Cross-Species%20Anatomy';
                }
                else if (this.currentOnt === "CL"){
                    var subCat = 'CL:%20Cell%20Ontology';
                }
                else if (this.currentOnt === "VT"){
                    var subCat = 'VT:%20Vertebrate%20Trait%20Ontology';
                }


                    axios
                        .get(this.hostName + '/rgdweb/phenominerTermSearch.html?term=' + v.searchTerm + '&category=Ontology&subCat=' + subCat + '&species=&cat1=General&sp1=&postCount=1',
                            {
                                species: "hell",
                            })
                        .then(function (response) {
                            for (var searchKey in response.data) {
                                v.options=response.data;
                                v.optionsNotEmpty = false;

                                document.getElementById("searchResult").style.display="block";
                            }
                        })
                        .catch(function (error) {
                            console.log(error)
                            v.errored = true
                        })


            },

            updateConditionBox: function() {
                if (JSON.stringify(v.selectedConditions) === "{}") {
                    return;
                }
                v.block();
                document.getElementById("conditionMessageTable").style.visibility="hidden";
                document.getElementById("conditionMessageUpdate").style.display="block";

                axios
                    .get(this.hostName + '/rgdweb/phenominer/treeXml.html?ont=XCO&sex=both&species=3&terms=' + v.getAllTerms(),
                        {
                            species: "hell",
                        })
                    .then(function (response) {
                        var parser = new DOMParser();
                        xmlDoc = parser.parseFromString(response.data + "", "text/xml");

                        var root = xmlDoc.getRootNode();
                        //var root = xmlDoc.getElementsByTagName("tree");
                        var childNodes = root.getElementsByTagName("item");

                        var children = v.getLeafNodes(childNodes);

                        //find out if a selection is now gone
                        var tmpHash = {};
                        for (var key in v.selectedConditions) {
                            var found=false;
                            for (let i = 0; i < children.length; i++) {
                                let item = children[i];
                                var idArr = (item.getAttribute("id") + "").split("_");
                                var id = idArr[0];

                                if (v.selectedConditions[key] === id) {
                                    tmpHash[item.getAttribute("text")] = id;
                                    found=true;
                                    // v.selectedStrains[key] == null;
                                    //break;
                                }
                            }
                            if (!found) {
                                if (key.indexOf("(0)") > 0) {
                                    tmpHash[key] = v.selectedConditions[key];
                                }else {
                                    tmpHash[key + "(0)"] = v.selectedConditions[key];
                                }

                            }
                        }


                        v.selectedConditions = {};
                        for (key in tmpHash) {
                            if (key.indexOf('(0)') < 0) {
                                v.selectedConditions[key] = tmpHash[key];
                            }
                        }
                        for (key in tmpHash) {
                            if (key.indexOf('(0)') < 0) {
                            }else {
                                v.selectedConditions[key] = tmpHash[key];
                            }
                        }

                        //v.selectedConditions = tmpHash;
                        document.getElementById("conditionMessageTable").style.visibility="visible";
                        document.getElementById("conditionMessageUpdate").style.display="none";
                        v.unblock();

                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })

            },


        },
    })


    setTimeout(v.init, 10);


</script>
