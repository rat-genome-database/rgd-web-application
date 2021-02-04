<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.datamodel.RGDNewsConf" %>
<%@ page import="edu.mcw.rgd.dao.impl.RGDNewsConfDAO" %>
<%@ page import="edu.mcw.rgd.edit.NewsConferenceEditController" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>

<script src="https://cdn.jsdelivr.net/npm/vue@2.6.12/dist/vue.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" type="text/css">
<%
    RGDNewsConfDAO ndao = new RGDNewsConfDAO();

    String pageTitle = "Edit Object";
    String headContent = "";
    String pageDescription = "";
    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd", java.util.Locale.ENGLISH);
    Date d1 = new Date();


%>
<%@ include file="/common/headerarea.jsp"%>

<script type="text/javascript" src="/rgdweb/js/util.js"></script>

<link rel="stylesheet" href="/rgdweb/js/windowfiles/dhtmlwindow.css" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/windowfiles/dhtmlwindow.js">
    /***********************************************
     * DHTML Window Widget- � Dynamic Drive (www.dynamicdrive.com)
     * This notice must stay intact for legal use.
     * Visit http://www.dynamicdrive.com/ for full source code
     ***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/js/lookup.js"></script>
<html>

<h1>RGD News and Conference Editor</h1>

<h3>Add a News article, Conference, or Video Tutorial</h3>

<div id="insertApp">
    <table id="insertTable">
        <tr><td class="label">Release Date</td><td><input type="date" id="date" value="<%=format.format(d1)%>" placeholder="yyyy-MM-dd" ></td>
            <td>Ex: yyyy-MM-dd, MM/dd/yyyy</td></tr>
        <tr><td class="label">Display Text</td><td><input v-model="display" type="text" id="displayText" name="words" size="75"></td></tr>
        <tr><td class="label">Redirect Link</td><td><input v-model="hyperlink" type="url" id="redirectLink" size="75"></td></tr>
        <tr><td class="label">Content</td><td><select id="contentList">
                <option value="NEWS">NEWS</option>
                <option value="CONFERENCE">CONFERENCE</option>
                <option value="VIDEO">VIDEO</option>
            </select></td></tr>
        <tr><td class="label">ALERT Message</td><td><input v-model="strong" type="text" id="strongText" placeholder="(NEW) or (ONLINE)" size="75" maxlength="50"></td></tr>
            <td><button v-on:click="submitData">Submit</button></td>

        <tr><td><button v-on:click="showExample">Test View</button></td><td>{{message}}</td></tr>

    </table>

</div>

<br>
<h3>Edit News Articles, Conferences, or Video Tutorials</h3>

<div>
    <button v-on:click="redirect" id="editArticles">Edit Articles</button>
    <select id="editContent">
        <option value="NEWS">NEWS</option>
        <option value="CONFERENCE">CONFERENCE</option>
        <option value="VIDEO">VIDEO</option>
    </select>
</div>

<script>
    var insertApp = new Vue({
        el: '#insertApp',
        data: {
            display: '',
            hyperlink: '',
            type: '',
            strong: '',
            date: '',
            message: undefined
        },
        methods: {
           submitData: function () {
               //alert(this.display + this.hyperlink);
               const url = new URL(window.location.href);
               const urlParams = new URLSearchParams(url.search);
               var newUrl = window.location.href.split('&display')[0];

               this.display = document.getElementById("displayText").value;
               this.hyperlink = document.getElementById("redirectLink").value;
               this.type = document.getElementById("contentList").value;
               this.strong = document.getElementById("strongText").value;
               this.date = document.getElementById("date").value;

               if(this.date === '' && (this.type=='NEWS' || this.type=='CONFERENCE')) {
                   alert("Please include a date.");
                   return;
               }
               if (this.display === '' || this.hyperlink === ''){
                   alert("Please include display text or a redirect link.")
                   return;
               }

               newUrl += ('&display=' + this.display);
               newUrl += ('&hyperlink=' + this.hyperlink);
               newUrl += ('&type=' + this.type);
               newUrl += ('&strong='+this.strong);
               newUrl += ('&date='+this.date)
               //alert(newUrl);

               window.location.href = newUrl.toString();
           },
            showExample: function () {
                //this.message = '<td><p href="'+this.hyperlink+'">'+this.display +' '+this.strong+'</p></td>'
                if(document.getElementById("contentList").value != "VIDEO" ){
                    var dateEntered = new Date(document.getElementById("date").value);
                    var month = dateEntered.getMonth() + 1;

                    if (month.toString().length == 1) {
                        var day = dateEntered.getDate() + 1;
                        var year = dateEntered.getFullYear();
                        var newDate = "0" + month + "/" + day + "/" + year + " - ";
                    } else {

                    var day = dateEntered.getDate() + 1;
                    var year = dateEntered.getFullYear();
                    var newDate = month + "/" + day + "/" + year + " - ";//document.getElementById("date").value;
                    }
                }
                else{
                    var newDate = "";
                }
                var tbody = document.getElementById("insertTable");
                const td = document.createElement("TD");
                const a = document.createElement("A");
                const s = document.createElement("STRONG");
                s.setAttribute("style", "color:red");
                // s.innerHtml = '<span style="color:red">';
                s.innerText = " "+this.strong;
                a.setAttribute("href", this.hyperlink)
                a.setAttribute("target","_blank");
                a.innerText = newDate + this.display;
                a.appendChild(s);
                td.appendChild(a);
                tbody.appendChild(td);
                enableAllOnChangeEvents();
            }

        } // end of methods

    })

</script>
<script>
    var editArticles = new Vue({
        el: '#editArticles',
        data: {

        },
        methods: {
            redirect: function(){
                var path = window.location.href.split('&display')[0];;
                path += '&modify=1&content='+document.getElementById("editContent").value;
                window.location.href = path;
            }
        }
    })
</script>
<%@ include file="/common/footerarea.jsp"%>