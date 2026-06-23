<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.*" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>

<%
    String pageTitle = "Gene Binning";
    String headContent = "";
    String pageDescription = "Assigning genes of interest into Bins for disease portal curation.";
%>
<head>
    <style>
        .main-body{
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .main_form{
            display: flex;
            width: 100%;
            margin-top: 10px;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        input[type=submit]{
            margin-top: 10px;
            padding: 3px;
        }

        .show_bins{
            margin-left: auto;
            padding: 3px;
        }

        .session_bar{
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 12px;
            margin-top: 15px;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
        }
        .session_bar form{
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .session_bar select, .session_bar input[type=text]{
            padding: 4px;
        }
        .session_message{
            margin-top: 10px;
            padding: 8px 12px;
            border: 1px solid #c0c0c0;
            border-radius: 4px;
            background-color: #fff8e1;
        }
        .session_current{
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            border-top: 1px solid #eee;
            padding-top: 10px;
        }
        .delete-session-button{
            padding: 4px 10px;
            border: none;
            border-radius: 4px;
            background-color: #FF0000;
            color: white;
            cursor: pointer;
        }
        .delete-session-button:hover{ background-color: #CC0000; }
    </style>
</head>
<%@ include file="../../../../common/headerarea.jsp" %>
<div class="main-body" >

    <c:if test="${model.message != null}">
        <div class="session_message">${model.message}</div>
    </c:if>

<%--    Session selection / creation. A session keeps each binning run's genes separate. --%>
    <div class="session_bar">
        <form action="/rgdweb/curation/geneBinning/index.html" method="get">
            <input type="hidden" name="accessToken" value="${model.accessToken}"/>
            <label for="sessionId"><b>Binning session:</b></label>
            <select name="sessionId" id="sessionId" onchange="this.form.submit()">
                <option value="">-- select a session --</option>
                <c:forEach var="s" items="${model.sessions}">
                    <option value="${s}" <c:if test="${s == model.sessionId}">selected</c:if>>${s}</option>
                </c:forEach>
            </select>
            <noscript><input type="submit" value="Switch"/></noscript>
        </form>

        <form action="/rgdweb/curation/geneBinning/index.html" method="get">
            <input type="hidden" name="accessToken" value="${model.accessToken}"/>
            <label for="newSession"><b>New session:</b></label>
            <input type="text" name="newSession" id="newSession" placeholder="session name"/>
            <input type="submit" value="Create"/>
        </form>

        <c:if test="${model.sessionId != null && model.sessionId != ''}">
            <div class="session_current">
                <span><b>Current session:</b> ${model.sessionId}</span>

<%--            Rename the current session --%>
                <form action="/rgdweb/curation/geneBinning/index.html" method="get">
                    <input type="hidden" name="accessToken" value="${model.accessToken}"/>
                    <input type="hidden" name="renameFrom" value="${model.sessionId}"/>
                    <input type="text" name="renameTo" placeholder="new name"/>
                    <input type="submit" value="Rename"/>
                </form>

<%--            Delete the current session --%>
                <form action="/rgdweb/curation/geneBinning/index.html" method="get"
                      onsubmit="return confirm('Delete session \'${model.sessionId}\' and all of its binned genes? This cannot be undone.');">
                    <input type="hidden" name="accessToken" value="${model.accessToken}"/>
                    <input type="hidden" name="deleteSession" value="${model.sessionId}"/>
                    <input type="submit" class="delete-session-button" value="Delete session"/>
                </form>
            </div>
        </c:if>
    </div>

<%--    Binning UI is only available once a session is selected --%>
    <c:choose>
        <c:when test="${model.sessionId != null && model.sessionId != ''}">
            <div class="show_bins">
                <button>
                    <c:choose>
                        <c:when test="${model.pepDetail != null && model.pepDetail.getTotalGenes() > 15}">
                            <a style="text-decoration: none" href="/rgdweb/curation/geneBinning/bins.html?termAcc=GO:0008233&term=peptidase activity&parent=0&childTermAcc=GO:0070001&childTerm=aspartic-type peptidase activity&username=${model.username}&accessToken=${model.accessToken}&sessionId=${model.sessionId}">
                                Show Gene Bins
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a style="text-decoration: none" href="/rgdweb/curation/geneBinning/bins.html?termAcc=GO:0008233&term=peptidase activity&parent=1&username=${model.username}&accessToken=${model.accessToken}&sessionId=${model.sessionId}">
                                Show Gene Bins
                            </a>
                        </c:otherwise>
                    </c:choose>
                </button>
            </div>
            <div class="main_form">
                <h3>Enter Genes: </h3>
                <form action="/rgdweb/curation/geneBinning/bins.html" method="post">
                    <input type="hidden" name="termAcc" value="GO:0008233" />
                    <input type="hidden" name="term" value="peptidase activity" />
                    <input type="hidden" name="username" value="${model.username}"/>
                    <input type="hidden" name="accessToken" value="${model.accessToken}"/>
                    <input type="hidden" name="sessionId" value="${model.sessionId}"/>
                    <c:choose>
                        <c:when test="${model.pepDetail != null && model.pepDetail.getTotalGenes() > 15}">
                            <input type="hidden" name="parent" value="0">
                            <input type="hidden" name="childTermAcc" value="GO:0070001" />
                            <input type="hidden" name="childTerm" value="aspartic-type peptidase activity" />
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="parent" value="1"/>
                        </c:otherwise>
                    </c:choose>
                    <textarea rows="25" cols="150" name="inputdata"></textarea>
                    <br>
                    <input type="submit" value="Perform Binning">
                </form>
            </div>
        </c:when>
        <c:otherwise>
            <div class="main_form">
                <h3>Select or create a session above to begin binning.</h3>
            </div>
        </c:otherwise>
    </c:choose>
</div>


<%--Id: <c:out value="${geneList.gene.rgd_id}"/> <br/>--%>
<%--Name: <c:out value="${geneList.gene.gene_symbol}"/>  <br/>--%>


<%@ include file="../../../../common/footerarea.jsp" %>
