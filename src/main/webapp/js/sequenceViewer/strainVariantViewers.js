/*
 * Sequence viewers for the Allelic Variants section of the strain report.
 *
 * The shared loader (sequenceViewer/demo/index.js) drives a single viewer off page globals
 * - chr, start, stop, mapKey, variantData - which is all the gene and CNV reports need,
 * since each of those has exactly one region to show. A strain can be associated with
 * several allelic variants, each one sitting in a different gene, so each needs its own
 * viewer and its own range lookup. This is that loader, taking the variants as an argument
 * rather than off the window, so any number of them can be drawn on one page.
 *
 * Each entry handed to drawStrainVariantViewers() is:
 *   {divId, rgdId, name, chr, start, stop, mapKey, assembly, species, type, refNuc, varNuc}
 * where type is already one of the viewer's own vocabulary (see IsoformAndVariantTrack).
 */

const STRAIN_VARIANT_WS = 'https://rest.rgd.mcw.edu/rgdws';

// the isoform track is served out of the scge path, same as the other two reports use
const STRAIN_VARIANT_TRACK_WS = STRAIN_VARIANT_WS + '/scge';

// a variant that falls in no gene has no gene model to frame it, so the view becomes the
// variant plus this much sequence either side
const STRAIN_VARIANT_FLANK = 5000;

// the gene model is drawn from transcripts, so the viewer has to be told which child types
// count as one - the same list the shared loader uses
function strainVariantTranscriptTypes() {
    return ['mRNA', 'ncRNA', 'piRNA', 'lincRNA', 'miRNA', 'pre_miRNA', 'snoRNA', 'lnc_RNA',
        'tRNA', 'snRNA', 'rRNA', 'ARS', 'antisense_RNA', 'C_gene_segment', 'V_gene_segment',
        'pseudogene_attribute', 'snoRNA_gene', 'polypeptide_region', 'mature_protein_region'];
}

function fetchStrainVariantJson(url) {
    return fetch(url).then(function (response) {
        return response.ok ? response.json() : [];
    });
}

/*
 * Work out the window to draw the variant in.
 *
 * A variant inside a gene is framed by that gene's full span, which is what puts the
 * marker on the exon it actually hits. One that lands between genes gets a plain window
 * around itself, refined to the transcript range if the padded window happens to catch a
 * neighbouring gene. Either way the span is finally widened to contain the variant, which
 * matters for a deletion that runs off the end of the gene it starts in.
 */
async function resolveStrainVariantRange(variant) {
    let fmin;
    let fmax;
    let locus = variant.name;

    try {
        const genes = await fetchStrainVariantJson(STRAIN_VARIANT_WS + '/genes/mapped/'
            + variant.chr + '/' + variant.start + '/' + variant.stop + '/' + variant.mapKey);
        if (genes && genes.length > 0) {
            fmin = genes[0].start;
            fmax = genes[0].stop;
            if (genes[0].gene && genes[0].gene.symbol) {
                locus = genes[0].gene.symbol;
            }
        }
    } catch (e) {
        console.warn('could not look up the gene for variant RGD:' + variant.rgdId, e);
    }

    if (fmin === undefined) {
        fmin = Math.max(1, variant.start - STRAIN_VARIANT_FLANK);
        fmax = variant.stop + STRAIN_VARIANT_FLANK;
        try {
            const transcripts = await fetchStrainVariantJson(STRAIN_VARIANT_TRACK_WS + '/track/'
                + encodeURIComponent(variant.species) + '/All%20Genes/'
                + encodeURIComponent(variant.chr + ':' + fmin + '..' + fmax)
                + '.json?ignoreCache=true&mapKey=' + variant.mapKey);
            if (transcripts && transcripts.length > 0) {
                // findRange() comes from RenderFunctions.js and is what the track itself
                // uses, so asking it the same question keeps the axis and the gene model
                // on one set of coordinates
                const transcriptRange = findRange(transcripts, ['mRNA']);
                if (transcriptRange.fmin !== -1 && transcriptRange.fmax !== -1) {
                    fmin = transcriptRange.fmin;
                    fmax = transcriptRange.fmax;
                }
            }
        } catch (e) {
            console.warn('no transcripts around variant RGD:' + variant.rgdId
                + ', drawing a plain window', e);
        }
    }

    return {
        fmin: Math.min(fmin, variant.start),
        fmax: Math.max(fmax, variant.stop),
        locus: locus
    };
}

