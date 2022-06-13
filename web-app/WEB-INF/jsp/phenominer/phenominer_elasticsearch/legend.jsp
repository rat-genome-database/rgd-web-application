<link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css" integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous"/>

<script>
    $(document).ready(function(){
        // Add down arrow icon for collapse element which is open by default
        $(".collapse.show").each(function(){
            $(this).prev(".card-header").find(".fas").addClass("fa-angle-down").removeClass("fa-angle-up");
        });

        // Toggle right and down arrow icon on show hide of collapse element
        $(".collapse").on('show.bs.collapse', function(){
            $(this).prev(".card-header").find(".fas").removeClass("fa-angle-up").addClass("fa-angle-down");
        }).on('hide.bs.collapse', function(){
            $(this).prev(".card-header").find(".fas").removeClass("fa-angle-down").addClass("fa-angle-up");
        });
    });
</script>
<div class="row card-header">
    <div class="col">

            <label class="form-inline" style="color: black" >Colored By:&nbsp;
                <select class="form-control" id= "colorBy">

                    <option value="condition">Condition</option>
                    <option value="strain">Strain</option>
                    <option value="phenotype">Phenotype</option>
                    <option value="method">Method</option>
                    <option value="sex">Sex</option>
                </select>
            </label>

    </div>

    <div class="accordion-group col">
        <div class="pl-3  accordion-heading " >
            <button class="btn btn-sm btn-light"> <a class="accordion-toggle" data-toggle="collapse" href="#collapseTwo" style="text-decoration: none">
                Legend&nbsp;<span class="float-right"><i class="fas fa-angle-down"></i></span>
            </a></button>
        </div>
        <div id="collapseTwo" class="accordion-body collapse hidden">
            <div class="pl-3  accordion-inner">

                <ul>
                    <c:forEach items="${legend}" var="color">
                        <li class="list-group-item">
                            <div class="row" style="text-align: center">
                                <div class="col-xs-1" style="width: 10px;height: 10px;background-color: ${color.value};border:1px solid gray"></div>
                                <div class="col-xs-1">&nbsp;${color.key}</div>&nbsp;
                            </div>
                        </li>
                    </c:forEach>


                </ul>


            </div>
        </div>
    </div>


</div>
