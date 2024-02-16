var rgdModule = angular.module('rgdPage', ['ngSanitize']);

rgdModule.service('ConfigService', function () {

    this.listName="";
    this.listDescription="";
    this.geneWatchAttributes=["Nomenclature Changes","New GO Annotation","New Disease Annotation","New Phenotype Annotation","New Pathway Annotation","New PubMed Reference","Altered Strains","New NCBI Transcript/Protein","New Protein Interaction","RefSeq Status Has Changed"];

    //alert(this.username);

});

rgdModule.controller('RGDPageController', [
    '$scope','$http',  'ConfigService',
    function ($scope, $http,  ConfigService) {
        var ctrl = this;

        //$scope.username=ConfigService.username;
        //alert($scope.username);
        //$scope.geneWatchAttributes = ConfigService.geneWatchAttributes;

        $scope.speciesTypeKey = "";
        $scope.mapKey="";

        $scope.geneWatchAttributes = {};
        $scope.geneWatchSelection={};
        $scope.pageObject="";
        $scope.messageCount=1;


        try {
            $scope.pageObject=getLoadedObject();
        }catch (err) {
        }

        $scope.pageObject=getLoadedObject();

        $scope.activeObject="";
        $scope.watchLinkText="Watch Object";

        $scope.watchedObjects={};
        $scope.watchedTerms={};

        $scope.loginError="";

        $scope.activeList="";

        // toggle selection for a given fruit by name
        $scope.toggleGeneWatchSelection = function toggleGeneWatchSelection(geneWatchAttribute) {
            //alert(geneWatchAttribute);
            var idx = $scope.geneWatchSelection.indexOf(geneWatchAttribute);

            // is currently selected
            if (idx > -1) {
                $scope.geneWatchSelection.splice(idx, 1);
            }

            // is newly selected
            else {
                $scope.geneWatchSelection.push(geneWatchAttribute);
            }

        }

        ctrl.getActiveWatchers = function(rgdId) {
            if (rgdId=="") {
                return;
            }

            $scope.activeObject=rgdId;

            $http({
                method: 'POST',
                url: "/rgdweb/webservice/my.html?method=getWatchers",
                data: {rgdId: rgdId }

            }).then(function successCallback(response) {
                    if (!response.data.selected) {
                        $scope.watchLinkText="Subscribe to Updates";
                        $scope.geneWatchSelection = JSON.parse(JSON.stringify(response.data.all));
                    }else {
                        $scope.watchLinkText="Modify Subscription";
                        $scope.geneWatchSelection = response.data.selected;
                    }

                    $scope.geneWatchAttributes= response.data.all;

                $('#watch-modal').modal('show');

            }, function errorCallback(response) {
                alert("ERRROR:" + response.data);
                //alert(response.data);
                // called asynchronously if an error occurs
                // or server returns response with an error status.
            });


        }

        ctrl.setWatchers = function(rgdId) {
            if (rgdId=="") {
                return;
            }

            $http({
                method: 'POST',
                url: "/rgdweb/webservice/my.html?method=getWatchers",
                data: {rgdId: rgdId }

            }).then(function successCallback(response) {

                if (!response.data.selected) {
                    $scope.geneWatchSelection = JSON.parse(JSON.stringify(response.data.all));
                    $scope.watchLinkText="Subscribe to Updates";
                }else {
                    $scope.geneWatchSelection = response.data.selected;
                    $scope.watchLinkText="Modify Subscription";
                }

                $scope.geneWatchAttributes= response.data.all;

            }, function errorCallback(response) {
                alert("ERRROR:" + response.data);
                //alert(response.data);
                // called asynchronously if an error occurs
                // or server returns response with an error status.
            });


        }

        ctrl.addWatch = function(rgdId) {

            if ($scope.username == "Sign In") {
                $('#login-modal').modal('show');
            }else {
                ctrl.getActiveWatchers(rgdId);
            }
        }

        ctrl.saveWatch = function(rgdId) {

            $http({
                method: 'POST',
                data: {rgdId: rgdId ,geneWatchAttributes: $scope.geneWatchSelection},
                url: "/rgdweb/webservice/my.html?method=addWatcher",

            }).then(function successCallback(response) {
                $scope.watchLinkText="Modify Subscription";

            }, function errorCallback(response) {
                alert("ERRROR:" + response.data);
            });

        }


        ctrl.removeWatch = function(rgdId) {
            $http({
                method: 'POST',
                data: {rgdId: rgdId},
                url: "/rgdweb/webservice/my.html?method=removeWatcher",

            }).then(function successCallback(response) {

                $scope.watchedObjects = response.data.objects;
                $scope.watchedTerms = response.data.terms;


                if (rgdId == $scope.pageObject) {
                    $scope.geneWatchSelection = $scope.geneWatchAttributes;
                    $scope.watchLinkText = "Subscribe to Updates";
                }

            }, function errorCallback(response) {
                alert("ERRROR:" + response.data);
            });

        }

        ctrl.saveList = function(e) {

            if (ConfigService.username != "Sign In") {
                $scope.submitUrl = "/rgdweb/webservice/my.html?method=saveList";
                var geneList = getResultSet();
            }else {
                alert("You must be logged in to MyRGD to save a list");
            }

            $http({
                method: 'POST',
                data: {genes: getResultSetArray(),action: "add",url: location.href, name: $scope.listName,desc: $scope.listDescription},
                url: $scope.submitUrl,

            }).then(function successCallback(response) {
                ConfigService.listName = $scope.listName;
                ConfigService.listDescription = $scope.listDescription;

            }, function errorCallback(response) {
                alert("ERRROR:" + response.data);

            });

        }

        $scope.$watch(function () { return ConfigService.listName; },
            function (value) {
                $scope.listName = value;
            }
        );

        $scope.$watch(function () { return ConfigService.listDescription; },
            function (value) {
                $scope.listDescription= value;
            }
        );

        ctrl.selectedLink = function(e) {
            location.href=e.target.getAttribute("data-url");
        }

        ctrl.loadMyRgd = function(e) {
            if ($scope.username == "") {
                $scope.username="Sign In";
            }


            if ($scope.username == "Sign In") {
                console.log($scope.username + "showing login");

                $('#login-modal').modal('show');

            }else {

                $http({
                    method: 'GET',
                    url: "/rgdweb/webservice/my.html?method=getAllWatchedObjects"
                }).then(function successCallback(response) {

                    //alert(response.data);
                    $scope.watchedObjects = response.data.objects;
                    $scope.watchedTerms = response.data.terms;
                    $scope.messageCount=response.data.messageCount;

                    $('#my-modal').modal('show');
                }, function errorCallback(response) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                });

            }
        }

        ctrl.loadMyRgdLists = function(e) {

            if ($scope.username == "Sign In") {
                console.log($scope.username + "showing login");

                $('#login-modal').modal('show');

            }else {

                $http({
                    method: 'GET',
                    url: "/rgdweb/webservice/my.html?method=getLists"
                }).then(function successCallback(response) {
                    $scope.myLists = response.data;
                    $('#my-modal').modal('show');
                }, function errorCallback(response) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                });

            }
        }


        ctrl.loadGeneList = function(listId) {

            $http({
                method: 'GET',
                url: "/rgdweb/webservice/my.html?method=getGenes&lid=" + listId,
            }).then(function successCallback(response) {

                if ($scope.username == "Sign In") {
                    document.getElementById("rgd-model").innerHTML = response.data;
                }else {
                    $scope.geneList = response.data;
                }

            }, function errorCallback(response) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
            });
        }

        ctrl.import = function(listId) {

            $http({
                method: 'GET',
                url: "/rgdweb/webservice/my.html?method=getGenes&lid=" + listId,
            }).then(function successCallback(response) {

                if ($scope.username == "Sign In") {
                    document.getElementById("rgd-model").innerHTML = response.data;
                }else {
                    var geneList="";
                    for (var i=0; i< response.data.length; i++) {
                        geneList += response.data[i].symbol + "\n";
                    }
                    $scope.importTarget = geneList;
                }

            }, function errorCallback(response) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
            });
        }

        ctrl.removeList = function(listId) {

            $http({
                method: 'GET',
                url: "/rgdweb/webservice/my.html?method=removeList&lid=" + listId,
            }).then(function successCallback(response) {

                $scope.loadMyRgd;

            }, function errorCallback(response) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
            });
        }


        ctrl.setUser = function() {

            $http({
                method: 'GET',
                url: "/rgdweb/webservice/my.html?method=getUsername",
            }).then(function successCallback(response) {

                if (response.data.trim() == "") {
                    $scope.username="Sign In";
                    $scope.watchLinkText="Subscribe to Updates";
                    document.getElementById("signIn").style.display="block";
                    document.getElementById("manageSubs").style.display="none";

                }else {
                    $scope.username=response.data.trim();
                    document.getElementById("signIn").style.display="none";
                    document.getElementById("manageSubs").style.display="block";
                }
            }, function errorCallback(response) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
            });


        }


        ctrl.logout = function() {
            $http({
                method: 'GET',
                url: "/rgdweb/webservice/my.html?method=logout",
            }).then(function successCallback(response) {

                location.replace("/rgdweb/homepage")
                //ctrl.setUser();


            }, function errorCallback(response) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
            });
        }


        ctrl.login = function() {

            $.ajax({
                type: "POST",
                url: "/rgdweb/j_spring_security_check",
                data: {j_username: document.getElementById("j_username").value, j_password: document.getElementById("j_password").value},
                success: function(data) {

                    if (data.trim().length > 200) {
                        $scope.loginError="";
                    }else {
                       $scope.loginError = data.trim();
                    }

                    ctrl.setUser();
                    ctrl.setWatchers($scope.pageObject);

                    if ($scope.loginError == "") {
                        $('#login-modal').modal('hide');

                    }
                },
                error: function() {

                }
            });

        }

        ctrl.showTools = function(listId, speciesType, map, oKey, a, tool) {
            $scope.activeList=listId;
            $scope.speciesTypeKey=speciesType;
            var speciesKeys = [1,2,3,4,5,6,7,8,9];
            var text = "";
            for(i=0;i < speciesKeys.length;i++){
                if($scope.speciesTypeKey != speciesKeys[i])
                text += 'ortholog='+speciesKeys[i]+'&';
            }
            $scope.ortholog = text;
            if($scope.speciesTypeKey==3){
                $scope.ortholog1=1;
                $scope.ortholog2=2
            }
            else if($scope.speciesTypeKey==1){
                $scope.ortholog1=2;
                $scope.ortholog2=3;
            }
            else if($scope.speciesTypeKey==2){
                $scope.ortholog1=1;
                $scope.ortholog2=3;
            }
            $scope.mapKey=map;
            $scope.oKey=oKey;
            $scope.a= a;

            if (tool == null) {
                $('#tools-modal').modal('show');
            }else {
                ctrl.toolSubmit(tool);
            }


        }

        ctrl.toolSubmit = function(tool) {

            var lst = document.getElementsByClassName($scope.activeList);

            var geneList = "";
            for (i=0; i< lst.length; i++) {
                if (lst[i].innerHTML.includes("<sup>")) // temp statement to remove alleles
                {
                    continue;
                }
                if (i!=0) {
                    geneList +=",";
                }
                geneList += lst[i].innerHTML
            }

            if($scope.a==null ||$scope.a==""){
                $scope.a="~lst:" + geneList.replace(/\,/g, '[');
            }

            if (geneList.length ==0) {
                alert("List is Empty");

            } else {

                var url="#";
                if (tool == "vv") {

                  /*  if (geneList.length > 4000) {
                        alert("Gene List must be under 4000 Characters.  Variant Visualizer is unavailable for this list.")
                        return;
                    }
                */
                    url = "/rgdweb/front/dist.html?&mapKey="+ $scope.mapKey+ "&geneList=" + geneList;


                    if ($scope.speciesTypeKey != 1) {
                        url += "&con=&depthLowBound=8&depthHighBound=&excludePossibleError=true"   ;
                    }

                    if (location.href.indexOf("sample1") == -1) {
                        url += "&sample1=all"
                    }else {

                        queryString = location.href.split("?")[1];
                        url = url + "&" + queryString;
                    }


                    var f = document.createElement("form");
                    f.setAttribute('method',"post");
                    f.setAttribute('action',url);

                    /*
                    var i = document.createElement("input"); //input element, text
                    i.setAttribute('type',"hidden");
                    i.setAttribute('name',"geneList");
                    i.setAttribute('value',geneList);
                    f.appendChild(i);
                    
                    var i2 = document.createElement("input"); //input element, text
                    i2.setAttribute('type',"hidden");
                    i2.setAttribute('name',"sample1");
                    i2.setAttribute('value',"all");
                    f.appendChild(i2);

                    var i3 = document.createElement("input"); //input element, text
                    i3.setAttribute('type',"hidden");
                    i3.setAttribute('name',"mapKey");
                    i3.setAttribute('value',$scope.mapKey);
                    f.appendChild(i3);
                    */
                    document.getElementsByTagName('body')[0].appendChild(f);
                    f.submit();

             /*       url += "&sample1=all";
                    url += "&mapKey=" + $scope.mapKey;

                    url += "&geneList=" + geneList;
                    location.href=url;*/
                }else if (tool == "ga") {
                   url = "/rgdweb/ga/ui.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=56&x=36&x=52&x=40&x=31&x=45&x=29&x=32&x=48&x=23&x=33&x=50&x=17&x=2&x=20&x=54&x=57&x=27&x=41&x=35&x=49&x=5&x=55&x=42&x=10&x=38&x=3&x=6&x=15&x=1&x=53&x=37&x=7&x=34&x=43&x=39&x=30&x=4&x=21&x=44&x=14&x=22&x=51&x=16&x=24&"+ $scope.ortholog +"species=" + $scope.speciesTypeKey + "&chr=1&start=&stop=";
                    url += "&mapKey=" + $scope.mapKey;

                    var f = document.createElement("form");
                    f.setAttribute('method',"post");
                    f.setAttribute('action',url);

                    var i = document.createElement("input"); //input element, text
                    i.setAttribute('type',"hidden");
                    i.setAttribute('name',"genes");
                    i.setAttribute('value',geneList);

                    f.appendChild(i);
                    document.getElementsByTagName('body')[0].appendChild(f);
                    f.submit();

                    //url += "&genes=" + geneList;
                    //window.open(url);
                }else if (tool=="excel") {
                    //var url = "/rgdweb/gviewer/download.html?";
                    //url += "mapKey=" + document.getElementById("mapKey_tmp").options[document.getElementById("mapKey_tmp").selectedIndex].value;
                    //url += "&genes=" + getResultSet();

                    if (typeof $scope.oKey === 'undefined' || $scope.oKey === null) {
                        url = "/rgdweb/generator/process.html?&mapKey=" + $scope.mapKey + "&oKey=1&vv=&ga=&act=excel&a=" + $scope.a;
                    } else{
                        url = "/rgdweb/generator/process.html?&mapKey=" + $scope.mapKey + "&oKey=" + $scope.oKey + "&vv=&ga=&act=excel&a=" + $scope.a;
                    }

                    var f = document.createElement("form");
                    f.setAttribute('method',"post");
                    f.setAttribute('action',url);

              /*      var i = document.createElement("input"); //input element, text
                    i.setAttribute('type',"hidden");
                    i.setAttribute('name',"a");
                  //  console.log(geneList);
                    i.setAttribute('value',$scope.a);
                 //   console.log(geneList.replace(/\,/g, '['));
                    f.appendChild(i);*/
                    document.getElementsByTagName('body')[0].appendChild(f);
                    f.submit();

                    //window.open(url);

                   // processList("excel");
                }else if (tool == "gviewer") {
                    url = "/rgdweb/ga/genome.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=56&x=36&x=52&x=40&x=31&x=45&x=29&x=32&x=48&x=23&x=33&x=50&x=17&x=2&x=20&x=54&x=57&x=27&x=41&x=35&x=49&x=5&x=55&x=42&x=58&x=38&x=3&x=10&x=15&x=1&x=6&x=37&x=7&x=53&x=43&x=39&x=34&x=4&x=21&x=30&x=14&x=22&x=44&x=60&x=24&x=51&x=16&"+$scope.ortholog+"species=" + $scope.speciesTypeKey + "&chr=1&start=&stop=&mapKey=" + $scope.mapKey;

                    var f = document.createElement("form");
                    f.setAttribute('method',"post");
                    f.setAttribute('action',url);

                    var i = document.createElement("input"); //input element, text
                    i.setAttribute('type',"hidden");
                    i.setAttribute('name',"genes");
                    i.setAttribute('value',geneList);

                    f.appendChild(i);
                    document.getElementsByTagName('body')[0].appendChild(f);
                    f.submit();


                   // "&genes=" + geneList +
                        //var url = "/rgdweb/generator/process.html?a=~lst:" + geneList.replace(/\,/g, '[') + "&mapKey=" + $scope.mapKey + "&oKey=1&vv=&ga=&act=browse";
                    //processList("browse");
                 //   window.open(url);
                }else if (tool == "sv") {
                    //alert("saving list");
                    saveList();
                }else if (tool == "interviewer") {
                   url = "/rgdweb/cytoscape/cy.html?browser=12&species=" + $scope.speciesTypeKey ;

                    var f = document.createElement("form");
                    f.setAttribute('method',"post");
                    f.setAttribute('action',url);

                    var i = document.createElement("input"); //input element, text
                    i.setAttribute('type',"hidden");
                    i.setAttribute('name',"identifiers");
                    i.setAttribute('value',geneList);

                    f.appendChild(i);
                    document.getElementsByTagName('body')[0].appendChild(f);
                    f.submit();


//                    window.open(url);
                }else if (tool == "annotCompare") {
                    url = "/rgdweb/ga/termCompare.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=40&x=36&x=52&x=29&x=31&x=45&x=23&x=32&x=48&x=17&x=33&x=50&x=54&x=2&x=20&x=41&x=57&x=27&x=5&x=35&x=49&x=58&x=55&x=42&x=10&x=38&x=3&x=6&x=15&x=1&x=53&x=37&x=7&x=34&x=43&x=39&x=46&x=4&x=21&x=30&x=14&x=22&x=44&x=60&x=24&x=51&x=16&x=56&"+$scope.ortholog +"term1=DOID%3A4&term2=PW%3A0000001";
                    url +="&species=" + $scope.speciesTypeKey +  "&chr=1&start=&stop=&mapKey=" + $scope.mapKey;

                    var f = document.createElement("form");
                    f.setAttribute('method',"post");
                    f.setAttribute('action',url);

                    var i = document.createElement("input"); //input element, text
                    i.setAttribute('type',"hidden");
                    i.setAttribute('name',"genes");
                    i.setAttribute('value',geneList);

                    f.appendChild(i);
                    document.getElementsByTagName('body')[0].appendChild(f);
                    f.submit();


//                    window.open(url);
                } else if (tool == "olga") {
                  url = "/rgdweb/generator/list.html?mapKey=" + $scope.mapKey + "&oKey=1&vv=&ga=&act=";

                    var f = document.createElement("form");
                    f.setAttribute('method',"post");
                    f.setAttribute('action',url);

                    var i = document.createElement("input"); //input element, text
                    i.setAttribute('type',"hidden");
                    i.setAttribute('name',"a");
                    i.setAttribute('value',"~lst:" + geneList.replace(/\,/g, '['));

                    f.appendChild(i);
                    document.getElementsByTagName('body')[0].appendChild(f);
                    f.submit();



                    // window.open(url);
                }else if (tool == "damage") {

                    if (geneList.length > 2000) {
                        alert("Gene List must be under 2000 Characters.  Variant Visualizer is unavailable for this list.")
                        return;
                    }

                    var damaging = $scope.speciesTypeKey == 1 ? "&cs_pathogenic=true" : "&probably=true&possibly=true&excludePossibleError=true";
                    url = "/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=&geneList=" + geneList + "&mapKey=" + $scope.mapKey + "&con=&depthLowBound=8&depthHighBound=" + damaging;

                    if (location.href.indexOf("sample1") == -1) {
                        url += "&sample1=all"
                    }else {

                        queryString = location.href.split("?")[1];
                        url = url + "&" + queryString;
                    }
                    location.href=url;
                }
                else if (tool == "distribution") {

                    url = "/rgdweb/ga/analysis.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=56&x=36&x=52&x=40&x=31&x=45&x=29&x=32&x=48&x=23&x=33&x=50&x=17&x=2&x=20&x=54&x=57&x=27&x=41&x=35&x=49&x=5&x=55&x=42&x=10&x=38&x=3&x=6&x=15&x=1&x=53&x=37&x=7&x=34&x=43&x=39&x=30&x=4&x=21&x=44&x=14&x=22&x=51&x=16&x=24&" + $scope.ortholog+ "species=" + $scope.speciesTypeKey + "&chr=1&start=&stop=";
                    url += "&mapKey=" + $scope.mapKey + "&a=" +$scope.a


                    var f = document.createElement("form");
                    f.setAttribute('method',"post");
                    f.setAttribute('action',url);

                    var i = document.createElement("input"); //input element, text
                    i.setAttribute('type',"hidden");
                    i.setAttribute('name',"genes");
                    i.setAttribute('value',geneList);

                    f.appendChild(i);
                    document.getElementsByTagName('body')[0].appendChild(f);
                    f.submit();



  //                  url += "&genes=" + geneList;
//                    window.open(url);
                }
                else if (tool == "enrichment") {

                    params = new Object();
                    var form = document.createElement("form");
                    var method = "POST";
                    form.setAttribute("method", method);
                    form.setAttribute("action", "/rgdweb/enrichment/analysis.html");
                    params.species = [$scope.speciesTypeKey];
                    params.genes = geneList;
                    params.o = ["RDO"];
                    for (var key in params) {
                        var hiddenField = document.createElement("input");
                        hiddenField.setAttribute("type", "hidden");
                        hiddenField.setAttribute("name", key);
                        hiddenField.setAttribute("value", params[key]);
                        form.appendChild(hiddenField);
                    }

                    document.body.appendChild(form);
                    form.submit();



                    //                  url += "&genes=" + geneList;
//                    window.open(url);
                } else if (tool == "golf") {

                    params = new Object();
                    var form = document.createElement("form");
                    var method = "POST";
                    form.setAttribute("method", method);
                    form.setAttribute("action", "/rgdweb/ortholog/report.html");
                    params.inSpecies = $scope.speciesTypeKey;
                    params.inMapKey = $scope.mapKey;
                    params.genes = geneList;
                    if(params.inSpecies == 1) {
                        params.outSpecies = 3;
                        params.outMapKey = 360;
                    }else {
                        params.outSpecies = 1;
                        params.outMapKey = 38;
                    }
                    for (var key in params) {
                        var hiddenField = document.createElement("input");
                        hiddenField.setAttribute("type", "hidden");
                        hiddenField.setAttribute("name", key);
                        hiddenField.setAttribute("value", params[key]);
                        form.appendChild(hiddenField);
                    }

                    document.body.appendChild(form);
                    form.submit();



                    //                  url += "&genes=" + geneList;
//                    window.open(url);
                }

                //location.href=url;

            }

        }



        angular.element(document).ready(function () {
            ctrl.setUser();
            ctrl.setWatchers($scope.pageObject);
        });
    }
]);
