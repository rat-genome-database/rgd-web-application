$(function () {
    var  $species=$('#species');
    $species.on('change', function () {
        var species=this.value;
        var assembly=$('#assembly').val();
        $('#speciesForm').submit();
       
    });
    $('#assembly').on('change', function () {
        $('#assemblyForm').submit();

    });

   
    var species=$species.val().trim();

   if(species=='Rat' || species=='Human' || species=='Mouse' || species=='Dog' || species=='Bonobo' || species=='Pig' || species=='Black Rat'){
       console.log("SPECIES VAL():"+species+ "...RUNNING GVIEWER..");
        runGviewer()
   }

});
var gviewer=null;
function runGviewer() {
    var mapKey= $('#mapKey').val();
    var species=$('#species').val();
    var URL="https://rgd.mcw.edu/jbrowse/?tracks=ARGD_curated_genes&data=";
    var bandURL=null;
    if(species=='Rat') {
        bandURL="/rgdweb/gviewer/data/rgd_rat_ideo.xml";
        if(mapKey==380) {
            URL  = URL + "data_rn8";
        }else
        if(mapKey==372) {
            URL  = URL + "data_rn7_2";
        }
        else if(mapKey==360) {
           URL  = URL + "data_rgd6";
        }
        else if(mapKey==70){
           URL  = URL + "data_rgd5";
        }
        else if(mapKey==60){
            URL  = URL + "data_rgd3_4";
        }
        else if(mapKey==303){
            URL  = URL + "data_uth_wky";
        }
        else if(mapKey==302){
            URL  = URL + "data_uth_shrsp";
        }
        else if(mapKey==301){
            URL  = URL + "data_uth_shr";
        }
    }
    else if(species=='Human') {
        bandURL="/rgdweb/gviewer/data/human_ideo.xml";
        if(mapKey==38)
           URL = URL + "data_hg38";
        else if(mapKey==17)
           URL = URL + "data_hg19";
        else if(mapKey==13)
          URL = URL + "data_hg18";
    }
    else if(species=='Mouse') {
        bandURL="/rgdweb/gviewer/data/mouse_ideo.xml";
        if(mapKey==239)
            URL = URL + "data_mm39";
        else if(mapKey==35)
           URL  = URL + "data_mm38";
        else if(mapKey==18)
           URL  = URL + "data_mm37";
    }
   /* if(species=='Chinchilla') {
        if(mapKey==44)
           URL = URL + "data_cl1_0";
    }*/
    else if(species=='Dog') {
        bandURL="/rgdweb/gviewer/data/dog_ideo.xml";
        if(mapKey==631)
           URL  = URL + "data_dog3_1";
    }
  /*  if(species=='Squirrel') {
        if(mapKey==720)
          URL = URL + "data_squirrel2_0";
    }*/
    else if(species=='Bonobo') {
        bandURL="/rgdweb/gviewer/data/bonobo_ideo.xml";
        if(mapKey=='511')
            URL = URL + "data_bonobo1_1";
        else if(mapKey=='513')
            URL = URL + "data_bonobo2";
    }
    else if(species=='Pig') {
        bandURL="/rgdweb/gviewer/data/pig_ideo.xml";
        if(mapKey=='911')
            URL = URL + "data_pig11_1";
        else if(mapKey=='910')
            URL = URL + "data_pig10_2";
    }
    else if(species=='Naked Mole-Rat') {
        if(mapKey=='1410')
            URL = URL + "data_hetGla2";

    }
    else if(species=='Black Rat') {
        bandURL="/rgdweb/gviewer/data/black_rat_ideo.xml";
        if(mapKey==1701){
            URL=
        }

    }

    if(!gviewer) {
        gviewer = new Gviewer("gviewer",300,600, mapKey);
    //    gviewer.genomeBrowserURL = "http://rgd.mcw.edu/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes";
        gviewer.genomeBrowserURL =URL;
        gviewer.genomeBrowserName = "JBrowse";
        gviewer.regionPadding=2;
        gviewer.annotationPadding = 1;
        gviewer.loadBands(bandURL);

    }
}
