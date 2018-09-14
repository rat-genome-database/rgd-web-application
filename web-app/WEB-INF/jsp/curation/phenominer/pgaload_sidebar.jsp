<%-- SIDEBAR --%>
<div class="pga_sidebar">
    <h3>General Information</h3>
    <dl>
        <dt>Study Name:</dt><dd><%=bean.getStudy().getName()%></dd>
        <dt>Study Type:</dt><dd><%=bean.getStudy().getType()%></dd>
        <dt>Study Source:</dt><dd><%=bean.getStudy().getSource()%></dd>
        <dt>Study Url:</dt><dd><%=bean.getStudy().getUrl()%></dd>

        <dt>File Name:</dt>
        <c:if test="${!empty bean.dataFileName}">
            <dd><%=bean.getDataFileName()%></dd>
        </c:if>

        <dt>Line Count:</dt><dd><%=bean.getData().size()%></dd>

        <dt>Rat Strains:</dt>
        <c:if test="${!empty bean.mapStrains}">
        <dd><%=bean.getMapStrains().size()-bean.getUnmappedStrainCount()%> mapped out of <%=bean.getMapStrains().size()%>
            [<a href="pgaload.html?stage=stage2">edit</a>]
        </dd>
        </c:if>

        <dt>Atmospheric Conditions:</dt>
        <c:if test="${!empty bean.mapAtmCond}">
        <dd><%=bean.getMapAtmCond().size()%>
            [<a href="pgaload.html?stage=stage3">edit</a>]
        </dd>
        </c:if>

        <dt>Diet Conditions:</dt>
        <c:if test="${!empty bean.mapDietCond}">
        <dd><%=bean.getMapDietCond().size()%>
            [<a href="pgaload.html?stage=stage4">edit</a>]
        </dd>
        </c:if>

        <dt>Genders:</dt>
        <c:if test="${!empty bean.mapGender}">
        <dd><%=bean.getMapGender().size()%>
            [<a href="pgaload.html?stage=stage5">edit</a>]
        </dd>
        </c:if>

        <dt>Rat Diets:</dt>
        <c:if test="${!empty bean.mapRatDiet}">
        <dd><%=bean.getMapRatDiet().size()%>
            [<a href="pgaload.html?stage=stage6">edit</a>]
        </dd>
        </c:if>

        <dt>Phenotypes:</dt>
        <c:if test="${!empty bean.phenotypes}">
        <dd><%=bean.getMappedPhenotypeCount()%> mapped out of <%=bean.getPhenotypes().size()%>
            [<a href="pgaload.html?stage=stage7">edit</a>]
        </dd>
        </c:if>

        <dt>Experiments:</dt>
        <c:if test="${!empty bean.experiments}">
        <dd><%=bean.getExperiments().size()%>
            [<a href="pgaload.html?stage=stage8">edit</a>]
        </dd>
        </c:if>

        <dt>Experiment Records:</dt>
        <c:if test="${!empty bean.experimentRecords}">
        <dd><%=bean.getExperimentRecords().size()%>
            [<a href="pgaload.html?stage=stage9">edit</a>]
        </dd>
        </c:if>
    </dl>
</div>