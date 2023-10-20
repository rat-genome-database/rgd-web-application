
<%@ include file="../sectionHeader.jsp"%>

<div id="ajax_damaging_variants"></div>
 <script>
    $(document).ready(function(){

        // Send the input data to the server using get
        $.get("damagingVariants.html", {id: <%=obj.getRgdId()%>, s: "<%=obj.getSymbol()%>"} , function(data){
            // Display the returned data in browser
            $("#ajax_damaging_variants").html(data);
            // run(); // to add 'Damaging Variants' to nav sidebar
        });
    });
</script>
<%@ include file="../sectionFooter.jsp"%>
