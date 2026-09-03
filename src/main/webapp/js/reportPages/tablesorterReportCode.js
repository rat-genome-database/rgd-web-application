// Rows shown per page by every paged table on a report, from the Annotation section through
// Sequence, Genomics and References. One number so the whole report pages the same way.
//
// tablesorter's pager remembers the size a user picks, so this is the default for someone who has
// not changed it on that table before; anyone who has keeps their choice until they change it.
var REPORT_PAGE_SIZE = 10;

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
                size: REPORT_PAGE_SIZE
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

        // #variantTranscriptsTable was the 650px layout table that wrapped the Variant
        // Transcripts section, not a data table - sorting it sorted its one row, and the pager
        // container named here, .variantTranscriptsPager, is not in any JSP. The section is a
        // list of cards now, so both are gone.

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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
            });

        $('#annotationTable2')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager2'),
                size: REPORT_PAGE_SIZE
            });

        $('#annotationTable3')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager3'),
                size: REPORT_PAGE_SIZE
            });

        $('#annotationTable4')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager4'),
                size: REPORT_PAGE_SIZE
            });

        $('#annotationTable5')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager5'),
                size: REPORT_PAGE_SIZE
            });

        $('#annotationTable6')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager6'),
                size: REPORT_PAGE_SIZE
            });

        $('#annotationTable7')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager7'),
                size: REPORT_PAGE_SIZE
            });


        $('#annotationTable8')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager8'),
                size: REPORT_PAGE_SIZE
            });

        $('#annotationTable9')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager9'),
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
            });


        $('#nucleotideReferenceSequencesTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter']
            })
            .tablesorterPager({
                container: $('.nucleotideReferenceSequencesPager'),
                size: REPORT_PAGE_SIZE
            });

        $('#proteinReferenceSequencesTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter']
            })
            .tablesorterPager({
                container: $('.proteinReferenceSequencesPager'),
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                container: $('.clinicalVariantsPager'),
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
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
                size: REPORT_PAGE_SIZE
            });

    });
}