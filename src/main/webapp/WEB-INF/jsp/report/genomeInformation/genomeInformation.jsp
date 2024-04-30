<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="genomeInfoHeader.jsp"/>

        <div  style="margin-left:60%">
            <input type="hidden" id="mapKey" value="${model.mapKey}"/>

            <form id="speciesForm" action="genomeInformation.html?action=change&details=true">
            <div style="width:20%;float:left">
                <label>Species:
                    <select id="species" name="species">
                        <option selected>${model.species}</option>
                        <c:forEach items="${model.speciesList}" var="item">-
                            <c:if test="${model.species!=item && item!='All'}">
                                <option>${item}</option>
                            </c:if>
                        </c:forEach>
                    </select>
                </label>
            </div>
            </form>
            <form id="assemblyForm" action="genomeInformation.html?species=${model.species}&action=change&details=true">
                <input type="hidden"  name="species" value="${model.species}"/>
            <div style="width:30%;margin-left:21%;">
                <label>Assembly:
                    <select id="assembly" name="assembly">
                        <c:forEach items="${model.assemblyList}" var="item">
                            <c:choose>
                                <c:when test="${model.assembly==item}">
                                    <option selected>${item}</option>
                                </c:when>
                                <c:otherwise>
                                <option>${item}</option>
                                </c:otherwise>
                            </c:choose>

                        </c:forEach>
                    </select>
                </label>
            </div>
            </form>
        </div>

   <jsp:include page="Info.jsp"/>
 <jsp:include page="genomeInfoFooter.jsp"/>

<script>
    $(document).ready(function() {

        var mapKey= $('#mapKey').val();
        var species=$('#species').val();
        var $jbrowse= document.getElementById('jbrowseMini');
        var URL="/jbrowse?tracks=ARGD_curated_genes&highlight=&tracklist=0&nav=0&overview=0&data=";
        if($jbrowse!=null && typeof $jbrowse != 'undefined') {
            if (species == 'Chinchilla') {
                if (mapKey == 44)
                    $jbrowse.src = URL + "data_cl1_0&loc=";
            }

            if (species == 'Squirrel') {
                if (mapKey == 720)
                    $jbrowse.src = URL + "data_squirrel2_0&loc=";
            }
            if (species == 'Naked Mole-rat') {
                if (mapKey == 1410)
                    $jbrowse.src = URL + "data_hetGla2&loc=";
            }
            if (species == 'Green Monkey') {
                if (mapKey == 1311)
                    $jbrowse.src = URL + "data_chlSab2&loc=";
                if (mapKey == 1313)
                    $jbrowse.src = URL + "data_veroWho&loc=";
            }
        }
    });
</script>





