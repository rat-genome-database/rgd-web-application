$(function () {
    var $treeView= $("#jstree_results");
    $treeView.jstree({
        "themes":{
            "theme":"default",
            "dots":false,
            "icons":false
        },
        "types" : {
            "default" : {
                "icon" : "/rgdweb/common/images/bullet_green.png"
            }
        },
        "plugins" : [
            "types" /*, "themes", "html_data", "checkbox", "ui"*/
        ]
    });
    $treeView.jstree("open_all");
    //To Drag content overflow of a div
   /* if($treeView.offsetWidth < $treeView.scrollWidth){
        $('ul').on('click', function () {
            $(this).css("cursor","move");
            $(this).draggable();
        })
    }*/
});