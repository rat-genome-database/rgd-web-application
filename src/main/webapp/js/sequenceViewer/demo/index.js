/*import GenomeFeatureViewer from 'GenomeFeatureViewer';
import {TRACK_TYPE} from "../tracks/TrackTypeEnum";*/

// const BASE_URL = 'http://localhost:8080/apollo';
// const BASE_URL = 'http://54.91.83.120:8080/apollo';
// const BASE_URL = 'https://agr-apollo.berkeleybop.io/apollo';
//const BASE_URL = 'https://build.alliancegenome.org/apollo';
//const BASE_URL = 'https://www.alliancegenome.org/apollo';
//const BASE_URL = 'https://dev.rgd.mcw.edu/rgdws/scge';
const BASE_URL = 'https://rest.rgd.mcw.edu/rgdws/scge';

// Global View Example

//oldExamples();
//isoformExamples();
//wormExamples();
//fishExamples();
//ratExamples();
//mouseExamples();
//flyExamples();
//covidExamples();
//window.onload("currentExamples()");

//var chr='5';
//var start="121405170";
//var stop="121417273";
//var guideId="10000000089";
//var guide='{"guide_id":10000000089,"species":"human","targetLocus":"AAVS1","targetSequence":"GTCACCAATCCTGTCCCTAG","pam":"GTCACCAATCCTGTCCCTAGNGG","assembly":"hg38","chr":"chr19","start":"55115744","stop":"55115767","strand":"+","grnaLabId":"AAVS1_site_01","spacerLength":"20","spacerSequence":"GUCACCAAUCCUGUCCCUAG","repeatSequence":"","guide":"AAVS1_site_01","forwardPrimer":"CTGCCTAACAGGAGGTGGGGGTT","reversePrimer":"ACCCGGGCCCCTATGTCCACTTC","linkerSequence":"","antiRepeatSequence":"","stemloop1Sequence":"","stemloop2Sequence":"","stemloop3Sequence":"","source":"lab IVT","guideFormat":"sgRNA","modifications":"none","guideDescription":"Targets AAVS1 safe harbor locus","standardScaffoldSequence":"yes","tier":4,"ivtConstructSource":"Addgene","vectorId":"153997","vectorName":"pCRL01","vectorDescription":"Plasmid for single guide RNA IVT","vectorType":"plasmid","annotatedMap":"addgene-plasmid-153997-sequence-304516","specificityRatio":"0.02","guideCompatibility":"SpyCas9"}';

function loadSequenceViewer() {

    currentExamples();
}

function getTranscriptTypes(){
    return ['mRNA', 'ncRNA', 'piRNA', 'lincRNA', 'miRNA', 'pre_miRNA', 'snoRNA', 'lnc_RNA', 'tRNA', 'snRNA', 'rRNA', 'ARS', 'antisense_RNA', 'C_gene_segment', 'V_gene_segment', 'pseudogene_attribute','snoRNA_gene','polypeptide_region','mature_protein_region'];
}

