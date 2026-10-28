// Rows shown per page by every paged table on a report, from the Annotation section through
// Sequence, Genomics and References. One number so the whole report pages the same way.
//
// Every pager below also passes savePages: false, which is what makes this number the size a
// table actually opens at. The pager addon otherwise saves the page and size a user picks into
// localStorage under 'tablesorter-pager' (savePages defaults to true), keyed by URL path plus
// table id, and that saved size overrides the size passed here. All gene reports share one path,
// /rgdweb/report/gene/main.html, so a single visit where someone switched one table to 20 rows
// made that table open at 20 on every gene they looked at afterwards, while the tables they had
// never touched still opened at 10 - the "some tables show 20" report. Nothing cleared the key
// either: geneReport.js carried a manageLocalStorage() written for exactly that, but it was never
// called from anywhere.
//
// With savePages off the pager neither reads nor writes that key, so a size already stored in a
// user's browser is ignored and every paged table on every report opens at REPORT_PAGE_SIZE. The
// rows-per-page select still works; the choice now lasts for that page view instead of following
// the user onto unrelated records.
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
                size: REPORT_PAGE_SIZE,
                savePages: false
            });
        // The variant grid on report/rsId/main.html. The server sends up to 1000 records per
        // request, so without a pager the whole batch rendered as one scroll. .mapDataPager
        // matches the container above the grid and the one below it; the addon takes the set
        // and keeps both in step.
        //
        // This was commented out before because it could not have worked: the table had no
        // thead, so tablesorter itself bailed out and there was no initialised table for a
        // pager to attach to. The thead is in place now.
        $('#mapDataTable')
            .tablesorter({
                theme: 'blue',
                widget: ['zebra']
            })
            .tablesorterPager({
                container: $('.mapDataPager'),
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

        $('#annotationTable2')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager2'),
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

        $('#annotationTable3')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager3'),
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

        $('#annotationTable4')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager4'),
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

        $('#annotationTable5')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager5'),
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

        $('#annotationTable6')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager6'),
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

        $('#annotationTable7')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager7'),
                size: REPORT_PAGE_SIZE,
                savePages: false
            });


        $('#annotationTable8')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager8'),
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

        $('#annotationTable9')
            .tablesorter({
                theme: 'blue',
                widgets: ['zebra']
            })
            .tablesorterPager({
                container: $('.annotationPager9'),
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
            });


        $('#nucleotideReferenceSequencesTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter']
            })
            .tablesorterPager({
                container: $('.nucleotideReferenceSequencesPager'),
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

        $('#proteinReferenceSequencesTable')
            .tablesorter({
                theme: 'dropbox',
                widgets: ['zebra', 'filter']
            })
            .tablesorterPager({
                container: $('.proteinReferenceSequencesPager'),
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
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
                size: REPORT_PAGE_SIZE,
                savePages: false
            });

    });
}