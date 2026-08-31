// Rows shown per page by every table under the report's Annotation section - both the standard
// view (associations.jsp, whose tables geneReport.js builds as annotationTable1..9) and the
// Annotation Detail View (associationsCurator.jsp). Tables in other sections keep their own sizes.
//
// tablesorter's pager remembers the size a user picks, so this is the default for someone who has
// not changed it on that table before; anyone who has keeps their choice until they change it.
var ANNOTATION_PAGE_SIZE = 10;

tableSorterReport();
function tableSorterReport() {
    $(function () {

        $('#variantSamplesTable')
            .tablesorter({
                theme: 'blue',
                widget: ['zebra']
            })
            .tablesorterPager({
                container: $('.variantSamplesPager'),
                size: 20
            });
        $('#mapDataTable')
            .tablesorter({
                theme: 'blue',
                widget: ['zebra']
            });
        //     .tablesorterPager({
        //     container: $('.mapDataPager'),
        //     size: 100
        // });

        $('#variantTranscriptsTable')
            .tablesorter({
                theme: 'blue',
                widget: ['zebra']
            })
            .tablesorterPager({
                container: $('.variantTranscriptsPager'),
                size: 3
            });

        $('#sampleDetailsTable').tablesorter({
            theme: 'blue',
            widgets: ['zebra', 'filter'],
            widgetOptions: {
                filter_external: '#sampleDetailsSearch',
                filter_columnFilters: false
            }
        })
            .tablesorterPager({
                container: $('.sampleDetailsPager'),
                size: 9999
            });

        $('#gwasDataTable').tablesorter({
            theme: 'blue',
            widgets: ['zebra', 'filter'],
            widgetOptions: {
                filter_external: '#gwasDataSearch',
                filter_columnFilters: false
            }
        })
            .tablesorterPager({
                container: $('.gwasDataPager'),
                size: 20
            });

        $('#ssIDTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            });

        $('#ClinVarTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            });

        $('#annotationTable1')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager1'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#annotationTable2')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager2'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#annotationTable3')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager3'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#annotationTable4')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager4'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#annotationTable5')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager5'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#annotationTable6')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager6'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#annotationTable7')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager7'),
                size: ANNOTATION_PAGE_SIZE
            });


        $('#annotationTable8')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager8'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#annotationTable9')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager9'),
                size: ANNOTATION_PAGE_SIZE
            });
        //annotation detail view tables

        $('#manualAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#manualAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.manualAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#importedAnnotationsClinVarTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsClinVarSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsClinVarPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#importedAnnotationsCTDTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsCTDSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsCTDPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#importedAnnotationsGWASTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsGWASSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsGWASPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#importedAnnotationsGADTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsGADSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsGADPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#importedAnnotationsMGITable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsMGISearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsMGIPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#importedAnnotationsOMIATable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsOMIASearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsOMIAPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#importedAnnotationsOMIMTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsOMIMSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsOMIMPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#geneChemicalInteractionAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#geneChemicalInteractionAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.geneChemicalInteractionAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#biologicalProcessAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#biologicalProcessAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.biologicalProcessAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#cellularComponentAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#cellularComponentAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.cellularComponentAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#molecularFunctionAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#molecularFunctionAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.molecularFunctionAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#molecularPathwayManualAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#molecularPathwayManualAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.molecularPathwayManualAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#importedAnnotationsSMPDBTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsSMPDBSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsSMPDBPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#importedAnnotationsKEGGTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsKEGGSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsKEGGPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#importedAnnotationsPIDTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsPIDSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsPIDPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#importedAnnotationsOtherTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#importedAnnotationsOtherSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.importedAnnotationsOtherPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#mammalianPhenotypeAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#mammalianPhenotypeAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.mammalianPhenotypeAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#humanPhenotypeAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#humanPhenotypeAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.humanPhenotypeAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#humanPhenotypeManualAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#humanPhenotypeManualAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.humanPhenotypeManualAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#humanPhenotypeClinVarAnnotationsTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#humanPhenotypeClinVarAnnotationsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.humanPhenotypeClinVarAnnotationsPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        
        $('#cellOntologyTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#cellOntologySearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.cellOntologyPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#mouseAnatomyTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#mouseAnatomySearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.mouseAnatomyPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#ratStrainTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#ratStrainSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.ratStrainPager'),
                size: ANNOTATION_PAGE_SIZE
            });
        $('#efoAnnotTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['filter'],
                widgetOptions: {
                    filter_external: '#ratStrainSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.efoAnnotPager'),
                size: ANNOTATION_PAGE_SIZE
            });

        $('#clinicalMeasurementTable')
            .tablesorter({
                theme: 'blue'
            });

        $('#experimentalConditionTable')
            .tablesorter({
                theme: 'blue'
            });

        $('#measurementMethodTable')
            .tablesorter({
                theme: 'blue'
            });
        $('#vertebrateTraitTable')
            .tablesorter({
                theme: 'blue'
            });

        $('#objectsReferencedInThisArticleTable')
            .tablesorter({
                theme: 'blue'
            });

        $('#pubMedReferencesTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.pubMedReferencesPager'),
                size: 10
            });


        $('#referencesCuratedTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#referencesCuratedSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.referencesCuratedPager'),
                size: 20
            });


        $('#qtlAssociationTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#qtlAssociationSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.qtlAssociationPager'),
                size: 10
            });


        $('#geneAssociationTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#geneAssociationSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.geneAssociationPager'),
                size: 20
            });

        $('#mark2AssociationTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#mark2AssociationSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.mark2AssociationPager'),
                size: 20
            });

        $('#strainSequenceVariantsTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#strainSequenceVariantsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.strainSequenceVariantsPager'),
                size: 10
            });


        $('#nucleotideReferenceSequencesTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter']
            })
            .tablesorterPager({
                container: $('.nucleotideReferenceSequencesPager'),
                size: 5
            });

        $('#proteinReferenceSequencesTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter']
            })
            .tablesorterPager({
                container: $('.proteinReferenceSequencesPager'),
                size: 5
            });

        $('#nucleotideSequencesTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#nucleotideSequencesSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.nucleotideSequencesPager'),
                size: 30
            });

        $('#proteinSequencesTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#proteinSequencesSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.proteinSequencesPager'),
                size: 30
            });


        $('#clinicalVariantsTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#clinicalVariantsSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.clinicalVariantsPager')
            });

        $('#externalDatabaseLinksTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#externalDatabaseLinksSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.externalDatabaseLinksPager'),
                size: 40
            });
        $('#strainQtlAssociationTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter'],
                widgetOptions: {
                    filter_external: '#strainQtlAssociationSearch',
                    filter_columnFilters: false
                }
            })
            .tablesorterPager({
                container: $('.strainQtlAssociationPager'),
                size: 20
            });
        //added samplemetadatatable for expression study report page
        $('#sampleMetadataTable')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra'],
                // widgets: ['zebra','filter'],
                widgetOptions: {
                    // filter_external: '#sampleDataSearch',
                    // filter_columnFilters: false,
                    resize: true  // Enables column resizing by dragging
                }
            })

            .tablesorterPager({
                container: $('.sampleMetadataPager'),
                size: 10
            });

    });
}