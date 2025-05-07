/*import * as d3 from "d3";
import {calculateNewTrackPosition, checkSpace, findRange} from '../RenderFunctions';
import {
  generateDelinsPoint,
  generateInsertionPoint,
  generateSnvPoints,
  generateVariantDataBinsAndDataSets,
  getColorsForConsequences,
  getVariantDescriptions,
  getVariantSymbol,
  renderVariantDescriptions,
  getVariantTrackPositions,
  getVariantAlleles,
} from "../services/VariantService";
import {renderTrackDescription,getJBrowseLink} from "../services/TrackService";
// import {description} from "d3/dist/package";
import {ApolloService} from "../services/ApolloService";*/

let apolloService = new ApolloService();

// TODO: make configurable and a const / default
//let MAX_ROWS = 9;

 class IsoformAndVariantTrack {

  constructor(viewer, track, height, width, transcriptTypes, variantTypes,showVariantLabel,variantFilter,binRatio,isoformFilter) {
    this.trackData = {};
    this.variantData = {};
    this.viewer = viewer;
    this.width = width;
    this.variantFilter = variantFilter;
    this.isoformFilter = isoformFilter;
    this.height = height;
    this.transcriptTypes = transcriptTypes;
    this.variantTypes = variantTypes;
    this.binRatio = binRatio ;
    this.showVariantLabel = showVariantLabel!==undefined ? showVariantLabel : true ;
  }

  // Draw our track on the viewer
  // TODO: Potentially seperate this large section of code
  // for both testing/extensibility
  DrawTrack() {
    let isoformFilter = this.isoformFilter;
    let isoformData= this.trackData;
  //  let variantData = this.filterVariantData(this.variantData, this.variantFilter);
    let variantData = this.variantData;
    let viewer = this.viewer;
    let width = this.width;
    let showVariantLabel = this.showVariantLabel;
    let binRatio = this.binRatio;
    let distinctVariants= getVariantTrackPositions(variantData);
    let numVariantTracks=distinctVariants.length;
    let source = this.trackData[0].source;
    let chr = this.trackData[0].seqId;
    let MAX_ROWS = isoformFilter.length===0 ? 9 : 30;

    let UTR_feats = ["UTR", "five_prime_UTR", "three_prime_UTR"];
    let CDS_feats = ["CDS"];
    let exon_feats = ["exon"];
    let display_feats = this.transcriptTypes;
    let dataRange = findRange(isoformData, display_feats);

    let viewStart = dataRange.fmin;
    let viewEnd = dataRange.fmax;

    // constants
    const EXON_HEIGHT = 10; // will be white / transparent
    const CDS_HEIGHT = 10; // will be colored in
    const ISOFORM_HEIGHT = 40; // height for each isoform
    const GENE_LABEL_HEIGHT = 20 ;
    const MIN_WIDTH = 2;
    const ISOFORM_TITLE_HEIGHT = 0; // height for each isoform
    const UTR_HEIGHT = 10; // this is the height of the isoform running all of the way through
    const VARIANT_HEIGHT = 10; // this is the height of the isoform running all of the way through
    const VARIANT_OFFSET = 20; // this is the height of the isoform running all of the way through
    const TRANSCRIPT_BACKBONE_HEIGHT = 4; // this is the height of the isoform running all of the way through
    const ARROW_HEIGHT = 20;
    const ARROW_WIDTH = 10;
    const ARROW_POINTS = '0,0 0,' + ARROW_HEIGHT + ' ' + ARROW_WIDTH + ',' + ARROW_WIDTH;
    const SNV_HEIGHT = 10;
    const SNV_WIDTH = 10;
    const VARIANT_TRACK_HEIGHT = 40;//Not sure if this needs to be dynamic or not
    const LABEL_PADDING=22.5;

    const insertion_points = (x) => {
      return `${x-(SNV_WIDTH/2.0)},${SNV_HEIGHT} ${x},0 ${x+(SNV_WIDTH/2.0)},${SNV_HEIGHT}`;
    };

    const delins_points = (x) => {
      // const delins_strings = `${x-(snv_width/2.0)},${snv_height} ${x},0 ${x+(snv_width/2.0)},${snv_height}`;
      return `${x-(SNV_WIDTH/2.0)},${SNV_HEIGHT} ${x+(SNV_WIDTH/2.0)},${SNV_HEIGHT} ${x-(SNV_WIDTH/2.0)},${0} ${x+(SNV_WIDTH/2.0)},${0}`;
    };

    let x = d3.scaleLinear()
      .domain([viewStart, viewEnd])
      .range([0, width]);

    //Lets put this here so that the "track" part will give us extra space automagically
    let variantContainer = viewer.append("g").attr("class", "variants track")
      .attr("transform", "translate(0,22.5)");
    //Append Invisible Rect to give space properly if only one track exists.
    //variantContainer.append('rect').style("opacity", 0).attr("height", VARIANT_HEIGHT*numVariantTracks).attr("width",width);

    //need to build a new sortWeight since these can be dynamic
    let sortWeight = {};
    for (let i = 0, len = UTR_feats.length; i < len; i++) {
      sortWeight[UTR_feats[i]] = 200;
    }
    for (let i = 0, len = CDS_feats.length; i < len; i++) {
      sortWeight[CDS_feats[i]] = 1000;
    }
    for (let i = 0, len = exon_feats.length; i < len; i++) {
      sortWeight[exon_feats[i]] = 100;
    }

    let geneList = {};

    isoformData = isoformData.sort(function (a, b) {
      if (a.selected && !b.selected) return -1;
      if (!a.selected && b.selected) return 1;
      return a.name - b.name;
    });

    let heightBuffer = 0 ;

    let tooltipDiv = d3.select("body").append("div")
      .attr("class", "gfc-tooltip")
      .style('visibility', 'visible')
      .style("opacity", 0);

    const closeToolTip = () => {
        tooltipDiv.transition()
          .duration(100)
          .style("opacity", 10)
          .style("visibility","hidden");
    };
    // **************************************
    // Seperate isoform and variant render
    // **************************************
      let variantBins = generateVariantDataBinsAndDataSets(variantData,(viewEnd-viewStart)*binRatio);
      variantBins.forEach(variant => {
        let {type, fmax, fmin} = variant;
        let drawnVariant = true;
        let isPoints = false;
        let viewerWidth = this.width;
        let symbol_string = getVariantSymbol(variant);
        const descriptions = getVariantDescriptions(variant);
        let variant_alleles = getVariantAlleles(variant);
        let descriptionHtml = renderVariantDescriptions(descriptions);
        const consequenceColor = getColorsForConsequences(descriptions)[0];
        const width = Math.ceil(x(fmax)-x(fmin)) < MIN_WIDTH ? MIN_WIDTH : Math.ceil(x(fmax)-x(fmin));
        if (type.toLowerCase() === 'deletion') {
          variantContainer.append('rect')
            .attr('class', 'variant-deletion')
            .attr('id', 'variant-'+fmin)
            .attr('x', x(fmin))
            .attr('transform', 'translate(0,'+VARIANT_HEIGHT*distinctVariants.indexOf("deletion")+')')
            .attr('z-index', 30)
            .attr('fill', consequenceColor)
            .attr('height', VARIANT_HEIGHT)
            .attr('width', width)
            .on("click", d => {
              renderTooltipDescription(tooltipDiv,descriptionHtml,closeToolTip);
          //    let viewer_height= viewer.node().getBBox().height-22.5;
            })
            .on("mouseover", function(d){
              let theVariant = d.variant;
              d3.selectAll(".variant-deletion")
                .filter(function(d){return d.variant === theVariant})
                .style("stroke" , "black");
              d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground").raise()
                .filter(function(d){return d.variant === theVariant})
                .style("opacity", 1);
            })
            .on("mouseout", function(d){
              d3.selectAll(".variant-deletion")
                .filter(function(d){return d.selected != "true"})
                .style("stroke" , null);
              d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground")
                .style("opacity",0);
            })
            .datum({fmin: fmin, fmax: fmax, variant: symbol_string+fmin, alleles: variant_alleles});
        } else if (type.toLowerCase() === 'snv' || type.toLowerCase() === 'point_mutation') {
          isPoints = true;
          variantContainer.append('polygon')
            .attr('class', 'variant-SNV')
            .attr('id', 'variant-'+fmin)
            .attr('points', generateSnvPoints(x(fmin)))
            .attr('fill', consequenceColor)
            .attr('x', x(fmin))
            .attr('transform', 'translate(0,'+VARIANT_HEIGHT*distinctVariants.indexOf("snv")+')')
            .attr('z-index', 30)
            .on("click", d => {
              renderTooltipDescription(tooltipDiv,descriptionHtml,closeToolTip);
          //    let viewer_height= viewer.node().getBBox().height-22.5;
            })
            .on("mouseover", function(d){
              let theVariant = d.variant;
              d3.selectAll(".variant-SNV")
                .filter(function(d){return d.variant === theVariant})
                .style("stroke" , "black");
              d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground").raise()
                .filter(function(d){return d.variant === theVariant})
                .style("opacity", 1);
            })
            .on("mouseout", function(d){
              d3.selectAll(".variant-SNV")
                .filter(function(d){return d.selected != "true"})
                .style("stroke" , null);
              d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground")
                .style("opacity",0);
            })
            .datum({fmin: fmin, fmax: fmax, variant: symbol_string+fmin,  alleles: variant_alleles});
        } else if(type.toLowerCase() === 'grna'){
          isPoints = true;
          variantContainer.append('polygon')
              .attr('class', 'variant-SNV')
              .attr('id', 'variant-'+fmin)
              .attr('points', generateSnvPoints(x(fmin)))
              .attr('fill', "hotpink")
              .attr('x', x(fmin))
              .attr('transform', 'translate(0,'+VARIANT_HEIGHT*distinctVariants.indexOf("grna")+')')
              .attr('z-index', 30)
              .on("click", d => {
                renderTooltipDescription(tooltipDiv,descriptionHtml,closeToolTip);
                //    let viewer_height= viewer.node().getBBox().height-22.5;
              })
              .on("mouseover", function(d){
               let theVariant = d.variant;
                d3.selectAll(".variant-SNV")
                    .filter(function(d){return d.variant === theVariant})
                    .style("stroke" , "black");
                d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground").raise()
                    .filter(function(d){return d.variant === theVariant})
                    .style("opacity", 1);
              })
              .on("mouseout", function(d){
                d3.selectAll(".variant-SNV")
                    .filter(function(d){return d.selected != "true"})
                    .style("stroke" , null);
                d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground")
                    .style("opacity",0);
              })
              .datum({fmin: fmin, fmax: fmax, variant: symbol_string+fmin,  alleles: variant_alleles});

        }

        else if (type.toLowerCase() === 'insertion') {
          isPoints = true;
            variantContainer.append('polygon')
              .attr('class', 'variant-insertion')
              .attr('id', 'variant-'+fmin)
              .attr('points', generateInsertionPoint(x(fmin)))
              .attr('fill', consequenceColor)
              .attr('x', x(fmin))
              .attr('transform', 'translate(0,'+VARIANT_HEIGHT*distinctVariants.indexOf("insertion")+')')
              .attr('z-index', 30)
              .on("click", d => {
                renderTooltipDescription(tooltipDiv,descriptionHtml,closeToolTip);
           //     let viewer_height= viewer.node().getBBox().height-22.5;
              })
              .on("mouseover", function(d){
                let theVariant = d.variant;
                d3.selectAll(".variant-insertion")
                  .filter(function(d){return d.variant === theVariant})
                  .style("stroke" , "black");
                d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground").raise()
                  .filter(function(d){return d.variant === theVariant})
                  .style("opacity", 1);
              })
              .on("mouseout", function(d){
                d3.selectAll(".variant-insertion")
                  .filter(function(d){return d.selected != "true"})
                  .style("stroke" , null);
                d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground")
                  .style("opacity",0);
              })
              .datum({fmin: fmin, fmax: fmax, variant: symbol_string+fmin, alleles: variant_alleles});
        } else if (type.toLowerCase() === 'delins' || type.toLowerCase() === 'substitution' || type.toLowerCase() === 'indel' || type.toLowerCase() === 'mnv') {
          isPoints=true;
          variantContainer.append('polygon')
            .attr('class', 'variant-delins')
            .attr('id', 'variant-'+fmin)
         //   .attr('points', generateDelinsPoint(x(fmin)))
              .attr('points', generateSnvPoints(x(fmin)))
            .attr('x', x(fmin))
            .attr('transform', 'translate(0,'+VARIANT_HEIGHT*distinctVariants.indexOf("delins")+')')
            .attr('fill', 'blue')
            .attr('z-index', 30)
            .on("click", d => {
              renderTooltipDescription(tooltipDiv,descriptionHtml,closeToolTip);
          //    let viewer_height= viewer.node().getBBox().height-22.5;
            })
            .on("mouseover", function(d){
              let theVariant = d.variant;
              d3.selectAll(".variant-delins")
                .filter(function(d){return d.variant === theVariant})
                .style("stroke" , "black");
              d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground").raise()
                .filter(function(d){return d.variant === theVariant})
                .style("opacity", 1);
            })
            .on("mouseout", function(d){
              d3.selectAll(".variant-delins")
                .filter(function(d){return d.selected != "true"})
                .style("stroke" , null);
              d3.select(this.parentNode).selectAll(".variantLabel,.variantLabelBackground")
                .style("opacity",0);
            })
            .datum({fmin: fmin, fmax: fmax, variant: symbol_string+fmin,alleles: variant_alleles});
        }
        else{
          console.warn("type not found",type,variant);
          drawnVariant = false ;
        }

        if(drawnVariant){
          let label_offset=0;
          if(isPoints){
            label_offset = x(fmin)-SNV_WIDTH/2;
          }else {
            label_offset = x(fmin);}

          const symbol_string_length = symbol_string.length ? symbol_string.length : 1;
          let label_height=VARIANT_HEIGHT*numVariantTracks+LABEL_PADDING;
          let variant_label = variantContainer.append('text')
            .attr('class', 'variantLabel')
            .attr('fill', consequenceColor)
            .attr('opacity', 0)
            .attr('height', ISOFORM_TITLE_HEIGHT)
            .attr("transform", "translate("+label_offset+","+label_height+")")
            // if html, it cuts off the <sup> tag
            .text(symbol_string)
            .on("click", d => {
              renderTooltipDescription(tooltipDiv,descriptionHtml,closeToolTip);
            })
            .datum({fmin: fmin, variant: symbol_string+fmin});

       //     let symbol_string_width = variant_label.node().getBBox().width;
          let symbol_string_width=20;
            if(parseFloat(symbol_string_width+label_offset)>viewerWidth){
              let diff = parseFloat(symbol_string_width+label_offset-viewerWidth);
              label_offset-=diff;
              variant_label.attr("transform", "translate("+label_offset+",35)");
            }
        }
      });

    // Calculate where this track should go and translate it, must be after the variant lables are added
    let newTrackPosition = calculateNewTrackPosition(this.viewer);
    let track = viewer.append("g").attr('transform', 'translate(0,' + newTrackPosition + ')').attr("class", "track");

    let row_count = 0;
    let used_space = [];
    let fmin_display = -1;
    let fmax_display = -1;
    let renderTooltipDescription = this.renderTooltipDescription;
    // **************************************
    // FOR NOW LETS FOCUS ON ONE GENE ISOFORM
    // **************************************
    // let feature = data[0];
    for (let i = 0; i < isoformData.length && row_count < MAX_ROWS; i++) {
      let feature = isoformData[i];
      let featureChildren = feature.children;
      if (featureChildren) {

        let selected = feature.selected;

        //May want to remove this and add an external sort function
        //outside of the render method to put certain features on top.
        featureChildren = featureChildren.sort(function (a, b) {
          if (a.name < b.name) return -1;
          if (a.name > b.name) return 1;
          return a - b;
        });


        // For each isoform..
        let warningRendered = false ;
        featureChildren.forEach(function (featureChild) {
              if(featureChild.name.includes("NM")){
          if(!(isoformFilter.indexOf(featureChild.id) >= 0 || isoformFilter.indexOf(featureChild.name) >= 0 ) && isoformFilter.length!==0){
            return;
          }
          //
          let featureType = featureChild.type;

          if (display_feats.indexOf(featureType) >= 0) {
            //function to assign row based on available space.
            // *** DANGER EDGE CASE ***/
            let current_row = checkSpace(used_space, x(featureChild.fmin), x(featureChild.fmax));
            if (row_count < MAX_ROWS) {
              // An isoform container

              let text_string, text_label;
              let addingGeneLabel = false ;
              if(Object.keys(geneList).indexOf(feature.name)<0) {
                heightBuffer += GENE_LABEL_HEIGHT ;
                addingGeneLabel = true ;
                geneList[feature.name] = 'Green';
              }

              let isoform = track.append("g").attr("class", "isoform")
                .attr("transform", "translate(0," + ((row_count * ISOFORM_HEIGHT) + 10 + heightBuffer) + ")")
              ;

              if(addingGeneLabel){
                text_string = feature.name;
                text_label = isoform.append('text')
                  .attr('class', 'geneLabel')
                  .attr('fill', selected ? 'sandybrown' : 'black')
                  .attr('height', ISOFORM_TITLE_HEIGHT)
                  .attr("transform", "translate(" + x(featureChild.fmin) + `,-${GENE_LABEL_HEIGHT})`)
                  .text(text_string)
                  .on("click", d => {
                    renderTooltipDescription(tooltipDiv,renderTrackDescription(feature),closeToolTip);
                  })
                  .datum({fmin: featureChild.fmin});
              }

              isoform.append("polygon")
                .datum(function () {
                  return {fmin: featureChild.fmin, fmax: featureChild.fmax, strand: feature.strand};
                })
                .attr('class', 'transArrow')
                .attr('points', ARROW_POINTS)
                .attr('transform', function (d) {
                  if (feature.strand > 0) {
                    return 'translate(' + Number(x(d.fmax)) + ',0)';
                  } else {
                    return 'translate(' + Number(x(d.fmin)) + ',' + ARROW_HEIGHT + ') rotate(180)';
                  }
                })
                .on("click", d => {
                  renderTooltipDescription(tooltipDiv,renderTrackDescription(featureChild),closeToolTip);
                })
              ;

              isoform.append('rect')
                .attr('class', 'transcriptBackbone')
                .attr('y', 10 + ISOFORM_TITLE_HEIGHT)
                .attr('height', TRANSCRIPT_BACKBONE_HEIGHT)
                .attr("transform", "translate(" + x(featureChild.fmin) + ",0)")
                .attr('width', x(featureChild.fmax) - x(featureChild.fmin))
                .on("click", d => {
                  renderTooltipDescription(tooltipDiv,renderTrackDescription(featureChild),closeToolTip);
                })
                .datum({fmin: featureChild.fmin, fmax: featureChild.fmax});

              text_string = featureChild.name ;
              text_label = isoform.append('text')
                .attr('class', 'transcriptLabel')
                .attr('fill', selected ? 'sandybrown' : 'gray')
                .attr('opacity', selected ? 1 : 0.5)
                .attr('height', ISOFORM_TITLE_HEIGHT)
                .attr("transform", "translate(" + x(featureChild.fmin) + ",0)")
                .text(text_string)
                .on("click", d => {
                  renderTooltipDescription(tooltipDiv,renderTrackDescription(featureChild),closeToolTip);
                })
                .datum({fmin: featureChild.fmin});

              //Now that the label has been created we can calculate the space that
              //this new element is taking up making sure to add in the width of
              //the box.
              // TODO: this is just an estimate of the length
              let text_width = text_string.length * 2;
              let feat_end;


              // not some instances (as in reactjs?) the bounding box isn't available, so we have to guess
              try {
           //     text_width = text_label.node().getBBox().width;
              } catch (e) {
                // console.error('Not yet rendered',e)
              }
              //First check to see if label goes past the end
              if (Number(text_width + x(featureChild.fmin)) > width) {
                // console.error(featureChild.name + " goes over the edge");
              }
              if (text_width > x(featureChild.fmax) - x(featureChild.fmin)) {
                feat_end = x(featureChild.fmin) + text_width;
              } else {
                feat_end = x(featureChild.fmax);
              }

              //This is probably not the most efficent way to do this.
              //Making an 2d array... each row is the first array (no zer0)
              //next level is each element taking up space.
              //Also using colons as spacers seems very perl... maybe change that?
              // *** DANGER EDGE CASE ***/
              if (used_space[current_row]) {
                let temp = used_space[current_row];
                temp.push(x(featureChild.fmin) + ":" + feat_end);
                used_space[current_row] = temp;
              } else {
                used_space[current_row] = [x(featureChild.fmin) + ":" + feat_end]
              }

              //Now check on bounds since this feature is displayed
              //The true end of display is converted to bp.
              if (fmin_display < 0 || fmin_display > featureChild.fmin) {
                fmin_display = featureChild.fmin;
              }
              if (fmax_display < 0 || fmax_display < featureChild.fmax) {
                fmax_display = featureChild.fmax;
              }

              // have to sort this so we draw the exons BEFORE the CDS
              if(featureChild.children){

                featureChild.children = featureChild.children.sort(function (a, b) {

                  let sortAValue = sortWeight[a.type];
                  let sortBValue = sortWeight[b.type];

                  if (typeof sortAValue === 'number' && typeof sortBValue === 'number') {
                    return sortAValue - sortBValue;
                  }
                  if (typeof sortAValue === 'number' && typeof sortBValue !== 'number') {
                    return -1;
                  }
                  if (typeof sortAValue !== 'number' && typeof sortBValue === 'number') {
                    return 1;
                  }
                  // NOTE: type not found and weighted
                  return a.type - b.type;
                });

                featureChild.children.forEach(function (innerChild) {
                  let innerType = innerChild.type;


                  let validInnerType = false;
                  if (exon_feats.indexOf(innerType) >= 0) {
                    validInnerType = true;
                    isoform.append('rect')
                      .attr('class', 'exon')
                      .attr('x', x(innerChild.fmin))
                      .attr('transform', 'translate(0,' + (EXON_HEIGHT - TRANSCRIPT_BACKBONE_HEIGHT) + ')')
                      .attr('height', EXON_HEIGHT)
                      .attr('z-index', 10)
                      .attr('width', x(innerChild.fmax) - x(innerChild.fmin))
                      .on("click", d => {
                        renderTooltipDescription(tooltipDiv,renderTrackDescription(featureChild),closeToolTip);
                      })
                      .datum({fmin: innerChild.fmin, fmax: innerChild.fmax});
                  } else if (CDS_feats.indexOf(innerType) >= 0) {
                    validInnerType = true;
                    isoform.append('rect')
                      .attr('class', 'CDS')
                      .attr('x', x(innerChild.fmin))
                      .attr('transform', 'translate(0,' + (CDS_HEIGHT - TRANSCRIPT_BACKBONE_HEIGHT) + ')')
                      .attr('z-index', 20)
                      .attr('height', CDS_HEIGHT)
                      .attr('width', x(innerChild.fmax) - x(innerChild.fmin))
                      .on("click", d => {
                        renderTooltipDescription(tooltipDiv,renderTrackDescription(featureChild),closeToolTip);
                      })
                      .datum({fmin: innerChild.fmin, fmax: innerChild.fmax});
                  } else if (UTR_feats.indexOf(innerType) >= 0) {
                    validInnerType = true;
                    isoform.append('rect')
                      .attr('class', 'UTR')
                      .attr('x', x(innerChild.fmin))
                      .attr('transform', 'translate(0,' + (UTR_HEIGHT - TRANSCRIPT_BACKBONE_HEIGHT) + ')')
                      .attr('z-index', 20)
                      .attr('height', UTR_HEIGHT)
                      .attr('width', x(innerChild.fmax) - x(innerChild.fmin))
                      .on("click", d => {
                        renderTooltipDescription(tooltipDiv,renderTrackDescription(featureChild),closeToolTip);
                      })
                      .datum({fmin: innerChild.fmin, fmax: innerChild.fmax});
                  }
                });
              }
              row_count += 1;

            }
            if (row_count === MAX_ROWS && !warningRendered) {
              // *** DANGER EDGE CASE ***/
              let link = getJBrowseLink(source, chr, viewStart,viewEnd);
              ++current_row;
              warningRendered = true ;
              // let isoform = track.append("g").attr("class", "isoform")
              //     .attr("transform", "translate(0," + ((row_count * isoform_height) + 10) + ")")
              track.append('a')
                .attr('class', 'transcriptLabel')
                .attr('xlink:show', 'new')
                .append('text')
                .attr('x', 10)
                .attr('y', 10)
                .attr("transform", "translate(0," + ((row_count * ISOFORM_HEIGHT) + 20 +heightBuffer ) + ")")
                .attr('fill', 'red')
                .attr('opacity', 1)
                .attr('height', ISOFORM_TITLE_HEIGHT)
                .html(link);
            }
          }
        }}
        );
      }
    }


    if (row_count === 0) {
      track.append('text')
        .attr('x', 30)
        .attr('y', ISOFORM_TITLE_HEIGHT + 10)
        .attr('fill', 'orange')
        .attr('opacity', 0.6)
        .text('Overview of non-coding genome features unavailable at this time.');
    }
    // we return the appropriate height function
    return (row_count * ISOFORM_HEIGHT) + heightBuffer + VARIANT_TRACK_HEIGHT;
  }

  filterVariantData(variantData, variantFilter) {
    if(variantFilter.length===0) return variantData ;
    try {
      return variantData.filter(v => {
        let returnVal = false;
        try {
          if(variantFilter.indexOf(v.name) >= 0  ||
            (v.allele_symbols && v.allele_symbols.values &&  variantFilter.indexOf(v.allele_symbols.values[0].replace(/"/g, "")) >= 0) ||
            (v.symbol && v.symbol.values &&  variantFilter.indexOf(v.symbol.values[0].replace(/"/g, "")) >= 0) ||
            (v.symbol_text && v.symbol_text.values &&  variantFilter.indexOf(v.symbol_text.values[0].replace(/"/g, "")) >= 0)
          )
            {returnVal = true}
          let ids=v.allele_ids.values[0].replace(/"|\[|\]| /g, "").split(',');
          ids.forEach(function(id){
          if(variantFilter.indexOf(id) >= 0)
            {returnVal = true}
          })
        } catch (e) {
          console.error('error processing filter with so returning anyway',variantFilter,v,e)
          returnVal = true;
        }
        return returnVal;
      });
    } catch (e) {
      console.warn('problem filtering variant data',variantData,variantFilter,e);
    }
  }

  renderTooltipDescription(tooltipDiv, descriptionHtml,closeFunction) {
    tooltipDiv.transition()
      .duration(200)
      .style("width", 'auto')
      .style("height", 'auto')
      .style("opacity", 1)
      .style('visibility', 'visible');

    tooltipDiv.html(descriptionHtml)
     .style("left", (event.pageX+10) + "px")
      .style("top", (event.pageY +10) + "px")
      .append('button')
      .attr("type","button")
      .text('Close')
      .on('click', () => closeFunction());

    tooltipDiv.append('button')
      .attr("type", 'button')
      .html('&times;')
      .attr('class', "tooltipDivX")
      .on('click' , () => closeFunction());

  }

  async populateTrack(track) {
    await Promise.all([this.getTrackData(track), this.getVariantData(track)]);
  }

  /* Method for isoformTrack service call */
  async getTrackData(track) {
    let externalLocationString = track["chromosome"] + ':' + track["start"] + '..' + track["end"];
    const isoformUrl = track["isoform_url"];
    const dataUrl = isoformUrl[0] + encodeURI(track["genome"]) + isoformUrl[1] + encodeURI(externalLocationString) + isoformUrl[2];
    this.trackData= await apolloService.fetchDataFromUrl(dataUrl);
  }

  /* Method for isoformTrack service call */
  async getVariantData(track) {
 /*   const externalLocationString = track["chromosome"] + ':' + track["start"] + '..' + track["end"];
    const variantUrl = track["variant_url"];
    const dataUrl = variantUrl[0] + encodeURI(track["genome"]) + variantUrl[1] + encodeURI(externalLocationString) + variantUrl[2];

    this.variantData = await apolloService.fetchDataFromUrl(dataUrl);*/
 //
    // this.variantData=JSON.parse('[{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RC, Actn-RA, Actn-RF, Actn-RI, Actn-RH, Actn-RB, Actn-RG, Actn-RD, Actn-RJ\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"A"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<4>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"splice_acceptor_variant\\""]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>4<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2025701T>A\\""]},"description":"SNV T > A","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"point_mutation\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0070345, FBtr0070344, FBtr0310657, FBtr0333801, FBtr0310659, FBtr0070343, FBtr0310658, FBtr0303048, FBtr0333802\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0070345, FB:FBtr0070344, FB:FBtr0310657, FB:FBtr0333801, FB:FBtr0310659, FB:FBtr0070343, FB:FBtr0310658, FB:FBtr0303048, FB:FBtr0333802\\"]"]},"type":"SNV","fmax":2025701,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["\\"HIGH\\""]},"reference_allele":"T","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant\\"]"]},"name":"NC_004354.4:g.2025701T>A","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0000278\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"HIGH, HIGH, HIGH, HIGH, HIGH, HIGH, HIGH, HIGH, HIGH\\"]"]},"fmin":2025700,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn\\""]},"seqId":"X","uniqueID":"NC_004354.4:g.2025701T>A","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBgn0000667\\""]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RD, Actn-RH, Actn-RF, Actn-RG, Actn-RJ, Actn-RI, Actn-RA, Actn-RB, Actn-RC\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"T"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<3>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"splice_region_variant|synonymous_variant\\""]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>3<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2029841C>T\\""]},"description":"SNV C > T","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"point_mutation\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0303048, FBtr0310659, FBtr0310657, FBtr0310658, FBtr0333802, FBtr0333801, FBtr0070344, FBtr0070343, FBtr0070345\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0303048, FB:FBtr0310659, FB:FBtr0310657, FB:FBtr0310658, FB:FBtr0333802, FB:FBtr0333801, FB:FBtr0070344, FB:FBtr0070343, FB:FBtr0070345\\"]"]},"type":"SNV","fmax":2029841,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["\\"LOW\\""]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"splice_region_variant|synonymous_variant, synonymous_variant, intron_variant, synonymous_variant, synonymous_variant, splice_region_variant|synonymous_variant, intron_variant, splice_region_variant|synonymous_variant, synonymous_variant\\"]"]},"name":"NC_004354.4:g.2029841C>T","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0000277\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"LOW, LOW, MODIFIER, LOW, LOW, LOW, MODIFIER, LOW, LOW\\"]"]},"fmin":2029840,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn\\""]},"seqId":"X","uniqueID":"NC_004354.4:g.2029841C>T","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBgn0000667\\""]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RG, Actn-RC, Actn-RI, Actn-RH, Actn-RF, Actn-RD, Actn-RB, Actn-RJ, Actn-RA\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"A"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<2>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"missense_variant\\""]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>2<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2029875G>A\\""]},"description":"SNV G > A","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"point_mutation\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0310658, FBtr0070345, FBtr0333801, FBtr0310659, FBtr0310657, FBtr0303048, FBtr0070343, FBtr0333802, FBtr0070344\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0310658, FB:FBtr0070345, FB:FBtr0333801, FB:FBtr0310659, FB:FBtr0310657, FB:FBtr0303048, FB:FBtr0070343, FB:FBtr0333802, FB:FBtr0070344\\"]"]},"type":"SNV","fmax":2029875,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["\\"MODERATE\\""]},"reference_allele":"G","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"missense_variant, missense_variant, missense_variant, missense_variant, intron_variant, missense_variant, missense_variant, missense_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2029875G>A","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0000276\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODERATE, MODERATE, MODERATE, MODERATE, MODIFIER, MODERATE, MODERATE, MODERATE, MODIFIER\\"]"]},"fmin":2029874,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn\\""]},"seqId":"X","uniqueID":"NC_004354.4:g.2029875G>A","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBgn0000667\\""]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RF, Actn-RG, Actn-RI, Actn-RB, Actn-RC, Actn-RA, Actn-RD, Actn-RH, Actn-RJ\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"T"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<1>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"missense_variant\\""]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>1<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2030718C>T\\""]},"description":"SNV C > T","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"point_mutation\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0310657, FBtr0310658, FBtr0333801, FBtr0070343, FBtr0070345, FBtr0070344, FBtr0303048, FBtr0310659, FBtr0333802\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0310657, FB:FBtr0310658, FB:FBtr0333801, FB:FBtr0070343, FB:FBtr0070345, FB:FBtr0070344, FB:FBtr0303048, FB:FBtr0310659, FB:FBtr0333802\\"]"]},"type":"SNV","fmax":2030718,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["\\"MODERATE\\""]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"missense_variant, missense_variant, missense_variant, missense_variant, missense_variant, missense_variant, missense_variant, missense_variant, missense_variant\\"]"]},"name":"NC_004354.4:g.2030718C>T","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0000275\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODERATE, MODERATE, MODERATE, MODERATE, MODERATE, MODERATE, MODERATE, MODERATE, MODERATE\\"]"]},"fmin":2030717,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn\\""]},"seqId":"X","uniqueID":"NC_004354.4:g.2030718C>T","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBgn0000667\\""]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RG, Actn-RJ, Actn-RI, Actn-RH, Actn-RF, Actn-RA, Actn-RB, Actn-RC, Actn-RD\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<d08251>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"intron_variant\\""]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>d08251<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2032120_2032121ins\\""]},"description":"insertion C > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0310658, FBtr0333802, FBtr0333801, FBtr0310659, FBtr0310657, FBtr0070344, FBtr0070343, FBtr0070345, FBtr0303048\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0310658, FB:FBtr0333802, FB:FBtr0333801, FB:FBtr0310659, FB:FBtr0310657, FB:FBtr0070344, FB:FBtr0070343, FB:FBtr0070345, FB:FBtr0303048\\"]"]},"type":"insertion","fmax":2032120,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["\\"MODIFIER\\""]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2032120_2032121ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0188256\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2032119,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn\\""]},"seqId":"X","uniqueID":"NC_004354.4:g.2032120_2032121ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBgn0000667\\""]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RJ, Actn-RD, Actn-RC, Actn-RG, Actn-RA, Actn-RF, Actn-RH, Actn-RI, Actn-RB\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<NP0424>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"intron_variant\\""]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>NP0424<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2032836_2032837ins\\""]},"description":"insertion T > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0333802, FBtr0303048, FBtr0070345, FBtr0310658, FBtr0070344, FBtr0310657, FBtr0310659, FBtr0333801, FBtr0070343\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0333802, FB:FBtr0303048, FB:FBtr0070345, FB:FBtr0310658, FB:FBtr0070344, FB:FBtr0310657, FB:FBtr0310659, FB:FBtr0333801, FB:FBtr0070343\\"]"]},"type":"insertion","fmax":2032836,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["\\"MODIFIER\\""]},"reference_allele":"T","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2032836_2032837ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0223267\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2032835,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn\\""]},"seqId":"X","uniqueID":"NC_004354.4:g.2032836_2032837ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBgn0000667\\""]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RA, Actn-RB, Actn-RJ, Actn-RC, Actn-RH, Actn-RD, Actn-RI, Actn-RG, Actn-RF\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<EY20057>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"intron_variant\\""]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>EY20057<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2032850_2032851ins\\""]},"description":"insertion T > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0070344, FBtr0070343, FBtr0333802, FBtr0070345, FBtr0310659, FBtr0303048, FBtr0333801, FBtr0310658, FBtr0310657\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0070344, FB:FBtr0070343, FB:FBtr0333802, FB:FBtr0070345, FB:FBtr0310659, FB:FBtr0303048, FB:FBtr0333801, FB:FBtr0310658, FB:FBtr0310657\\"]"]},"type":"insertion","fmax":2032850,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["\\"MODIFIER\\""]},"reference_allele":"T","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2032850_2032851ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0192543\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2032849,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn\\""]},"seqId":"X","uniqueID":"NC_004354.4:g.2032850_2032851ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBgn0000667\\""]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RC, Actn-RD, Actn-RH, Actn-RJ, Actn-RI, Actn-RA, Actn-RG, Actn-RF, Actn-RB\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<CC01961>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"intron_variant\\""]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>CC01961<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2033299_2033300ins\\""]},"description":"insertion C > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0070345, FBtr0303048, FBtr0310659, FBtr0333802, FBtr0333801, FBtr0070344, FBtr0310658, FBtr0310657, FBtr0070343\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0070345, FB:FBtr0303048, FB:FBtr0310659, FB:FBtr0333802, FB:FBtr0333801, FB:FBtr0070344, FB:FBtr0310658, FB:FBtr0310657, FB:FBtr0070343\\"]"]},"type":"insertion","fmax":2033299,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["\\"MODIFIER\\""]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2033299_2033300ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0211606\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2033298,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn\\""]},"seqId":"X","uniqueID":"NC_004354.4:g.2033299_2033300ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBgn0000667\\""]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RB, Actn-RF, Actn-RH, Actn-RA, Actn-RC\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<EY14992>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"intron_variant\\""]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>EY14992<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2036485_2036486ins\\""]},"description":"insertion C > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0070343, FBtr0310657, FBtr0310659, FBtr0070344, FBtr0070345\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0070343, FB:FBtr0310657, FB:FBtr0310659, FB:FBtr0070344, FB:FBtr0070345\\"]"]},"type":"insertion","fmax":2036485,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["\\"MODIFIER\\""]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, intron_variant, intron_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2036485_2036486ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0162829\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2036484,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn\\""]},"seqId":"X","uniqueID":"NC_004354.4:g.2036485_2036486ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBgn0000667\\""]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RC, usp-RB, usp-RA, Actn-RA, Actn-RF, Actn-RB\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"T"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"usp<3>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"missense_variant, intron_variant\\"]"]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"usp<sup>3<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2040435C>T\\""]},"description":"SNV C > T","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"point_mutation\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0070345, FBtr0333803, FBtr0070346, FBtr0070344, FBtr0310657, FBtr0070343\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0070345, FB:FBtr0333803, FB:FBtr0070346, FB:FBtr0070344, FB:FBtr0310657, FB:FBtr0070343\\"]"]},"type":"SNV","fmax":2040435,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODERATE, MODIFIER\\"]"]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, missense_variant, missense_variant, intron_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2040435C>T","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0017652\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODERATE, MODERATE, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2040434,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["[\\"usp, Actn\\"]"]},"seqId":"X","uniqueID":"NC_004354.4:g.2040435C>T","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBgn0003964, FB:FBgn0000667\\"]"]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RF, Actn-RB, Actn-RA, usp-RB, Actn-RC, usp-RA\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"A"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"usp<4>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, missense_variant\\"]"]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"usp<sup>4<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2040526G>A\\""]},"description":"SNV G > A","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"point_mutation\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0310657, FBtr0070343, FBtr0070344, FBtr0333803, FBtr0070345, FBtr0070346\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0310657, FB:FBtr0070343, FB:FBtr0070344, FB:FBtr0333803, FB:FBtr0070345, FB:FBtr0070346\\"]"]},"type":"SNV","fmax":2040526,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODERATE\\"]"]},"reference_allele":"G","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, intron_variant, intron_variant, missense_variant, intron_variant, missense_variant\\"]"]},"name":"NC_004354.4:g.2040526G>A","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0017653\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODERATE, MODIFIER, MODERATE\\"]"]},"fmin":2040525,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["[\\"Actn, usp\\"]"]},"seqId":"X","uniqueID":"NC_004354.4:g.2040526G>A","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBgn0000667, FB:FBgn0003964\\"]"]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"CG4313-RE, Actn-RA, usp-RA, Actn-RF, CG4313-RC, Actn-RC, usp-RB, Actn-RB, CG4325-RA, CG4325-RB\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"T"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["[\\"CG4325<Δ148>, usp<Δ148>, Actn<Δ148>\\"]"]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"splice_acceptor_variant|splice_donor_variant|5_prime_UTR_variant|intron_variant, splice_donor_variant|5_prime_UTR_variant|intron_variant, splice_acceptor_variant|coding_sequence_variant|3_prime_UTR_variant|intron_variant, splice_acceptor_variant|splice_donor_variant|5_prime_UTR_variant|intron_variant\\"]"]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["[\\"CG4325<sup>Δ148<\u002fsup>, usp<sup>Δ148<\u002fsup>, Actn<sup>Δ148<\u002fsup>\\"]"]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2041152_2043557del\\""]},"description":"deletion TACATAATCTTGAGCCGATGGAGCAGCGCACTTTATTCGCTCGCCTCCAAACAATTGCGCTTTTTACCAACAAACAAAGAATGCCAGACTTTCTGACTAATGAATAAATACCTTTTTTCGCGTCGACATTTTTTCTCAACAAAGACAATCTCACCACAGCGACGCAACTCACCAACGTAGGGATGGACTGTGACACAGGTTGCGTCGTCACGAGTCACAGTCACGACTGTTAAACACTGTATAAAATTAACAACGGCGATGGTATTACCTTAAGTCATATGGTATATAACGCATCTATAAAATTACATACTCCTCTTTTTAATTAATGCACGACATAAGTACATATATCGGTCTCCCAATTGAAGCACGGATTCGTGACTGGGCGCAATCGCATCTCTAATTCACCACAAAGTGGACAGGGCTGTTTTCCCACTCACAGAAACAGTTTTAAGTGGGCGTTAATGACCCAATTAAAGCGCTAATGCCCATCGCACCTGCCGCAAAAATAAGTGTTTTTACTTTGATAACCAATGCGCAATCAATCAATTAATTAATTTAGTCGAAAACCAGAAAACGGGAGTAGCGACAGCCCTGGCGGCGCCATTGCAAAACTCACCGCACCTACGGCGCATGCAACCCTGAGTCAGTCTGGCTCCCCTCCTCACCGCCTTGCAAACCACACAGTGCACAAATAATTTAGCGCCGCTGCAATTATGCAGAATAGAAATGCAAAATGGAGACGTGAATGTGCGCCAATTTCACCGCTGCCGGCGGCAACCTCGGCCTCAAATCGCAAACGCCGTCGCCGAGAATCGAGCGGTTAGGCTGCTGAACCGTGAATCCCAAGACCAAACGGAACCAGAATTGGGCGAAATGCAAATGGAAGTGCAACTTACTTGCAGCCAGTGGCTTTTGATGCGCCGCAAGGTGACGGTTGTTTATTTACTTTTTTCCTTGGCTATCAGTTATCAGTGCTCGCGAGCACACACACACACAGGCACGTCACTGACACGACAACACCACACGACGCTGATTTAATTTGTTGCAATCTCTATTGTAATTGTAGTAATTGAGTCCATCCCATCATCACAAAGAGACGCGACGCGGTAATTGGCATTCGCAAGAAGAAGCATTTCGCGAAACAACAGCTGACAGCGTGGTGAGAAAGCGATTGCGGGGGGCGAAGAACTGGTTTGTCTGTGGTGAGTATACTGTCGCGGTGAGTTGCCTTGGTTCGGTAAAAAACAATGGCACATTATAGGCTGTTTCCACTTCGCTTAATGGTCAGAAAATCTGAAAATTAATCCGTCATGGATATTTATGTATTTTATATATTTATGCGATAGTTAGACCGCAGTAAATTTCTAAAAAATGAATTTCCGCGATGACCAAGAAGCAGGGATTCAGTAATTCAAGAGCACCCTAACATCTGCCTTAAAATTCGATACCGGTTTAGAACAAAAATGGGAGATTCAAAATTTATATAGAAAAAAATTTGCTTAACACTATCAAATTAAGAAGCTTATTTTAAAACAGTTTAAGGGAATGGAAATAGAGTTTTCACATCAAAATTGACATTCAGGACATATATTCTTAATATTTATTTGATTATTGGTATACAAAAAATACACTAATATGTGATATTTTCTATCAGTTTAATTTTCTGATATCGCAATTTGGGGCCTCAGCCCTAAACAATTTATTTCTATTTGGGTCTATTATCTTGTCAAACCCTTTAGTTGCTAACCCTGTACCTACCGCTTCCTTTATAATGAAATGTATCGAGTTCTTTTGTTTAGCTCAGCCTTATTACGTTTTGCCTGTCGGTTTCGCAAATATTCGGTTTTGATTGGTTTTCAGGCGAATAGTACGATAAGCAAATGCGACTCGTTTGTTTGTTTACGGCTTTTAATCAACATCCGAATCCGAACATTCATGTAGTTTGCTGAGTTCAGCATTGAGGACAGTAAGGGCTCCGATCCGCTGGTTAAGATATTCGATCTCTTCTCGGTACACGCCCGTCTCGTAAAGTAGATTCTCGTACTCCCTCATAATTCCAATATAATCGTCACTGCTGCTGTTGTCGTTACTGTTGTTGTTGTTGCTGCTGCAGCTGCTGCTGCTGCTGCTGTGACCTTGGCTCCGATTATGGCCGCCCCAACTGCCACCCTGAGCCGATGCACTTTCCGGAAACTCCTCAAAGTCCAGATAAAGCTGAAAGTAGGCGGCATCCTGGCTGCGGCAGATAGGGCAAGTCCTTGATCTGCAAAGCAGACGGAATCCGCGTATAAGACAAAACGTTTGAGCTCGGCGATAAGATTTGGGGCACTGCCACTGATTTAAATCACTTTTGTATCATTTTCATTTCTGATTGGTGCATAAATTAGAATATTATATCAGTGGCACA > T","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"deletion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0340109, FBtr0070344, FBtr0070346, FBtr0310657, FBtr0340107, FBtr0070345, FBtr0333803, FBtr0070343, FBtr0070342, FBtr0310443\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0340109, FB:FBtr0070344, FB:FBtr0070346, FB:FBtr0310657, FB:FBtr0340107, FB:FBtr0070345, FB:FBtr0333803, FB:FBtr0070343, FB:FBtr0070342, FB:FBtr0310443\\"]"]},"type":"deletion","fmax":2043557,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["[\\"HIGH, HIGH, HIGH, HIGH\\"]"]},"reference_allele":"TACATAATCTTGAGCCGATGGAGCAGCGCACTTTATTCGCTCGCCTCCAAACAATTGCGCTTTTTACCAACAAACAAAGAATGCCAGACTTTCTGACTAATGAATAAATACCTTTTTTCGCGTCGACATTTTTTCTCAACAAAGACAATCTCACCACAGCGACGCAACTCACCAACGTAGGGATGGACTGTGACACAGGTTGCGTCGTCACGAGTCACAGTCACGACTGTTAAACACTGTATAAAATTAACAACGGCGATGGTATTACCTTAAGTCATATGGTATATAACGCATCTATAAAATTACATACTCCTCTTTTTAATTAATGCACGACATAAGTACATATATCGGTCTCCCAATTGAAGCACGGATTCGTGACTGGGCGCAATCGCATCTCTAATTCACCACAAAGTGGACAGGGCTGTTTTCCCACTCACAGAAACAGTTTTAAGTGGGCGTTAATGACCCAATTAAAGCGCTAATGCCCATCGCACCTGCCGCAAAAATAAGTGTTTTTACTTTGATAACCAATGCGCAATCAATCAATTAATTAATTTAGTCGAAAACCAGAAAACGGGAGTAGCGACAGCCCTGGCGGCGCCATTGCAAAACTCACCGCACCTACGGCGCATGCAACCCTGAGTCAGTCTGGCTCCCCTCCTCACCGCCTTGCAAACCACACAGTGCACAAATAATTTAGCGCCGCTGCAATTATGCAGAATAGAAATGCAAAATGGAGACGTGAATGTGCGCCAATTTCACCGCTGCCGGCGGCAACCTCGGCCTCAAATCGCAAACGCCGTCGCCGAGAATCGAGCGGTTAGGCTGCTGAACCGTGAATCCCAAGACCAAACGGAACCAGAATTGGGCGAAATGCAAATGGAAGTGCAACTTACTTGCAGCCAGTGGCTTTTGATGCGCCGCAAGGTGACGGTTGTTTATTTACTTTTTTCCTTGGCTATCAGTTATCAGTGCTCGCGAGCACACACACACACAGGCACGTCACTGACACGACAACACCACACGACGCTGATTTAATTTGTTGCAATCTCTATTGTAATTGTAGTAATTGAGTCCATCCCATCATCACAAAGAGACGCGACGCGGTAATTGGCATTCGCAAGAAGAAGCATTTCGCGAAACAACAGCTGACAGCGTGGTGAGAAAGCGATTGCGGGGGGCGAAGAACTGGTTTGTCTGTGGTGAGTATACTGTCGCGGTGAGTTGCCTTGGTTCGGTAAAAAACAATGGCACATTATAGGCTGTTTCCACTTCGCTTAATGGTCAGAAAATCTGAAAATTAATCCGTCATGGATATTTATGTATTTTATATATTTATGCGATAGTTAGACCGCAGTAAATTTCTAAAAAATGAATTTCCGCGATGACCAAGAAGCAGGGATTCAGTAATTCAAGAGCACCCTAACATCTGCCTTAAAATTCGATACCGGTTTAGAACAAAAATGGGAGATTCAAAATTTATATAGAAAAAAATTTGCTTAACACTATCAAATTAAGAAGCTTATTTTAAAACAGTTTAAGGGAATGGAAATAGAGTTTTCACATCAAAATTGACATTCAGGACATATATTCTTAATATTTATTTGATTATTGGTATACAAAAAATACACTAATATGTGATATTTTCTATCAGTTTAATTTTCTGATATCGCAATTTGGGGCCTCAGCCCTAAACAATTTATTTCTATTTGGGTCTATTATCTTGTCAAACCCTTTAGTTGCTAACCCTGTACCTACCGCTTCCTTTATAATGAAATGTATCGAGTTCTTTTGTTTAGCTCAGCCTTATTACGTTTTGCCTGTCGGTTTCGCAAATATTCGGTTTTGATTGGTTTTCAGGCGAATAGTACGATAAGCAAATGCGACTCGTTTGTTTGTTTACGGCTTTTAATCAACATCCGAATCCGAACATTCATGTAGTTTGCTGAGTTCAGCATTGAGGACAGTAAGGGCTCCGATCCGCTGGTTAAGATATTCGATCTCTTCTCGGTACACGCCCGTCTCGTAAAGTAGATTCTCGTACTCCCTCATAATTCCAATATAATCGTCACTGCTGCTGTTGTCGTTACTGTTGTTGTTGTTGCTGCTGCAGCTGCTGCTGCTGCTGCTGTGACCTTGGCTCCGATTATGGCCGCCCCAACTGCCACCCTGAGCCGATGCACTTTCCGGAAACTCCTCAAAGTCCAGATAAAGCTGAAAGTAGGCGGCATCCTGGCTGCGGCAGATAGGGCAAGTCCTTGATCTGCAAAGCAGACGGAATCCGCGTATAAGACAAAACGTTTGAGCTCGGCGATAAGATTTGGGGCACTGCCACTGATTTAAATCACTTTTGTATCATTTTCATTTCTGATTGGTGCATAAATTAGAATATTATATCAGTGGCACA","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"splice_acceptor_variant|splice_donor_variant|5_prime_UTR_variant|intron_variant, splice_donor_variant|5_prime_UTR_variant|intron_variant, 5_prime_UTR_variant, splice_donor_variant|5_prime_UTR_variant|intron_variant, splice_acceptor_variant|splice_donor_variant|5_prime_UTR_variant|intron_variant, splice_donor_variant|5_prime_UTR_variant|intron_variant, splice_acceptor_variant|splice_donor_variant|5_prime_UTR_variant|intron_variant, splice_donor_variant|5_prime_UTR_variant|intron_variant, splice_acceptor_variant|coding_sequence_variant|3_prime_UTR_variant|intron_variant, splice_acceptor_variant|coding_sequence_variant|3_prime_UTR_variant|intron_variant\\"]"]},"name":"NC_004354.4:g.2041152_2043557del","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBal0264306, FB:FBal0212727, FB:FBal0212726\\"]"]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"HIGH, HIGH, MODIFIER, HIGH, HIGH, HIGH, HIGH, HIGH, HIGH, HIGH\\"]"]},"fmin":2041150,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["[\\"usp, Actn, CG4325, CG4313\\"]"]},"seqId":"X","uniqueID":"NC_004354.4:g.2041152_2043557del","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBgn0003964, FB:FBgn0000667, FB:FBgn0026878, FB:FBgn0025632\\"]"]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RB, Actn-RA, usp-RB, Actn-RF, Actn-RC\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<G509>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"5_prime_UTR_variant, intron_variant\\"]"]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>G509<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2041338_2041339ins\\""]},"description":"insertion C > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0070343, FBtr0070344, FBtr0333803, FBtr0310657, FBtr0070345\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0070343, FB:FBtr0070344, FB:FBtr0333803, FB:FBtr0310657, FB:FBtr0070345\\"]"]},"type":"insertion","fmax":2041338,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER\\"]"]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, intron_variant, 5_prime_UTR_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2041338_2041339ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0247853\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2041337,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["[\\"usp, Actn\\"]"]},"seqId":"X","uniqueID":"NC_004354.4:g.2041338_2041339ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBgn0003964, FB:FBgn0000667\\"]"]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RA, usp-RB, Actn-RC, Actn-RB, Actn-RF\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<NP7268>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"5_prime_UTR_variant, intron_variant\\"]"]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>NP7268<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2041339_2041340ins\\""]},"description":"insertion T > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0070344, FBtr0333803, FBtr0070345, FBtr0070343, FBtr0310657\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0070344, FB:FBtr0333803, FB:FBtr0070345, FB:FBtr0070343, FB:FBtr0310657\\"]"]},"type":"insertion","fmax":2041339,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER\\"]"]},"reference_allele":"T","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, 5_prime_UTR_variant, intron_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2041339_2041340ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0223268\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2041338,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["[\\"usp, Actn\\"]"]},"seqId":"X","uniqueID":"NC_004354.4:g.2041339_2041340ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBgn0003964, FB:FBgn0000667\\"]"]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"Actn-RF, usp-RB, Actn-RA, Actn-RB, Actn-RC\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<EY02029>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, intron_variant\\"]"]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>EY02029<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2041795_2041796ins\\""]},"description":"insertion C > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0310657, FBtr0333803, FBtr0070344, FBtr0070343, FBtr0070345\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0310657, FB:FBtr0333803, FB:FBtr0070344, FB:FBtr0070343, FB:FBtr0070345\\"]"]},"type":"insertion","fmax":2041795,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER\\"]"]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, intron_variant, intron_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2041795_2041796ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0162830\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2041794,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["[\\"Actn, usp\\"]"]},"seqId":"X","uniqueID":"NC_004354.4:g.2041795_2041796ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBgn0000667, FB:FBgn0003964\\"]"]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"CG4313-RC, CG4313-RE, Actn-RB, usp-RB, Actn-RF, Actn-RC, Actn-RA\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["\\"Actn<EP1193>\\""]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"intron_variant, 5_prime_UTR_variant, intron_variant\\"]"]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>EP1193<\u002fsup>\\""]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2041937_2041938ins\\""]},"description":"insertion C > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0340107, FBtr0340109, FBtr0070343, FBtr0333803, FBtr0310657, FBtr0070345, FBtr0070344\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0340107, FB:FBtr0340109, FB:FBtr0070343, FB:FBtr0333803, FB:FBtr0310657, FB:FBtr0070345, FB:FBtr0070344\\"]"]},"type":"insertion","fmax":2041937,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER\\"]"]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"5_prime_UTR_variant, 5_prime_UTR_variant, intron_variant, intron_variant, intron_variant, intron_variant, intron_variant\\"]"]},"name":"NC_004354.4:g.2041937_2041938ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0131808\\""]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2041936,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["[\\"usp, CG4313, Actn\\"]"]},"seqId":"X","uniqueID":"NC_004354.4:g.2041937_2041938ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBgn0003964, FB:FBgn0025632, FB:FBgn0000667\\"]"]}},{"allele_of_transcript_gff3_names":{"meta":{"number":[-1],"description":["The transcript gff3 Names that the Allele is located on"],"id":["allele_of_transcript_gff3_names"],"type":["UNBOUNDED"]},"values":["[\\"CG4313-RE, Actn-RF, Actn-RC, CG4313-RC, usp-RB, Actn-RA, Actn-RB\\"]"]},"alternative_alleles":{"meta":{"description":"VCF ALT field, list of alternate non-reference alleles called on at least one of the samples"},"values":"ALT_MISSING"},"allele_symbols_text":{"meta":{"number":[-1],"description":["Another human readable representation of the allele"],"id":["allele_symbols_text"],"type":["UNBOUNDED"]},"values":["[\\"Actn<5-HA-1011>, Actn<5-HA-1774>, Actn<KG06473>\\"]"]},"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"5_prime_UTR_variant, 5_prime_UTR_variant, 5_prime_UTR_variant\\"]"]},"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["[\\"Actn<sup>5-HA-1011<\u002fsup>, Actn<sup>5-HA-1774<\u002fsup>, Actn<sup>KG06473<\u002fsup>\\"]"]},"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2042231_2042232ins\\""]},"description":"insertion C > ALT_MISSING","soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"insertion\\""]},"allele_of_transcript_gff3_ids":{"meta":{"number":[-1],"description":["The transcript gff3ID that the Allele is located on"],"id":["allele_of_transcript_gff3_ids"],"type":["UNBOUNDED"]},"values":["[\\"FBtr0340109, FBtr0310657, FBtr0070345, FBtr0340107, FBtr0333803, FBtr0070344, FBtr0070343\\"]"]},"allele_of_transcript_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_transcript_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBtr0340109, FB:FBtr0310657, FB:FBtr0070345, FB:FBtr0340107, FB:FBtr0333803, FB:FBtr0070344, FB:FBtr0070343\\"]"]},"type":"insertion","fmax":2042231,"geneImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Gene"],"id":["geneImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER\\"]"]},"reference_allele":"C","transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"5_prime_UTR_variant, 5_prime_UTR_variant, 5_prime_UTR_variant, 5_prime_UTR_variant, 5_prime_UTR_variant, 5_prime_UTR_variant, 5_prime_UTR_variant\\"]"]},"name":"NC_004354.4:g.2042231_2042232ins","allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBal0223266, FB:FBal0223269, FB:FBal0137674\\"]"]},"transcriptImpact":{"meta":{"number":[-1],"description":["Variant impact scale for Transcript"],"id":["transcriptImpact"],"type":["UNBOUNDED"]},"values":["[\\"MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER, MODIFIER\\"]"]},"fmin":2042230,"allele_of_gene_symbols":{"meta":{"number":[-1],"description":["The gene names that the Allele is located on"],"id":["allele_of_gene_symbols"],"type":["UNBOUNDED"]},"values":["[\\"usp, CG4313, Actn\\"]"]},"seqId":"X","uniqueID":"NC_004354.4:g.2042231_2042232ins","allele_of_gene_ids":{"meta":{"number":[-1],"description":["The gene ids that the Allele is located on"],"id":["allele_of_gene_ids"],"type":["UNBOUNDED"]},"values":["[\\"FB:FBgn0003964, FB:FBgn0025632, FB:FBgn0000667\\"]"]}}]');
 /* this.variantData=JSON.parse('[{\n' +
      '"geneLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Gene"],"id":["geneLevelConsequence"],"type":["UNBOUNDED"]},"values":["\\"splice_acceptor_variant\\""]},\n' +
      '\n' +
      '"allele_symbols":{"meta":{"number":[-1],"description":["The human readable name of the Allele"],"id":["allele_symbols"],"type":["UNBOUNDED"]},"values":["\\"Actn<sup>4<\u002fsup>\\""]},\n' +
      '\n' +
      '"hgvs_nomenclature":{"meta":{"number":[1],"description":["the HGVS name of the allele"],"id":["hgvs_nomenclature"],"type":["INTEGER"]},"values":["\\"NC_004354.4:g.2025701T>A\\""]},\n' +
      '\n' +
      '"description":"SNV T > A",' +
      '"soTerm":{"meta":{"number":[1],"description":["The Sequence Ontology term for the variant"],"id":["soTerm"],"type":["INTEGER"]},"values":["\\"point_mutation\\""]},\n' +
      '\n' +
      '"type":"SNV",\n' +
      '\n' +
      '"fmax":55115788,\n' +
      '\n' +
      '"reference_allele":"T",\n' +
      '\n' +
      '"transcriptLevelConsequence":{"meta":{"number":[-1],"description":["VEP consequence of the variant on the Transcript"],"id":["transcriptLevelConsequence"],"type":["UNBOUNDED"]},"values":["[\\"splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant, splice_acceptor_variant\\"]"]},\n' +
      '\n' +
      '"name":"NC_004354.4:g.2025701T>A",\n' +
      '\n' +
      '"allele_ids":{"meta":{"number":[-1],"description":["The ID of the Allele"],"id":["allele_ids"],"type":["UNBOUNDED"]},"values":["\\"FB:FBal0000278\\""]},\n' +
      '\n' +
      '"fmin":55115765,\n' +
      '\n' +
      '"seqId":"19",\n' +
      '\n' +
      '"uniqueID":"NC_004354.4:g.2025701T>A"'+
      '}]') ;*/
    const guide=JSON.parse(track["guide"]);
    this.variantData=JSON.parse(track["otherGuides"])
  /*  this.variantData=JSON.parse('[{\n' +
        '"targetSequence":"'+ guide["targetSequence"] +'",' +
        '"targetLocus":"'+ guide["targetLocus"] +'",' +
        '"description":"'+ guide["description"] +'",' +
        '"type":"'+ "gRNA" +'", ' +
        '"fmax":'+ guide["stop"] +',' +
        '"pam":"'+ guide["pam"] +'",\n' +
        '"strand":"'+ guide["strand"] +'",\n' +
        '"assembly":"'+ guide["assembly"] +'",\n' +
        '"name":"'+ guide["guide"] +'",\n' +
        '"guide_ids":{"meta":{"number":[-1],"description":["The ID of the Guide"],"id":["guide_ids"],"type":["UNBOUNDED"]},"values":["\\"AAVS1_site_02\\""]},\n' +
        '"fmin":'+ guide["start"] +',\n' +
        '"seqId":"'+ guide["chr"] +'",\n' +
        '"scge_id":"'+ guide["guide_id"] +'"'+
        '},' +
        '{\n' +
    '"targetSequence":"'+ guide["targetSequence"] +'",' +
    '"targetLocus":"'+ guide["targetLocus"] +'",' +
    '"description":"'+ guide["description"] +'",' +
    '"type":"'+ "insertion" +'", ' +
    '"fmax":'+ guide["stop"] +',' +
    '"pam":"'+ guide["pam"] +'",\n' +
    '"strand":"'+ guide["strand"] +'",\n' +
    '"assembly":"'+ guide["assembly"] +'",\n' +
    '"name":"'+ guide["guide"] +'",\n' +
    '"guide_ids":{"meta":{"number":[-1],"description":["The ID of the Guide"],"id":["guide_ids"],"type":["UNBOUNDED"]},"values":["\\"AAVS1_site_02\\""]},\n' +
    '"fmin":'+ guide["start"] +',\n' +
    '"seqId":"'+ guide["chr"] +'",\n' +
    '"scge_id":"'+ guide["guide_id"] +'"'+
        '}]') ;
*/
  }
  //chr19:55115765..55115788
}
