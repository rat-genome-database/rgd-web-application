$(function () {
    $(".RatAssembly").on('change', function () {
        var mapKey= this.value;
       
        var $content=$(".RatClass");
        changeGenomeData('Rat', mapKey, $content);
    });
    $(".HumanAssembly").on('change', function () {
        var mapKey= this.value;
        var $content=$(".HumanClass");
        changeGenomeData('Human',mapKey, $content);
    });
    $(".MouseAssembly").on('change', function () {
        var mapKey= this.value;
        var $content=$(".MouseClass");
        changeGenomeData('Mouse',mapKey, $content);
    });
    $(".ChinchillaAssembly").on('change', function () {
        var mapKey= this.value;
        var $content=$(".ChinchillaClass");
        changeGenomeData('Chinchilla',mapKey, $content);
    });
    $(".DogAssembly").on('change', function () {
        var mapKey= this.value;
        var $content=$(".DogClass");
        changeGenomeData('Dog',mapKey, $content);
    });
    $(".SquirrelAssembly").on('change', function () {
        var mapKey= this.value;
        var $content=$(".SquirrelClass");
        changeGenomeData('Squirrel',mapKey, $content);
    });
    $(".BonoboAssembly").on('change', function () {
        var mapKey= this.value;
        var $content=$(".BonoboClass");
        changeGenomeData('Bonobo',mapKey, $content);
    });
    $(".PigAssembly").on('change', function () {
        var mapKey= this.value;
        var $content=$(".PigClass");
        changeGenomeData('Pig',mapKey, $content);
    });
    $(".GreenMonkey").on('change', function () {
        var mapKey= this.value;
        var $content=$(".GreenMonkeyClass");
        changeGenomeData('Green Monkey',mapKey, $content);
    });
    $(".NakedMole-Rat").on('change', function () {
        var mapKey= this.value;
        var $content=$(".NakedMole-RatClass");
        changeGenomeData('Naked Mole-Rat',mapKey, $content);
    });
    $(".more").hide();
    $(".moreLink").on("click", function(e) {

        var $this = $(this);
        var parent = $this.parent();
        var $content=parent.find(".more");
        var linkText = $this.text();

        if(linkText === "More..."){
            linkText = "Hide...";
            $content.show();
        } else {
            linkText = "More...";
            $content.hide();
        }
        $this.text(linkText);
        return false;

    });
});
function changeGenomeData(species,mapKey, $content) {
    var href="genomeInformation.html?species="+species.replace(" ","+")+"&mapKey="+mapKey+"&details=true";
    $('#headerLink'+species).attr('href', href);
    var className = ".map" + mapKey;
    var url = "genomeInformation.html?mapKey=" + mapKey + "&infoTable=y";
    $.get(url, function (data, status) {
        $content.html(data);

    });
}