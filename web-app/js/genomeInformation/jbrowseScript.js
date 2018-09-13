
$(document).ready(function() {

    var mapKey= $('#mapKey').val();
    var species=$('#species').val();
    var chr=$('#chr').val();
    var $jbrowse= document.getElementById('jbrowseMini');
    var URL="https://rgd.mcw.edu/jbrowse/?tracks=ARGD_curated_genes&highlight=&tracklist=0&nav=0&overview=0&data=";
    console.log("MapKEY: "+ mapKey);
    if(species=='Rat') {
        if(mapKey==360) {
            $jbrowse.src  = URL + "data_rgd6&loc=Chr"+chr;
        }
        if(mapKey==70){
            $jbrowse.src  = URL + "data_rgd5&loc=Chr"+chr;
        }
        if(mapKey==60){
            $jbrowse.src  = URL + "data_rgd3_4&loc=Chr"+chr;
        }
    }
    if(species=='Human') {
        if(mapKey==38)
            $jbrowse.src = URL + "data_hg38&loc=Chr"+chr;
        if(mapKey==17)
            $jbrowse.src = URL + "data_hg19&loc=Chr"+chr;
        if(mapKey==13)
            $jbrowse.src = URL + "data_hg18&loc=Chr"+chr;
    }
    if(species=='Mouse') {
        if(mapKey==35)
            $jbrowse.src  = URL + "data_mm38&loc=Chr"+chr;
        if(mapKey==18)
            $jbrowse.src  = URL + "data_mm37&loc=Chr"+chr;
    }
    if(species=='Chinchilla') {
        if(mapKey==44)
            $jbrowse.src = URL + "data_cl1_0&loc=";
    }
    if(species=='Dog') {
        if(mapKey==631)
            $jbrowse.src  = URL + "data_dog3_1&loc=";
    }
    if(species=='Squirrel') {
        if(mapKey==720)
            document.getElementById('jbrowseMini').src = URL + "data_squirrel2_0&loc=";
    }
    if(species=='Bonobo') {
        if(mapKey=='511')
            document.getElementById('jbrowseMini').src = URL + "data_bonobo1_1&loc=";
    }

});

