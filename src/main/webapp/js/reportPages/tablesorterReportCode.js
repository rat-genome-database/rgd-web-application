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
                size: 20
            });

        $('#annotationTable2')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager2'),
                size: 20
            });

        $('#annotationTable3')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager3'),
                size: 20
            });

        $('#annotationTable4')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager4'),
                size: 20
            });

        $('#annotationTable5')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager5'),
                size: 20
            });

        $('#annotationTable6')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager6'),
                size: 20
            });

        $('#annotationTable7')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager7'),
                size: 20
            });


        $('#annotationTable8')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager8'),
                size: 20
            });

        $('#annotationTable9')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager9'),
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                size: 20
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
                widgetOptions: {
                    resize: true  // Enables column resizing by dragging
                }
            })

            .tablesorterPager({
                container: $('.sampleMetadataPager'),
                size: 10
            });

    });
}