function covidExamples(){
    createCoVExample("NC_045512.2:17894..28259", "SARS-CoV-2", "covidExample1", TRACK_TYPE.ISOFORM, false);
}
var range="";
function currentExamples(){
//    createIsoformExample(range, "human", "viewerActnFly", TRACK_TYPE.ISOFORM, false);
    console.log("Map key in current examples"+mapKey)
    var url=  "https://rest.rgd.mcw.edu/rgdws/genes/mapped/"+chr+"/"+start+"/"+stop+"/" + mapKey;
    getGenomeInfo(url, guide);

//   createExample("X:2023822..2042311", "fly", "viewerActnFly", TRACK_TYPE.ISOFORM_AND_VARIANT, true,["FB:FBal0212726","FB:FBal0000277","FB:FBal0000276"],['FBtr0070344','FBtr0070346']);
    //createExample("8:57320983..57324517", "mouse", "viewerHand2Mouse", TRACK_TYPE.ISOFORM_AND_VARIANT, false,[],['ENSMUST00000185635']);
    //createExample("9:42732992..42873700", "zebrafish", "viewerHighlightExample", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
    //createCoVExample("NC_045512.2:17894..28259", "SARS-CoV-2", "covidExample1", TRACK_TYPE.ISOFORM, false);
    //createHTPExample("X:2023822..2042311", "fly", "viewerActnHTPFly", TRACK_TYPE.ISOFORM, false,[],'Actn','X:2037135');
}
var  otherGuides="";
// function getGenomeInfo(url){
//
//     $.ajax({
//         url:url,
//         type:"GET",
//         success:function (geneInfo) {
//             const mappedGeneChr=geneInfo[0].chromosome;
//             const mappedGeneStart=geneInfo[0].start;
//             const mappedGeneStop=geneInfo[0].stop;
//             console.log(mappedGeneChr+":"+mappedGeneStart+".."+mappedGeneStop);
//             range= mappedGeneChr+":"+mappedGeneStart+".."+mappedGeneStop;
//              getOtherGuidesJson(mappedGeneStart, mappedGeneStop, range, guideId);
//                 console.log("OTHER: "+ otherGuides);
//             $("#range").html("<p><strong>Gene Location:</strong>"+range+"</p>");
//
//         }
//     });
//
// }
function getGenomeInfo(url){
    $.ajax({
        url:url,
        type:"GET",
        success:function (geneInfo) {
            if ((!geneInfo || geneInfo.length === 0) && typeof hasVariantData !== 'undefined' && hasVariantData) {
                let viewStart = Math.max(1, start - 5000);
                let viewEnd = stop + 5000;
                geneInfo = [{
                    chromosome: chr,
                    start: viewStart,
                    stop: viewEnd,
                    mapKey: mapKey
                }];
                console.log('Created dummy coordinates:', viewStart, 'to', viewEnd);
            }
            const mappedGeneChr=geneInfo[0].chromosome;
            const mappedGeneStart=geneInfo[0].start;
            const mappedGeneStop=geneInfo[0].stop;
            console.log('Genes returned by service:', geneInfo);
            console.log('MapKey used:', mapKey);
            console.log('Query coordinates:', chr+"/"+start+"/"+stop+"/" + mapKey);
            range= mappedGeneChr+":"+mappedGeneStart+".."+mappedGeneStop;
            console.log("mapkey in getGenomeInfo "+geneInfo[0].mapKey)
            console.log('in get genome method');
            console.log('hasVariantData check:', typeof hasVariantData !== 'undefined');
            console.log('otherGuides available:', typeof otherGuides !== 'undefined');

            if (typeof hasVariantData !== 'undefined' && hasVariantData) {
                console.log('About to call handle with variant data');
                console.log('variantData before parse:', variantData);
                try {
                    var parsedData = JSON.parse(variantData);
                    console.log('Parsed data:', parsedData);
                    handle(parsedData, range);
                } catch (e) {
                    console.error('JSON parse error:', e);
                    console.error('Invalid JSON:', variantData);
                }
            }
            else{
                console.log('Loading gene/guide data');

                handle("", range)
            }

            $("#range").html("<p><strong>Gene Location:</strong>"+range+"</p>");
        }
    });
}
function handle(data, range){
     var otherGuides=JSON.stringify(data);
    if (typeof hasVariantData !== 'undefined' && hasVariantData) {
        var species = typeof speciesName !== 'undefined' ? speciesName : 'rat';
        createExample(range, species, "viewerActnFly", TRACK_TYPE.ISOFORM_AND_VARIANT, true, null, null, guide, otherGuides);
    }
    else {
        // Original gene logic
        createIsoformExample(range, geneSpecies, "viewerActnFly", TRACK_TYPE.ISOFORM, true);
    }
}
function flyExamples() {
    // 2L:132412..230018
// http://localhost:8080/apollo/vcf/remotefly/Phenotypic%20Variants/2L:132412..230018.json?includeGenotypes=false&ignoreCache=true
// http://localhost:8080/apollo/track/remotefly/All%20Genes/2L:132412..230018.json?includeGenotypes=false&ignoreCache=true
    createExample("2L:130639..135911", "fly", "viewerFlyExample1", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true);
    createExample("2R:23974973..23989002", "fly", "viewerFlyExample3", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true, ['NT_033778.4:g.23975146T>C']);
    createExample("2R:23974973..23989002", "fly", "viewerFlyExample2", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true);
    createExample("2L:130639..135911", "fly", "viewerFlyExample1NoLabel", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, false);
    createExample("2R:23974973..23989002", "fly", "viewerFlyExample3NoLabel", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, false, ['NT_033778.4:g.23975146T>C']);
    createExample("2R:23974973..23989002", "fly", "viewerFlyExample2NoLabel", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, false);
    createExample("2R:23974973..23989002", "fly", "viewerFlyExample2NoLabelAnd", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
    createExample("3R:22693140..22699809", "fly", "viewerFlyExample3", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
    createExample("2R:23974972..23989001", "fly", "viewerFlyExample4", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
    createExample("3R:22693140..22699809", "fly", "viewerFlyExample5", TRACK_TYPE.ISOFORM_AND_VARIANT, false,["FB:FBal0265700", "FB:FBal0265699"]);
    createExample("2R:18614210..18615018", "fly", "viewerFlyExample6", TRACK_TYPE.ISOFORM_AND_VARIANT, false,["FB:FBal0325512"]);
    createExample("X:2023822..2043557", "fly", "viewerFlyExample7", TRACK_TYPE.ISOFORM_AND_VARIANT, false,["FB:FBal0212726"]);
}

function ratExamples() {
    // http://localhost:8080/apollo/vcf/remotemouse/Phenotypic%20Variants/6:113619452..113636198.json?includeGenotypes=false&ignoreCache=true
    // http://localhost:8080/apollo/track/remotemouse/All%20Genes/6:113619452..113636198.json?includeGenotypes=false&ignoreCache=true  let configGlobal1 = {
    createExample("10:94485648..94489071", "rat", "networkExampleRat1", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true, null);
    createExample("10:94485648..94489071", "rat", "networkExampleRat1And", TRACK_TYPE.ISOFORM_AND_VARIANT, true, null);
    createExample("1:34987290..35280466", "rat", "viewerRatExample1", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true);
    createExample("1:34987290..35280466", "rat", "viewerRatExample1NoLabel", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, false);
}

function mouseExamples() {
    // http://localhost:8080/apollo/vcf/remotemouse/Phenotypic%20Variants/6:113619452..113636198.json?includeGenotypes=false&ignoreCache=true
    // http://localhost:8080/apollo/track/remotemouse/All%20Genes/6:113619452..113636198.json?includeGenotypes=false&ignoreCache=true  let configGlobal1 = {
    createExample("18:11035719..11058885", "mouse", "viewerMouseExample6", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
    createIsoformExample("18:11042037..11052567", "mouse", "viewerMouseExample5", TRACK_TYPE.ISOFORM, false);
    createExample("17:46007760..46041588", "mouse", "viewerMouseExample4", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
    createExample("11:69550420..69563869", "mouse", "viewerMouseExample3", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
    createExample("3:115707662..115717830", "mouse", "viewerMouseExample2", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
    createExample("6:113619452..113636198", "mouse", "viewerMouseExample1", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true);
    createExample("6:113619452..113636198", "mouse", "viewerMouseExample1NoLabel", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, false);
    createExample("6:113619452..113636198", "mouse", "viewerMouseExample1NoLabelAnd", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
}

function fishExamples() {
    createExample("14:5383966..5390885", "zebrafish", "viewerFishLbx2", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true);
    createExample("8:40452405..40469627", "zebrafish", "viewerFishMyl7", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true);
    createExample("14:5383966..5390885", "zebrafish", "viewerFishLbx2NoLabel", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, false);
    createExample("14:5383966..5390885", "zebrafish", "viewerFishLbx2NoLabelAnd", TRACK_TYPE.ISOFORM_AND_VARIANT, false);
    createExample("14:5383966..5390885", "zebrafish", "viewerFishLbx2NoLabelAndNameOnly", TRACK_TYPE.ISOFORM_AND_VARIANT, false, ['NC_007125.7:g.5388210A>T']);
    createExample("14:5383966..5390885", "zebrafish", "viewerFishLbx2NoLabelAndSymbolOnly", TRACK_TYPE.ISOFORM_AND_VARIANT, false, ['hu3336']);
    createExample("8:40452405..40469627", "zebrafish", "viewerFishMyl7NoLabel", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, false);
}


function wormExamples() {
    createExample("V:7106..57424", "worm", "viewerWormEgl8", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true);
    createExample("V:7106..57424", "worm", "viewerWormEgl8NoLabel", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, false);
    createExample("V:7114..57432", "worm", "networkExampleWorm1", TRACK_TYPE.ISOFORM_EMBEDDED_VARIANT, true, null);
    createExample("V:7114..57432", "worm", "networkExampleWorm1And", TRACK_TYPE.ISOFORM_AND_VARIANT, true, null);
}


function isoformExamples() {
    createIsoformExample("chrIV:1276345..1277478", "yeast", "yeastExampleIsoformOnly", TRACK_TYPE.ISOFORM, true);
    createIsoformExample("25:15029041..15049781", "zebrafish", "zebrafishExampleIsoformOnly", TRACK_TYPE.ISOFORM, true);
}

function createExample(range, genome, divId, type, showLabel, variantFilter,isoformFilter,guide, otherGuides) {
    const chromosome = range.split(":")[0];
    const [start, end] = range.split(":")[1].split("..");
    const ratio = 0.01;
    let configGlobal1 = {
        "locale": "global",
        "chromosome": chromosome,
        "start": start,
        "end": end,
        "showVariantLabel": showLabel,
        "transcriptTypes": getTranscriptTypes(),
        "isoformFilter": isoformFilter || [],
        "variantFilter": variantFilter || [],
        "binRatio": ratio,
        "guide":guide,
        "otherGuides":otherGuides,
        "tracks": [
            {
                "id": 12,
                "genome": genome,
                "type": type,
                "mapKey": mapKey,
                "isoform_url": [
                    `${BASE_URL}/track/`,
                    "/All%20Genes/",
                    ".json?ignoreCache=true"
                ],
                "variant_url": [
                    `${BASE_URL}/vcf/`,
                    "/Variants/",
                    ".json"
                ]

            }
        ]
    };
    // const gfc = new GenomeFeatureViewer(configGlobal1, `#${divId}`, 900, 500);
    const gfc=  (new GenomeFeatureViewer(configGlobal1, `#${divId}`, 900, 500));
    const closeButton = document.getElementById(divId + 'CloseButton');
    if (closeButton) {
        closeButton.addEventListener('click', () => {
            gfc.closeModal();
        })
    }

    // const legendButton = document.getElementById(divId+'LegendButton');
    const legendTarget = document.getElementById(divId + 'LegendTarget');
    if (legendTarget) {
        legendTarget.innerHTML = gfc.generateLegend();
        // legendButton.addEventListener( 'click', () => {
        //   console.log('1');
        //   legendTarget.innerHTML = gfc.generateLegend() ;
        //   console.log('2')
        // })
    }



    if(divId==='networkExampleWorm1And'){
        document.getElementById("wormbutton").addEventListener("click", function(){
            gfc.setSelectedAlleles(["WB:WBVar00089535","WB:WBVar02125540","WB:WBVar00242477"], '#networkExampleWorm1And');
        });
        document.getElementById("clrbutton").addEventListener("click", function(){
            gfc.setSelectedAlleles([], '#networkExampleWorm1And');
        });
    }
    if(divId==='viewerFlyExample2NoLabelAnd'){
        document.getElementById("flybutton").addEventListener("click", function(){
            gfc.setSelectedAlleles(["FB:FBal0242675","FB:FBal0302371","FB:FBal0012433"], '#viewerFlyExample2NoLabelAnd');
        });
        document.getElementById("clrbuttonfly").addEventListener("click", function(){
            gfc.setSelectedAlleles([], '#viewerFlyExample2NoLabelAnd');
        });
    }
    if(divId==='viewerHighlightExample'){
        document.getElementById("mausbutton").addEventListener("click", function(){
            gfc.setSelectedAlleles(["ZFIN:ZDB-ALT-130411-164"], '#viewerHighlightExample');
        });
        document.getElementById("clrbuttonmaus").addEventListener("click", function(){
            gfc.setSelectedAlleles([], '#viewerHighlightExample');
        });
    }

}


function createIsoformExample(range, genome, divId, type, showLabel, variantFilter) {

    const chromosome = range.split(":")[0];
    const [start, end] = range.split(":")[1].split("..");
    const ratio = 0.01;
    let configGlobal1 = {
        "locale": "global",
        "chromosome": chromosome,
        "start": start,
        "end": end,
        "transcriptTypes": getTranscriptTypes(),
        "showVariantLabel": showLabel,
        "variantFilter": variantFilter || [],
        "tracks": [
            {
                "id": 12,
                "genome": genome,
                "type": type,
                "url": [
                    `${BASE_URL}/track/`,
                    "/All%20Genes/",
                    ".json"
                ],
            },
        ]
    };
    new GenomeFeatureViewer(configGlobal1, `#${divId}`, 900, 500);
}

function createHTPExample(range, genome, divId, type, showLabel, variantFilter,geneSymbol,htpVariant) {

    const chromosome = range.split(":")[0];
    console.log(htpVariant);
    const [start, end] = range.split(":")[1].split("..");
    const ratio = 0.01;
    let configGlobal1 = {
        "locale": "global",
        "chromosome": chromosome,
        "start": start,
        "end": end,
        "transcriptTypes": getTranscriptTypes(),
        "showVariantLabel": showLabel,
        "geneSymbol": geneSymbol || '',
        "variantFilter": variantFilter || [],
        "htpVariant": htpVariant,
        "tracks": [
            {
                "id": 12,
                "genome": genome,
                "type": type,
                "url": [
                    `${BASE_URL}/track/`,
                    "/All%20Genes/",
                    ".json?name=Actn&ignoreCache=true"
                ],
            },
        ]
    };
    new GenomeFeatureViewer(configGlobal1, `#${divId}`, 900, 500);
}

function createCoVExample(range, genome, divId, type, showLabel, variantFilter) {

    const chromosome = range.split(":")[0];
    const [start, end] = range.split(":")[1].split("..");
    let configGlobal1 = {
        "locale": "global",
        "chromosome": chromosome,
        "start": start,
        "end": end,
        "transcriptTypes": getTranscriptTypes(),
        "showVariantLabel": showLabel,
        "variantFilter": variantFilter || [],
        "tracks": [
            {
                "id": 12,
                "genome": genome,
                "type": type,
                "url": [
                    `${BASE_URL}/track/`,
                    "/Mature%20peptides/",
                    ".json?ignoreCache=true&flatten=false"
                ],
            },
        ]
    };
    new GenomeFeatureViewer(configGlobal1, `#${divId}`, 900, 500);
}


function oldExamples() {

    let configGlobal1 = {
        "locale": "global",
        "chromosome": 5,
        "start": 75574916,
        "end": 75656722,
        "tracks": [
            {
                id: 2,
                "genome": "Mus musculus",
                "type": TRACK_TYPE.VARIANT_GLOBAL,
            },
            {
                "id": 1,
                "genome": "Mus musculus",
                "type": TRACK_TYPE.ISOFORM,
                "url": [
                    `${BASE_URL}/apollo/track/`,
                    "/All%20Genes/",
                    ".json"
                ]
            },
        ]
    };

    new GenomeFeatureViewer(configGlobal1, "#viewer1", 700, null);

    let configGlobal2 = {
        "locale": "global",
        "chromosome": "2L",
        "start": 19400752,
        "end": 19426596,
        "transcriptTypes": [
            'mRNA', 'ncRNA', 'piRNA',
            'lincRNA',
            'miRNA',
            'pre_miRNA',
            'snoRNA',
            'lnc_RNA',
            'tRNA',
            'snRNA',
            'rRNA',
            'ARS',
            'antisense_RNA',


            'C_gene_segment',
            'V_gene_segment',
            'pseudogene_attribute',
            'snoRNA_gene'
        ],
        "tracks": [
            {
                "id": 1,
                "genome": "Drosophila melanogaster",
                "type": TRACK_TYPE.ISOFORM,
                "url": [
                    `${BASE_URL}/apollo/track/`,
                    "/All%20Genes/",
                    ".json?name=Pax"
                ]
            },
        ]
    };

    new GenomeFeatureViewer(configGlobal2, "#viewer2", 700, null);

// Local View Example
// Right now we enter in with a specific location, center it in the viewer.
// TODO: Enable a range and start the left most value on the viewer.
    let configLocal3 = {
        "locale": "local",
        "chromosome": 5,
        "start": 48515461,
        "end": 48515461,
        "centerVariant": true,
        "tracks": [
            {
                "id": 1,
                "label": "Case Variants",
                "type": TRACK_TYPE.VARIANT,
                "chromosome": 5,
            },
            {
                "id": 2,
                "label": "ClinVar Cases",
                "type": TRACK_TYPE.VARIANT,
                "chromosome": 5,
            }
        ]
    };


    new GenomeFeatureViewer(configLocal3, "#viewer3", 900, 400);

}
