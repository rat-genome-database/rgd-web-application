/**
 * Created by hsnalabolu on 4/9/2019.
 */
function OrthologVue(divId) {

    var div = '#'+divId;
    var host = window.location.protocol + window.location.host;
    if (window.location.host.indexOf('localhost') > -1) {
        host= window.location.protocol + '//dev.rgd.mcw.edu';
    } else if (window.location.host.indexOf('dev.rgd') > -1) {
        host= window.location.protocol + '//dev.rgd.mcw.edu';
    }else if (window.location.host.indexOf('test.rgd') > -1) {
        host= window.location.protocol + '//test.rgd.mcw.edu';
    }else if (window.location.host.indexOf('pipelines.rgd') > -1) {
        host= window.location.protocol + '//pipelines.rgd.mcw.edu';
    }else {
        host=window.location.protocol + '//rest.rgd.mcw.edu';
    }

    host = 'https://dev.rgd.mcw.edu';
    var v = new Vue({
        el: div,
        data: {
            hostName: host,
            maps: [],
            mapsHtml: "",
            inMaps: [],
            outMaps: [],
            chromosomes: [],
            inSpecies: 3,
            outSpecies: 1,
            chr: 1,
            inMapKey: "Rnor_6.0",
            outMapKey: "GRCh38",
            genes: []
        },
        methods: {
            setMaps: function(species,divId) {
                var mapKey = 0;
                if(species != this.inSpecies && species != this.outSpecies )
                    species = species.options[species.selectedIndex].value;
                v.maps = [];
                if(divId == 'inMaps')
                    v.inMaps=[];
                else v.outMaps=[];

                axios
                    .get(this.hostName + '/rgdws/maps/'+species)
                    .then(function (response) {
                        v.maps = (response.data);

                        for(var i=0;i < v.maps.length;i++){
                            if(divId == 'inMaps') {
                                mapKey = v.maps[0].key;
                                v.inMapKey = v.maps[0].key;
                                v.inMaps.push(v.maps[i]); }
                            else {v.outMapKey = v.maps[0].key;
                                v.outMaps.push(v.maps[i]); }
                        }
                        if(divId == 'inMaps' && v.maps.length > 0)
                            v.setChromosomes(mapKey);
                    }).catch(function (error) {
                    console.log(error)
                });


            },

            download: function() {

                params = new Object();
                var form = document.createElement("form");
                var method = "POST";
                form.setAttribute("method", method);
                form.setAttribute("action", "/rgdweb/ortholog/report.html?fmt=csv");
                params.inSpecies = v.inSpecies;
                params.outSpecies = v.outSpecies;
                params.inMapKey = v.inMapKey;
                params.outMapKey = v.outMapKey;
                params.genes = v.genes;

                for (var key in params) {
                    var hiddenField = document.createElement("input");
                    hiddenField.setAttribute("type", "hidden");
                    hiddenField.setAttribute("name", key);
                    hiddenField.setAttribute("value", params[key]);
                    form.appendChild(hiddenField);
                }
                document.body.appendChild(form);
                form.submit();
            },

            setChromosomes: function(mapKey) {
                   if(v.inMapKey == 'Rnor_6.0')
                        mapKey = 360;
                    axios
                        .get(this.hostName + '/rgdws/maps/chr/' + mapKey)
                        .then(function (response) {
                            v.chromosomes = response.data;
                        }).catch(function (error) {
                        console.log(error)
                    });
            }


        },
           });

    return v;
}