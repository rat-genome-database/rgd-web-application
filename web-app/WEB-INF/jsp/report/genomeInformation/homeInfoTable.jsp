<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<table class="table table-stripped" >

    <c:forEach items="${model.hits}" var="hit">

    <tr><td colspan="2" style="text-align: center">
        <!--form action="genomeInformation.html">
            <input type="hidden" name=species value="$--{hit.source.species}"/>
        <button type="submit">More</button>
        </form-->

        <a href="genomeInformation.html?species=${hit.sourceAsMap.species}&mapKey=${hit.sourceAsMap.mapKey}&details=true" title="click to see more info and other assemblies"><strong>More Details..</strong></a>

    </td>

        </tr>
    <tr><td>Total Seq Length</td><td>${hit.sourceAsMap.totalSeqLength}</td></tr>
    <tr><td>Chromosomes(haploid)</td><td>${hit.sourceAsMap.chromosomes}</td></tr>
    <tr><td>Genes</td><td>${hit.sourceAsMap.totalGenes}</td></tr>

    </c:forEach>
   
</table>