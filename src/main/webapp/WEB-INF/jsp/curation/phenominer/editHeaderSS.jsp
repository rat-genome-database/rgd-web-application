<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>

<%@ include file="/common/headerarea.jsp"%>

<script type="text/javascript" src="/rgdweb/js/sorttable.js"></script>

<link rel="stylesheet" type="text/css" href="/rgdweb/css/pheno.css">

<link rel="stylesheet" href="/solr/OntoSolr/files/jquery.autocomplete.css" type="text/css" />

<script type="text/javascript">
    function edit(idName) {
        if (countSelected(idName) < 1) {
            alert("You must select an item to be edited");
            return;
        }

        document.form1.act.value="edit";
        document.form1.submit();
    }

    function editExperimentRecords(idName) {
        if (countSelected(idName) < 1) {
            alert("You must select an item to be edited");
            return;
        }

        document.form1.action="records.html"
        document.form1.act.value="edit_experiment_records";
        document.form1.submit();
    }

    function editExperiments(idName) {
        if (countSelected(idName) < 1) {
            alert("You must select an item to be edited");
            return;
        }

        document.form1.action="experiments.html"
        document.form1.act.value="edit_experiments";
        document.form1.submit();
    }

    function selectAll(idName) {
        var count = countSelected(idName);

        var ids = document.getElementsByName(idName);
        for (var i=0; i< ids.length; i++) {
            if (count > 0) {
                ids[i].checked = false;
            }else {
                ids[i].checked = true;                
            }
        }
    }

    function deSelectAll(idName) {
        var ids = document.getElementsByName(idName);
        for (var i=0; i< ids.length; i++) {
            ids[i].checked = false;
        }
    }

    function countSelected(idName) {
        var count=0;
        var ids = document.getElementsByName(idName);
        for (var i=0; i< ids.length; i++) {
            if (ids[i].checked) {
                count++;
            }
        }
        return count;
    }


    function del(idName) {

        if (countSelected(idName) < 1) {
            alert("You must select an item to be deleted");
            return;
        }

        var message = countSelected(idName) + " items are selected. Item(s) without any experiment records will be deleted and can not be reversed. Select OK to proceed.";
        if (confirm(message)) {
            document.form1.act.value="del";
            document.form1.submit();
        }
    }

    function create(idName) {
        if (countSelected(idName) > 1) {
            alert("You must select Zero or One item to clone.  You currently have " + countSelected(idName) + " selections");
            return;
        }

        document.form1.act.value="new";        
        document.form1.submit();
    }


    function search(page) {
        location.href = page + "?" + location.href.split("?")[1];
    }

</script>

<%
    HttpRequestFacade req = new HttpRequestFacade(request);
    PhenominerDAO dao = new PhenominerDAO();

    DisplayMapper dm = new DisplayMapper(req, (ArrayList) request.getAttribute("error"));
     
    FormUtility fu = new FormUtility();


%>


<div class="pageFormat">