function drawStrainVariantViewer(variant, range) {
    // the track reads its variants out of otherGuides as a JSON string - guide is the
    // single-feature form the SCGE guide pages use and stays null here
    const variantData = [{
        name: variant.name,
        type: variant.type,
        fmin: variant.start,
        fmax: variant.stop,
        seqId: variant.chr,
        targetLocus: range.locus,
        assembly: variant.assembly,
        alternative_alleles: variant.varNuc,
        reference_allele: variant.refNuc,
        sequenceChange: variant.refNuc && variant.varNuc
            ? variant.refNuc + ' → ' + variant.varNuc : '',
        guide_ids: {values: [String(variant.rgdId)]}
    }];

    const config = {
        'locale': 'global',
        'chromosome': variant.chr,
        'start': range.fmin,
        'end': range.fmax,
        'showVariantLabel': true,
        'transcriptTypes': strainVariantTranscriptTypes(),
        'isoformFilter': [],
        'variantFilter': [],
        'binRatio': 0.01,
        'guide': null,
        'otherGuides': JSON.stringify(variantData),
        'tracks': [
            {
                'id': 12,
                'genome': variant.species,
                'type': TRACK_TYPE.ISOFORM_AND_VARIANT,
                'mapKey': variant.mapKey,
                'isoform_url': [
                    STRAIN_VARIANT_TRACK_WS + '/track/',
                    '/All%20Genes/',
                    '.json?ignoreCache=true'
                ],
                'variant_url': [
                    STRAIN_VARIANT_TRACK_WS + '/vcf/',
                    '/Variants/',
                    '.json'
                ]
            }
        ]
    };

    new GenomeFeatureViewer(config, '#' + variant.divId, 900, 500);
}

async function loadStrainVariantViewer(variant) {
    try {
        const range = await resolveStrainVariantRange(variant);
        const caption = document.getElementById(variant.divId + 'Range');
        if (caption) {
            caption.innerHTML = '<strong>Region shown:</strong> chr' + variant.chr + ':'
                + range.fmin + '..' + range.fmax + ' (' + variant.assembly + ')';
        }
        drawStrainVariantViewer(variant, range);
    } catch (e) {
        console.error('could not draw the viewer for variant RGD:' + variant.rgdId, e);
    }
}

/*
 * Drawn on first sight rather than on load.
 *
 * Track heights are measured off the rendered DOM - calculateNewTrackPosition() adds up
 * bounding boxes - so a viewer drawn inside a collapsed card measures every track as zero
 * high and stacks them on top of each other, and reportModernUx.js restores a collapsed
 * Allelic Variants card before this ever runs. Waiting for the block to actually appear
 * also keeps the service calls off the page load of a report nobody scrolls that far down.
 */
function drawStrainVariantViewers(variants) {
    if (typeof IntersectionObserver === 'undefined') {
        variants.forEach(loadStrainVariantViewer);
        return;
    }

    const pending = new window.Map();
    const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (!entry.isIntersecting) {
                return;
            }
            const variant = pending.get(entry.target);
            // once only: the viewer replaces the svg's contents on every draw
            pending.delete(entry.target);
            observer.unobserve(entry.target);
            if (variant) {
                loadStrainVariantViewer(variant);
            }
        });
    }, {rootMargin: '200px'});

    variants.forEach(function (variant) {
        // the block is observed rather than the svg: the svg has no size of its own until
        // it is drawn, and a zero-height target is not reliably reported as intersecting
        const block = document.getElementById(variant.divId + 'Block');
        if (block) {
            pending.set(block, variant);
            observer.observe(block);
        } else {
            loadStrainVariantViewer(variant);
        }
    });
}
