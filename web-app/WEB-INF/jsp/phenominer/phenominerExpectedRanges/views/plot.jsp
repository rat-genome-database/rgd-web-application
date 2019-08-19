<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>



<div>Display Normal Ranges:
    <c:if test="${model.normalRange.mixed!=null}">
    <input type="hidden" id="normalLow" value="${model.normalRange.mixed.rangeLow}"/>
    <input type="hidden" id="normalHigh" value="${model.normalRange.mixed.rangeHigh}"/>

    <input type="radio" class="normalRadio" name="normal" value="Both" checked>&nbsp;&nbsp;<span title="All Ages and All Sex">Normal All</span>&nbsp;&nbsp;
    </c:if>
    <c:if test="${model.normalRange.male!=null}">
       <input type="hidden" id="normalMaleLow" value="${model.normalRange.male.rangeLow}"/>
        <input type="hidden" id="normalMaleHigh" value="${model.normalRange.male.rangeHigh}"/>

    <input type="radio" class="normalRadio" name="normal" value="Male">&nbsp;&nbsp;<span title="Male - All ages">Normal Male</span>&nbsp;&nbsp;
    </c:if>
    <c:if test="${model.normalRange.female!=null}">
        <input type="hidden" id="normalFemaleLow" value="${model.normalRange.female.rangeLow}"/>
        <input type="hidden" id="normalFemaleHigh" value="${model.normalRange.female.rangeHigh}"/>


    <input type="radio" class="normalRadio" name="normal" value="Female">&nbsp;&nbsp;<span title="Female - All Ages">Normal Female</span>&nbsp;&nbsp;
    </c:if>
    <c:choose>
       <c:when test="${model.normalRange.mixed==null && model.normalRange.male==null && model.normalRange.female==null}">

        <span style="color:red">Not available</span>
    </c:when>
        <c:otherwise>
            <input type="radio" class="normalRadio" name="normal" value="">&nbsp;&nbsp;<span title="Turn Off Normal Range">Turn Off</span>
        </c:otherwise>

    </c:choose>

</div>
<div id="rangeDiv" style="width: auto">

</div>


<br>Normal Ranges:
<c:if test="${model.normalRange.mixed!=null}">
    <span style="font-weight: bold;color:red;font-size: small">LOW:</span><strong>${model.normalRange.mixed.rangeLow}</strong>
    <span style="font-weight: bold;color:red;font-size: small">HIGH: </span><strong>${model.normalRange.mixed.rangeHigh}</strong>
</c:if>

<div>
<c:if test="${model.normalRange.male!=null}">
<span style="font-weight: bold;color:blue;font-size: small">MALE LOW:</span><strong>${model.normalRange.male.rangeLow}</strong>
<span style="font-weight: bold;color:blue;font-size: small">MALE HIGH:</span><strong>${model.normalRange.male.rangeHigh}</strong>
    </c:if>
<c:if test="${model.normalRange.female!=null}">
<span style="font-weight: bold;color:fuchsia;font-size: small">FEMALE LOW:</span><strong>${model.normalRange.female.rangeLow}</strong>
<span style="font-weight: bold;color:fuchsia;font-size: small">FEMALE HIGH:</span><strong>${model.normalRange.female.rangeHigh}</strong>
   </c:if>
</div>


<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="/rgdweb/js/expectedRanges/plotly-latest.min.js"></script>

<script src="/rgdweb/js/expectedRanges/expectedRanges.js"></script>

<script>

    var normalLow=$('#normalLow').val();
    var normalHigh=$('#normalHigh').val();
    var normalMaleLow=$('#normalMaleLow').val();
    var normalMaleHigh= $('#normalMaleHigh').val();
    var normalFemaleLow=$('#normalFemaleLow').val();
    var normalFemaleHigh= $('#normalFemaleHigh').val();
    var data = ${model.plotData};
    var phenotype='${model.phenotype}${model.strainGroup}';
    var yaxisTitle=$('#units').val();

    var x1=${fn:length(model.plotData)}

    if(typeof normalLow =='undefined' && typeof normalHigh=='undefined'){
        turnOffNormalRanges();
    }else{   initialPlot();}

    </script>
