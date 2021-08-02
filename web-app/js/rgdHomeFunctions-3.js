
function verify(f)
{
    if(f.term.value == null ||f.term.value == "" || f.term.value == " * for wildcard"){
        alert("The form was not submitted because you have to enter a keyword to search on;");
        return false;
    }else{
        return true;
    }
}

function getTabIndex() {
    var menuMap = new Array(new Array(0), new Array("/data-entry", "/report", "/genes", "/objectSearch","/GO", "/strains/","/ests", "/maps",  "/sequences", "/references", "/data-menu", "/ontology","/search"), new Array("/tool-entry", "/VCMAP", "/ontoloty", "/gviewer",  "/sequenceresource", "/ACPHAPLOTYPER" ,"/METAGENE", "/front" , "/GENOMESCANNER", "/tool-menu","/plfRGD", "gbreport","GenomeErrorReport"), new Array("/tools/Diseases","/dportal","/portal") , new Array("/physiology", "/strains-and-models", "/strain-availability", "/phenotype-data13","blood-pressure","heart-rate", "glucose-level", "protein-excretion", "urine-electrolytes","body-weight","organ-weight","ventilation","pulmonary-vascular-resistance","airway-reactivity","vasodilation","vasoconstriction", "phenotyping-methods","cholesterol-level","/aci","/bn","/cop","/ss", "/strain-discussion","/termSelection","/dataTable"), new Array("physgenknockouts","custom_rats","gerrc"), new Array("/home/pathway2","/home/pathway","pathway") ,new Array("nomen","registration-entry","/community-entry","/com-menu","resource-links"), new Array("/curation"));
	var index=0;

	for (i=0; i< menuMap.length; i++) {
		for (j=0; j< menuMap[i].length; j++) {
		        //alert(document.location.href + " " + menuMap[i][j]);
                        //if (ddtabmenu.currentpageurl.indexOf(menuMap[i][j]) != -1) {
                        if (document.location.href.indexOf(menuMap[i][j]) != -1) {
 				return i;
			}
		}
	}
     return index; 
}

