var v = new Vue({
    el: '#app',
    data: {
        selected: 0
    },
    methods: {

        viewReport: function (rgdId) {
            document.report.rgdId.value = rgdId;
            document.report.submit();
        },

        setMap: function (obj) {

            var selected = obj.options[obj.selectedIndex].value;

            var maps = document.getElementById("maps");

            if (selected == 1) {

                maps.innerHTML = humanMaps;
                chroms.innerHTML = humanChroms;
            } else if (selected == 2) {
                maps.innerHTML = mouseMaps;
                chroms.innerHTML = mouseChroms;
            } else if (selected == 3) {
                maps.innerHTML = ratMaps;
                chroms.innerHTML = ratChroms;
            } else if (selected == 4) {
                maps.innerHTML = chinMaps;
                chroms.innerHTML = chinChroms;
            } else if (selected == 5) {
                maps.innerHTML = bonoboMaps;
                chroms.innerHTML = bonoboChroms;
            } else if (selected == 6) {
                maps.innerHTML = dogMaps;
                chroms.innerHTML = dogChroms;
            } else if (selected == 7) {
                maps.innerHTML = squiMaps;
                chroms.innerHTML = squiChroms;
            } else if (selected == 9) {
                maps.innerHTML = pigMaps;
                chroms.innerHTML = pigChroms;
            }else if (selected == 13) {
                maps.innerHTML = greenMonkeyMaps;
                chroms.innerHTML = greenMonkeyChroms;
            }else if (selected == 14) {
                maps.innerHTML = moleRatMaps;
                chroms.innerHTML = moleRatChroms;
            }else if (selected == 17) {
                maps.innerHTML = blackRatMaps;
                chroms.innerHTML =blackRatChroms;
            }else {
                maps.innerHTML = ratMaps;
                chroms.innerHTML = ratChroms;
            }
        },

        validate: function () {

            var x =  document.forms["enrichment"]["genes"].value;
            var y =  document.forms["enrichment"]["start"].value;
            var z =  document.forms["enrichment"]["idType"].value;
            if(x == "" && y=="") {
                alert("Please enter genes or position");
                return false;
            }
            if(x != "" && z == "") {
                alert("Please enter idType");
                return false;
            }
        }
    }
})