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
            species: ['Rat','Mouse','Human','Chinchilla','Bonobo','Dog','Squirrel'],
            inSpecies: 3,
            outSpecies: 3,
            default: 3,
            inMapKey: "Rnor_6.0",
            outMapKey: "Rnor_6.0",
            genes: []
        },
        methods: {
            setMaps: function(species,divId) {

                if(species != this.default)
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
                                v.inMapKey = v.maps[0].key;
                                v.inMaps.push(v.maps[i]); }
                            else {v.outMapKey = v.maps[0].key;
                                v.outMaps.push(v.maps[i]); }
                        }
                    }).catch(function (error) {
                    console.log(error)
                })
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
                alert(params.genes);
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



        },
           });

    return v;
}