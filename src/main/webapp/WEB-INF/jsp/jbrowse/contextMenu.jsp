<!DOCTYPE html>

<script type="text/javascript">

	function resize_iFrame()
	{
		var iFrame = window.parent.document.getElementById( "id_IFrame" );
		if( iFrame == null ) return;

		var contentHeight = document.body.scrollHeight;
		var operatingContentHeight = contentHeight + 60;
		if( operatingContentHeight > 480 ) operatingContentHeight = 480;
		var contentHeight_string = operatingContentHeight.toString() + "px";

		var windowHeight = window.parent.window.innerHeight;
		if( typeof( windowHeight ) != "number" ) windowHeight = window.parent.document.documentElement.clientHeight;
		if( typeof( windowHeight ) != "number" ) windowHeight = window.parent.document.body.clientHeight;
		var windowHeight_string = windowHeight.toString() + "px";

		var offsetHeight = Math.floor( ( windowHeight - operatingContentHeight ) * 0.4 );
		var offsetHeight_string = offsetHeight.toString() + "px";

		// DEBUG: (sanity check)
		// Ensure that our contentHeight, windowHeight,
		// and offsetHeight parameters are acceptable
		/*
		document.write( "<br />Content Height: " + contentHeight );
		document.write( "<br />Content Height (operating): " + operatingContentHeight );
		document.write( "<br />Content Height (string): " + contentHeight_string );
		document.write( "<br />Window Height: " + windowHeight );
		document.write( "<br />Window Height (string): " + windowHeight_string );
		document.write( "<br />Offset Height: " + offsetHeight );
		document.write( "<br />Offset Height (string): " + offsetHeight_string );
		*/

		// NOTE:
		// The following double-".parentNode." code is completely dependent on JBrowse's
		// double-div enclosure around the contentDialog iFrame. Thus, if the method in which
		// JBrowse encapsulates this iFrame changes, then we MUST accordingly change the
		// code that references the iFrame's uppermost parent "<div>" element
		iFrame.height = contentHeight_string;
		iFrame.parentNode.parentNode.style.top = offsetHeight_string;
	}

	function testEmpty( passedVariable )
	{
		if( passedVariable == null || passedVariable == "" || passedVariable == "NA" || passedVariable == "null" )
			return "NA";
		else
			return passedVariable;
	}

	function fancifyNumber( num )
	{
		if( testEmpty( num ) != "NA" )
		{
			var string = num.toString(), length = string.length,
				newString = "", i;
			
			for( i = length; i > 0; i -= 3 )
			{
				if( i < 4 ) newString = string.slice( 0, i ) + newString;
				else newString = "," + string.slice( i - 3, i ) + newString;
			}
			
			return newString;
		}
		else
		{
			return "NA";
		}
	}

	function determineTrackType( source, type )
	{
		if( source != null && type != null )
		{
			if( source.match( /^synteny/i ) != null )
				return "synteny";
			else if( source.match( /.*EST.*|.*RNAseq$/g ) != null )
				return "RNAseqFeatures";
			else if( source.match( /^dbSNP.*/ ) != null )
				return "dbSNP";
			else if( source.match( /^[eE]nsemblSNP.*/ ) != null )
				return "ensemblSNP";
			else if( source.match( /^RGD_Ontology_DOID[0-9]*/i ) != null && type.match( /^gene_ont.*/i ) != null )
				return "diseaseOntology";
			else if( source.match( /^RGD_Ontology_CHEBI[0-9]*/i ) != null && type.match( /^gene_ont.*/i ) != null )
				return "drugGeneOntology";
			else if( type.match( /^QTL$|^human_QTL$/gi ) != null )
				return "QTL";
			else if( type.match( /^(multi)?congenic|^mutant.*|^transgenic/i ) != null )
				return "congenicStrains";
			else if( type.match( /^SSLPS/i ) != null )
				return "microSatellite";
			else if( source.match( /^RGD_Ontology_DOID[0-9]*/i ) != null && type.match( /^qtl_ont.*/i ) != null )
				return "diseaseQTLontology";
			else if( source.match( /^RGD_Ontology_DOID[0-9]*/i ) != null && type.match( /^strain_ont.*/i ) != null )
				return "diseaseStrainOntology";
			else if( source == "miRBase" && type == "miRNA" )
				return "miRNA";
			else if( source.match( /^EPD_|^EPDNEW_|^MPROMDB_/i ) != null )
				return "EPDpromoter";
			else if( type.match( /^methylation/i ) != null )
				return "methylation";
			else if( source.match( /\*Hubrecht_Institute/i ) != null && type.match( /^INDEL/i ) != null )
				return "indelHubrecht";
			else if( source.match( /\*Imperial_College/i ) != null && type.match( /^INDEL/i ) != null )
				return "indelICL";
			else if( type == "PGA" )
				return "physGenStrains";
			else if( type.match( /^Misassembly/i ) != null )
				return "misassembly";
			else if( type.match( /^CNV/i ) != null )
				return "CNV";
			else if( source.match( /^NA[0-9]*$/i ) != null )
				return "1000Genomes";
			else if( source.match( /^ClinVar/i ) != null )
				return "ClinVar";
			else if( source.match( /^GenBank/i ) != null )
			{
				switch( type )
				{
					case "gene":
						return "entrezGene";
						break;
					case "CDS":
					case "exon":
					case "mRNA":
					case "pseudogene":
						return "entrezNonGeneFeature";
						break;
					default:
						return null;
						break;
				}
			}
			else
			{
				switch( type )
				{
					case "CDS":
					case "EXON":
					case "mRNA":
					case "UTR3":
					case "UTR5":
						return "transcripts";
						break;
					default:
						return null;
						break;
				}
			}
		}
		else
		{
			return null;
		}
	}

	function getDataset()
	{
		var dataset = window.parent.window.location.search.substring( 1 ).match( /^data=[a-zA-Z0-9_]*&/ );

		if( dataset != null )
		{
			dataset = dataset.toString().replace( /^data=|&$/g, "" );
			return dataset;
		}
		else
			return null;
	}

	function getMapKey( dataset )
	{
		if( dataset != null )
		{
			switch( dataset )
			{
				case "data_rgd5":
					return 70;
					break;
				case "data_rgd3_4":
					return 60;
					break;
				case "data_mm37":
					return 18;
					break;
				case "data_hg18":
					return 13;
					break;
				case "data_hg19":
					return 17;
					break;
				default:
					return null;
					break;
			}
		}
		else
			return null;
	}

	function getBoldOpenTag( boldFace )
	{
		if( boldFace == 1 ) return "<strong>";
		else return "";
	}

	function getBoldCloseTag( boldFace )
	{
		if( boldFace == 1 ) return "</strong>";
		else return "";
	}

	function writeRow( parameterName, parameterValue, boldFace, htmlLinkPrefix, htmlLinkSuffix )
	{
		if( parameterName != null && parameterValue != null )
		{
			var boldOpenTag = getBoldOpenTag( boldFace ), boldCloseTag = getBoldCloseTag( boldFace );

			if( htmlLinkPrefix != null && htmlLinkSuffix != null )
			{
				// This code generates a table row using an HTML
				// link in the "parameterValue" column--that is,
				// the second <td></td> element in the table row (<tr></tr>)
				document.write( "<tr><td>" + boldOpenTag + parameterName + boldCloseTag + "</td><td>" );
				document.write( "<a href=\"" + htmlLinkPrefix + htmlLinkSuffix + "\" target=\"_blank\">" );
				document.write( parameterValue + "</a></td></tr>" );
			}
			else
			{
				// This is the code that prints out a standard
				// text-based table row: one that contains
				// no HTML hyperlinks of any sort
				document.write( "<tr><td>" + boldOpenTag + parameterName + boldCloseTag );
				document.write( "</td><td>" + parameterValue + "</td></tr>" );
			}
		}
	}

	function writeSpannedRow( parameterValue, boldFace, htmlLinkPrefix, htmlLinkSuffix )
	{
		if( parameterValue != null )
		{
			var boldOpenTag = getBoldOpenTag( boldFace ), boldCloseTag = getBoldCloseTag( boldFace );

			if( htmlLinkPrefix != null && htmlLinkSuffix != null )
			{
				// Generates a singular hyperlinked table row
				document.write( "<tr><td colspan=\"2\">" + boldOpenTag + "<a href=\"" );
				document.write( htmlLinkPrefix + htmlLinkSuffix + "\" target=\"_blank\">" );
				document.write( parameterValue + "</a>" + boldCloseTag + "</td></tr>" );
			}
			else
			{
				// Generates a singular text(-only) table row
				document.write( "<tr><td colspan=\"2\">" + boldOpenTag + parameterValue );
				document.write( boldCloseTag + "</td></tr>" );
			}
		}
	}

	function writeLocationRow( parameterName, chromosome, startingBP, endingBP, boldFace )
	{
		if( ( parameterName != null && chromosome != null ) && ( startingBP != null && endingBP != null ) )
		{
			var boldOpenTag = getBoldOpenTag( boldFace ), boldCloseTag = getBoldCloseTag( boldFace ),
				dataset = getDataset();

			if( dataset == null )
			{
				document.write( "<tr><td>" + boldOpenTag + parameterName + boldCloseTag + "</td><td>" );
				document.write( chromosome + ": " + fancifyNumber( startingBP ) + ".." );
				document.write( fancifyNumber( endingBP ) + "</td></tr>" );
			}
			else
			{
				document.write( "<tr><td>" + boldOpenTag + parameterName + boldCloseTag + "</td>" );
				document.write( "<td><a href=\"/jbrowse/?data=" + dataset + "&loc=" + chromosome + ":" );
				document.write( startingBP + ".." + endingBP + "\" target=\"_parent\">" + chromosome + ": " );
				document.write( fancifyNumber( startingBP ) + ".." + fancifyNumber( endingBP ) + "</a></td></tr>" );
			}
		}
	}

	function writeSyntenyRow( parameterName, syntenyClass, chromosome, startingBP, endingBP, boldFace )
	{
		var boldOpenTag = getBoldOpenTag( boldFace ), boldCloseTag = getBoldCloseTag( boldFace ),
			parentURLparameters = window.parent.window.location.search.substring( 1 ).split( "&" ),
			originDataset = parentURLparameters[ 0 ].split( "=" )[ 1 ], destinationDataset,
			location = chromosome + ":" + startingBP + ".." + endingBP,
			tracks = parentURLparameters[ 2 ].split( "=" )[ 1 ],
			highlight = parentURLparameters[ 3 ].split( "=" )[ 1 ];

		switch( syntenyClass )
		{
			case "Rat5_match":
				destinationDataset = "data_rgd5";
				tracks += "%2CRat34SyntenyBlock";
				break;
			case "Rat3.4_match":
				destinationDataset = "data_rgd3_4";

				switch( originDataset )
				{
					case "data_rgd5":
						tracks += "%2CRat5SyntenyBlock";
						break;
					case "data_mm37":
						tracks += "%2CMouseSyntenyBlock%2CMouse37SyntenyBlock";
						break;
					case "data_hg18":
						tracks += "%2CHumanSyntenyBlock";
						break;
					case "data_hg19":
						tracks += "%2CHuman37SyntenyBlock";
						break;
					default:
						destinationDataset = "";
						break;
				}

				break;
			case "Mouse37_match":
				destinationDataset = "data_mm37";

				switch( originDataset )
				{
					case "data_rgd3_4":
						tracks += "%2CRatSyntenyBlock%2CRat34SyntenyBlock";
						break;
					case "data_hg18":
						tracks += "%2CHumanSyntenyBlock";
						break;
					case "data_hg19":
						tracks += "%2CHuman37SyntenyBlock";
						break;
					default:
						destinationDataset = "";
						break;
				}

				break;
			case "Human36_match":
				destinationDataset = "data_hg18";

				switch( originDataset )
				{
					case "data_rgd3_4":
						tracks += "%2CRatSyntenyBlock";
						break;
					case "data_mm37":
						tracks += "%2CMouseSyntenyBlock";
						break;
					default:
						destinationDataset = "";
						break;
				}

				break;
			case "Human37_match":
				destinationDataset = "data_hg19";

				switch( originDataset )
				{
					case "data_rgd3_4":
						tracks += "%2CRatSyntenyBlock";
						break;
					case "data_mm37":
						tracks += "%2CMouseSyntenyBlock";
						break;
					default:
						destinationDataset = "";
						break;
				}

				break;
			default:
				destinationDataset = "";
				break;
		}

		if( destinationDataset != null && destinationDataset != "" )
		{
			document.write( "<tr><td>" + boldOpenTag + parameterName + boldCloseTag + "</td>" );
			document.write( "<td><a href=\"/jbrowse/?data=" + destinationDataset + "&loc=" );
			document.write( location + "&tracks=" + tracks + "&highlight=" + highlight );
			document.write( "\" target=\"_blank\">" + chromosome + ": " + fancifyNumber( startingBP ) );
			document.write( ".." + fancifyNumber( endingBP ) + "</a></td></tr>" );
		}
		else
		{
			document.write( "<tr><td>" + boldOpenTag + parameterName + boldCloseTag + "</td>" );
			document.write( "<td>" + chromosome + ": " + fancifyNumber( startingBP ) );
			document.write( ".." + fancifyNumber( endingBP ) + "</td></tr>" );
		}
	}

	// This function dynamically [and efficiently] calculates
	// the length of a passed feature, with an upper limit
	// on the order of Giga base-pairs (Gbp) in length
	function writeFeatureLengthRow( parameterName, startingBP, endingBP, boldFace, numDigits )
	{
		var diff = endingBP - startingBP, diffFixed, frontLength = diff.toString().length,
			suffixArray = [ "bp", "Kbp", "Mbp", "Gbp" ], i = 0, suffix = suffixArray[ i ];

		while( frontLength > 3 )
		{
			diff /= 1000;
			i += 1;
			suffix = suffixArray[ i ];
			frontLength = diff.toString().split( "." )[ 0 ].toString().length;
		}

		diffFixed = diff.toFixed( numDigits );
		if( diffFixed.split( "." )[ 1 ] == "00" && suffix == "bp" ) diffFixed = diffFixed.split( "." )[ 0 ];
		diffFixed += " " + suffix;

		writeRow( parameterName, diffFixed, boldFace, null, null );
	}

	// This function handles dynamic URL linking for
	// RGD GA Tool links, Ensembl Gene links, Unigene
	// links, and Ensembl SNP links
	function writeDynamicURLrow( inputDoubleArray, rowType, parameterName, parameterValue, boldFace )
	{
		if( ( inputDoubleArray != null && parameterName != null ) && ( parameterValue != null && boldFace != null ) )
		{
			if( boldFace != 0 && boldFace != 1 ) boldFace = 0;

			var htmlLinkPrefix, dataset = getDataset();

			if( dataset != null )
			{
				for( var i = 0; i < inputDoubleArray.length; i++ )
				{
					if( dataset == inputDoubleArray[ i ][ 0 ] )
					{
						htmlLinkPrefix = inputDoubleArray[ i ][ 1 ];
						break;
					}
				}
			}

			if( rowType == 1 ) // writing a spanned row
			{
				if( testEmpty( htmlLinkPrefix ) != "NA" )
					writeSpannedRow( parameterName, boldFace, htmlLinkPrefix, parameterValue );
				else
					writeSpannedRow( parameterName, boldFace, null, null );
			}
			else // writing a regular (double) <td> row
			{
				rowType = 0;

				if( testEmpty( htmlLinkPrefix ) != "NA" )
					writeRow( parameterName, parameterValue, boldFace, htmlLinkPrefix, parameterValue );
				else
					writeRow( parameterName, parameterValue, boldFace, null, null );
			}
		}
	}

	function writeTableBreaks( numBreaks )
	{
		document.write( "</table>" );

		for( var i = 0; i < numBreaks; i++ )
		{
			document.write( "<br />" );
		}

		document.write( "<table cellspacing=\"0\" cellpadding=\"0\">" );
	}

	function assignDBXrefs( dbxRef, matchString, replaceString )
	{
		if( ( ( dbxRef != "NA" && dbxRef != "" ) && ( dbxRef != null && matchString != null ) ) && replaceString != null )
		{
			dbxRef = dbxRef.split( "," );

			for( var i = 0; i < dbxRef.length; i++ )
			{
				if( dbxRef[ i ].match( matchString ) != null )
				{
					return dbxRef[ i ].replace( matchString, replaceString );
				}
			}

			return null;
		}
		else
		{
			return null;
		}
	}

	function writeDBXrefs( dbxRef )
	{
		if( ( dbxRef != "NA" && dbxRef != "" ) && dbxRef != null )
		{
			dbxRef = dbxRef.split( "," );

			writeSpannedRow( "External Database References:", 1, null, null );

			for( var i = 0; i < dbxRef.length; i++ )
			{
				var subDBXref = dbxRef[ i ].split( ":" );
				var subDBXref_name = subDBXref[ 0 ];
				var subDBXref_value = decodeURIComponent( subDBXref[ 1 ] ).replace( / /g, "" );

				switch( subDBXref_name )
				{
					case "EnsemblGenes":
						writeDynamicURLrow( URL_ENSEMBL_GENE, 0, subDBXref_name + ":", subDBXref_value, 0 );
						break;
					case "EntrezGene":
						writeRow( subDBXref_name + ":", subDBXref_value, 0, URL_ENTREZ_GENE, subDBXref_value );
						break;
					// The following 3 cases have been disabled, per
					// RGD users' meeting request
					// case "KEGGPathway":
						// writeRow( subDBXref_name + ":", subDBXref_value, 0, URL_KEGG_PATHWAY, subDBXref_value );
						// break;
					// case "OMIM":
						// writeRow( subDBXref_name + ":", subDBXref_value, 0, URL_OMIM, subDBXref_value );
						// break;
					// case "PharmGKB":
						// writeRow( subDBXref_name + ":", subDBXref_value, 0, URL_PHARM_GKB, subDBXref_value );
						// break;
					case "UniGene":
						writeDynamicURLrow( URL_UNIGENE, 0, subDBXref_name + ":", subDBXref_value, 0 );
						break;
					case "UniProt":
						writeRow( subDBXref_name + ":", subDBXref_value, 0, URL_UNIPROT, subDBXref_value );
						break;
					default:
						break;
				}
			}
		}
	}

	function writeRelatedQTLs( relatedQTLs )
	{
		if( relatedQTLs != null )
		{
			if( relatedQTLs == "NA" || relatedQTLs == "" )
			{
				writeRow( "Related QTLs:", "none", 1, null, null );
			}
			else
			{
				writeSpannedRow( "Related QTLs:", 1, null, null );

				relatedQTLs = relatedQTLs.split( "," );

				for( var i = 0; i < relatedQTLs.length; i++ )
				{
					var subQTL = relatedQTLs[ i ].split( "%7C%7C" );

					// Because internet browsers are fickle and don't want
					// to consistently display either "%7C%7C" or "||" - behavior
					// has been noted to vary from Firefox to Internet Explorer
					if( subQTL.length == 1 )
					{
						subQTL = relatedQTLs[ i ].split( "||" );
					}

					var subQTL_id = subQTL[ 0 ].replace( /:.*$/, "" );
					var subQTL_name = decodeURIComponent( subQTL[ 1 ] );
					var subQTL_value = subQTL[ 4 ];

					writeRow( subQTL_name, subQTL_value, 0, URL_RGD_QTL, subQTL_id );
				}
			}
		}
	}

	function writeRelatedFeatures( relatedFeatures, featuresNameset, fieldSeparator, subFieldSeparator, htmlLinkPrefix, htmlLinkSuffixIndex, sendGAlist )
	{
		if( ( relatedFeatures != null && featuresNameset != null ) && ( fieldSeparator != null && subFieldSeparator != null ) )
		{
			var i, subRelatedFeatures, subFeatures_name, subFeatures_value;

			if( relatedFeatures == "NA" || relatedFeatures == "" )
			{
				writeRow( featuresNameset, "none", 1, null, null );
			}
			else if( ( htmlLinkPrefix != null && htmlLinkSuffixIndex != null ) && ( htmlLinkSuffixIndex % 1 == 0 && htmlLinkSuffixIndex >= 0 ) )
			{
				writeSpannedRow( featuresNameset, 1, null, null );

				relatedFeatures = relatedFeatures.split( fieldSeparator );

				if( sendGAlist == 1 )
				{
					var gene_annotation_list = "";
				}
				else
				{
					// Take care of the "sendGAlist" variable in the event
					// that something silly (or nothing/null) was passed
					sendGAlist = 0;
				}

				for( i = 0; i < relatedFeatures.length; i++ )
				{
					subRelatedFeatures = relatedFeatures[ i ].split( subFieldSeparator );

					subFeatures_name = decodeURIComponent( subRelatedFeatures[ 0 ] );
					subFeatures_value = subRelatedFeatures[ htmlLinkSuffixIndex ];

					writeRow( subFeatures_name, subFeatures_value, 0, htmlLinkPrefix, subFeatures_value );

					if( sendGAlist == 1 ) // Safer control this way
					{
						if( relatedFeatures.length - i == 1 )
						{
							gene_annotation_list += subFeatures_value;
						}
						else
						{
							gene_annotation_list += subFeatures_value + ",";
						}
					}
				}

				if( sendGAlist == 1 && gene_annotation_list != "" )
				{
					writeDynamicURLrow( URL_RGD_GA_TOOL, 1, "RGD Gene Annotation analysis for candidate genes",
										gene_annotation_list, 1 );
				}
			}
			else
			{
				writeSpannedRow( featuresNameset, 1, null, null );

				relatedFeatures = relatedFeatures.split( fieldSeparator );

				for( i = 0; i < relatedFeatures.length; i++ )
				{
					subRelatedFeatures = relatedFeatures[ i ].split( subFieldSeparator );

					subFeatures_name = decodeURIComponent( subRelatedFeatures[ 0 ] );
					subFeatures_value = decodeURIComponent( subRelatedFeatures[ 1 ] );

					writeRow( subFeatures_name, subFeatures_value, 0, null, null );
				}
			}
		}
	}

	// This ontology-writing function is designed to list
	// associated disease and phenotype ontology database
	// entries for congenic rat strain tracks
	function writeOntologyFeatures( ontologyFeatures, ontologyNameset, fieldSeparator, subFieldSeparator, htmlLinkPrefix, htmlLinkSuffixIndex, htmlLinkSuffixSeparator )
	{
		if( ( ontologyFeatures != null && ontologyNameset != null ) && ( fieldSeparator != null && htmlLinkPrefix != null ) )
		{
			var i, subOntologyFeatures, subOntologyFeatures_name, subOntologyFeatures_value;

			if( ontologyFeatures == "" || ontologyFeatures == "NA" )
			{
				writeRow( ontologyNameset, "none", 1, null, null );
			}
			else if( ( ( htmlLinkPrefix != null && htmlLinkSuffixIndex != null ) && ( htmlLinkSuffixIndex % 1 == 0 && htmlLinkSuffixIndex >= 0 ) ) && htmlLinkSuffixSeparator != null )
			{
				writeSpannedRow( ontologyNameset, 1, null, null );

				ontologyFeatures = ontologyFeatures.split( fieldSeparator );

				for( i = 0; i < ontologyFeatures.length; i++ )
				{
					subOntologyFeatures = ontologyFeatures[ i ].split( subFieldSeparator );

					if( subOntologyFeatures.length == 1 ) continue;

					subOntologyFeatures_name = "";
					subOntologyFeatures_value = decodeURIComponent( subOntologyFeatures[ 2 ] );

					for( var j = 0; j < htmlLinkSuffixIndex; j++ )
					{
						if( htmlLinkSuffixIndex - j == 1 )
						{
							subOntologyFeatures_name += subOntologyFeatures[ j ];
						}
						else
						{
							subOntologyFeatures_name += subOntologyFeatures[ j ] + htmlLinkSuffixSeparator;
						}
					}

					writeRow( subOntologyFeatures_name, subOntologyFeatures_value, 0, htmlLinkPrefix, subOntologyFeatures_name );
				}
			}
			else
			{
				writeSpannedRow( ontologyNameset, 1, null, null );

				ontologyFeatures = ontologyFeatures.split( fieldSeparator );

				for( i = 0; i < ontologyFeatures.length; i++ )
				{
					subOntologyFeatures = ontologyFeatures[ i ].split( subFieldSeparator );

					if( subOntologyFeatures.length == 1 ) continue;

					subOntologyFeatures_name = subOntologyFeatures[ 0 ] + ":" + subOntologyFeatures[ 1 ];
					subOntologyFeatures_value = decodeURIComponent( subOntologyFeatures[ 2 ] );

					writeRow( subOntologyFeatures_name, subOntologyFeatures_value, 0, null, null );
				}
			}
		}
	}

	// This function is specifically designed to list
	// RGD ontology database entries for disease-related
	// feature tracks
	function writeDiseaseOntologyTerms( ontologyTerms, ontologyNameset, fieldSeparator, subFieldSeparator, secondarySeparator, backupSecondarySeparator, htmlPrefix )
	{
		if( ( ( ontologyTerms != null && ontologyNameset != null ) && ( fieldSeparator != null && subFieldSeparator != null ) ) && ( secondarySeparator != null && backupSecondarySeparator != null ) )
		{
			var i, subOntologyTerms, DOID_id, DOID_termBlock, DOID_term;

			if( testEmpty( ontologyTerms ) == "NA" ) {
				writeRow( ontologyNameset, "none", 1, null, null );
			}
			else {
				writeSpannedRow( ontologyNameset, 1, null, null );

				ontologyTerms = ontologyTerms.split( fieldSeparator );

				for( i = 0; i < ontologyTerms.length; i++ )
				{
					subOntologyTerms = ontologyTerms[ i ].split( subFieldSeparator );

					if( subOntologyTerms.length == 1 ) continue;

					DOID_id = subOntologyTerms[ 0 ];
					// Initialize like this because IntelliJ is picky
					DOID_term = decodeURIComponent( subOntologyTerms[ 1 ] );

					DOID_termBlock = DOID_term.split( secondarySeparator );

					if( DOID_termBlock.length == 1 ) DOID_termBlock = DOID_term.split( backupSecondarySeparator );

					if( DOID_termBlock.length == 1 ) DOID_term = DOID_termBlock[ 0 ];
					else DOID_term = DOID_termBlock[ 0 ] + " (" + DOID_termBlock[ 1 ] + ")";

					if( testEmpty( htmlPrefix ) != "NA" ) writeRow( DOID_term, DOID_id, 0, htmlPrefix, DOID_id );
					else writeRow( DOID_term, DOID_id, 0, null, null );
				}
			}
		}
	}

	// This function writes ontology interaction
	// table rows for the gene-chemical interaction
	// feature tracks
	function writeDrugGeneOntologyTerms( ontologyTerms, ontologyNameset, fieldSeparator, subFieldSeparator, secondarySeparator, backup_secondarySeparator, baseHtmlPrefix, tableHtmlPrefix )
	{
		if( ( ( ontologyTerms != null && ontologyNameset != null ) && ( fieldSeparator != null && subFieldSeparator != null ) ) && ( ( secondarySeparator != null && backup_secondarySeparator != null ) && ( baseHtmlPrefix != null && tableHtmlPrefix != null ) ) )
		{
			if( ( ontologyTerms == "" || ontologyTerms == "null" ) || ontologyTerms == "NA" ) {
				writeRow( ontologyNameset, "none", 1, null, null );
			}
			else {
				var subOntologyTerms, subOntologyTerms_ontoEntry,
					subOntologySet, subOntologySet_name, subOntologySet_value;

				writeSpannedRow( ontologyNameset, 1, null, null );

				ontologyTerms = ontologyTerms.split( fieldSeparator );

				for( var i = 0; i < ontologyTerms.length; i++ )
				{
					subOntologyTerms = ontologyTerms[ i ].split( subFieldSeparator );

					subOntologyTerms_ontoEntry = subOntologyTerms[ 0 ];

					subOntologySet = subOntologyTerms[ 1 ].split( secondarySeparator );

					if( subOntologySet.length == 1 )
					{
						subOntologySet = subOntologyTerms[ 1 ].split( backup_secondarySeparator );
					}

					if( subOntologySet.length == 1 ) continue;

					subOntologySet_name = decodeURIComponent( subOntologySet[ 0 ] );
					subOntologySet_value = decodeURIComponent( subOntologySet[ 1 ] );

					document.write( "<tr><td><a href=\"" + baseHtmlPrefix + "acc_id=" + subOntologyTerms_ontoEntry
					+ "\" target=\"_blank\">" + subOntologySet_name + "</a></td><td><a href=\"" + tableHtmlPrefix
					+ "term=" + subOntologyTerms_ontoEntry + "&id=" + dbxRef_rgdID + "\" target=\"_blank\">"
					+ subOntologySet_value + "</a></td></tr>" );
				}
			}
		}
	}

	// This function writes tissue-to-chipSeq
	// densities for the EPD feature track(s)
	function writeTissueDensities( tissueNameset, chipSeqNameset, tissues, densities )
	{
		if( ( tissueNameset != null && chipSeqNameset != null ) && ( tissues != null && densities != null ) )
		{
			document.write( "<tr><td><strong>" + tissueNameset + "</strong></td><td><strong>" );
			document.write( chipSeqNameset + "</strong></td></tr>" );

			tissues = tissues.split( "," );
			densities = densities.split( "," );

			for( var i = 0; i < tissues.length; i++ )
			{
				writeRow( tissues[ i ], testEmpty( densities[ i ] ), 0, null, null );
			}
		}
	}

	// This function writes singular promoter-to-gene
	// relationships for the EPD feature track(s)
	function writePromoterGeneRelation( promoterGeneRlt, promoterGeneNameset, fieldSeparator, subFieldSeparator )
	{
		if( testEmpty( promoterGeneRlt ) == "NA" )
		{
			writeRow( promoterGeneNameset, "none", 1, null, null );
		}
		else if( ( promoterGeneRlt != null && promoterGeneNameset != null ) && ( fieldSeparator != null && subFieldSeparator != null ) )
		{
			writeSpannedRow( promoterGeneNameset, 1, null, null );

			promoterGeneRlt = promoterGeneRlt.split( fieldSeparator );
			var subFieldPromoter, subPromoter_name, subPromoter_value,
				GAlist = "";

			for( var i = 0; i < promoterGeneRlt.length; i++ )
			{
				subFieldPromoter = promoterGeneRlt[ i ].split( subFieldSeparator );
				subPromoter_name = subFieldPromoter[ 0 ];
				subPromoter_value = subFieldPromoter[ 1 ];

				if( promoterGeneRlt.length - i == 1 )
					GAlist += subPromoter_value;
				else
					GAlist += subPromoter_value + ",";

				writeRow( subPromoter_name, subPromoter_value, 0, URL_RGD_GENE, subPromoter_value );
			}

			if( GAlist != "" )
				writeDynamicURLrow( URL_RGD_GA_TOOL, 1, "RGD Gene Annotation Analysis for promoter genes",
									GAlist, 1 );
		}
	}

	// This function writes a variant call analysis
	// table for indel feature track data from the
	// Hubrecht Institute
	function writeVariantCallAnalysis( variantSeq, infoAC, vcaNameset, variantSeqDesc, variantACdesc )
	{
		if( ( ( variantSeq != null && infoAC != null ) && ( vcaNameset != null && variantSeqDesc != null ) ) && variantACdesc != null )
		{
			variantSeq = variantSeq.split( "," );
			infoAC = infoAC.split( "," );

			writeSpannedRow( vcaNameset, 1, null, null );
			writeRow( variantSeqDesc, variantACdesc, 0, null, null );

			for( i = 0; i < variantSeq.length; i++ )
			{
				writeRow( variantSeq[ i ], testEmpty( infoAC[ i ] ), 0, null, null );
			}
		}
	}

	// This function writes an allelic depth table
	// for indel feature track data from the
	// Imperial College of London (ICL)
	function writeICL_allelicDepth( variantSeq, formatAD, formatGT, formatGQ, nameset, variantSeqDesc, variantADdesc )
	{
		if( ( ( variantSeq != null && formatAD != null ) && ( formatGT != null && formatGQ != null ) ) && ( ( nameset != null && variantSeqDesc != null ) && variantADdesc != null ) )
		{
			variantSeq = variantSeq.split( "," );
			formatAD = formatAD.split( "," );

			writeSpannedRow( nameset, 1, null, null );
			writeRow( variantSeqDesc, variantADdesc, 0, null, null );

			for( var i = 0; i < variantSeq.length; i++ )
			{
				writeRow( variantSeq[ i ], testEmpty( formatAD[ i ] ), 0, null, null );
			}

			writeRow( "Genotype:", formatGT, 1, null, null );
			writeRow( "Genotype quality:", formatGQ, 1, null, null );
		}
	}

	// This function fixes Class values for "transcripts"
	// tracks without resolving discrepancies
	// from the original source GFF3 data
	function fixTranscriptsType( isNonCoding )
	{
		if( testEmpty( isNonCoding ) != "NA" )
		{
			if( isNonCoding.match( /^y$/i ) != null ) return "RNA";
			else if( isNonCoding.match( /^n$/i ) != null ) return "mRNA";
			else return null;
		}
		else return null;
	}

	// This function writes location rows for
	// multi-congenic strains features
	function writeMultiCongenicStrains( spannedTitle, titleBoldFace, locationPrefix, locationSuffix, locationBoldFace )
	{
		if( ( ( spannedTitle != null && titleBoldFace != null ) && ( locationPrefix != null && locationSuffix != null ) ) && locationBoldFace != null )
		{
			var locations = window.location.search.substring( 1 ).match( /loc[0-9]*=Chr[0-9XY]*:[0-9]*\.\.[0-9]*/gi );
			var i, subLocation, subLocationNumber,
				chr, BPrange, startBP, endBP;

			writeSpannedRow( spannedTitle, titleBoldFace, null, null );

			for( i = 0; i < locations.length; i++ )
			{
				subLocation = locations[ i ].toString().split( "=" );
				subLocationNumber = subLocation[ 0 ].toString().replace( /^loc/i, locationPrefix ) + locationSuffix;
				chr = subLocation[ 1 ].toString().split( ":" )[ 0 ].toString();
				BPrange = subLocation[ 1 ].toString().split( ":" )[ 1 ].toString();
				startBP = BPrange.split( "\.\." )[ 0 ].toString();
				endBP = BPrange.split( "\.\." )[ 1 ].toString();

				writeLocationRow( subLocationNumber, chr, startBP, endBP, locationBoldFace );
			}
		}
	}

	// This function writes the origin row
	// for congenic strains features
	function writeOrigin( parameterName, boldFace )
	{
		if( parameterName != null && boldFace != null )
		{
			var origin = window.location.search.substring( 1 ).match( /origin=.*$/ ).toString();
			origin = decodeURIComponent( testEmpty( origin.replace( /^origin=/, "" ) ) );

			writeRow( parameterName, origin, boldFace, null, null );
		}
	}

	function writeClinVar() {
		writeRow( "Symbol:", symbol, 1, URL_RGD_VARIANT, dbxRef_rgdID );
		writeRow( "Name:", name, 1, null, null );
		writeRow( "Clinical Significance:", clinicalSignificance, 1, null, null );
		writeRow( "Trait Name(s):", cvTraitName, 1, null, null );
		writeRow( "Molecular Consequence:", cvMolecularConsequence, 1, null, null );
		writeRow( "Method Type:", cvMethodType, 1, null, null );
		writeRow( "Submitter:", cvSubmitter, 1, null, null );
		writeRow( "Age of Onset:", cvAgeOfOnset, 1, null, null );
		writeRow( "Prevalence:", cvPrevalence, 1, null, null );
	}

	// ************************* GLOBALS *********************************
	// "Global" debug variable to enable display
	// of track type at the very top of the
	// context menu
	//
	// DEBUG trackType variable: set to 1 to
	// display (default: disabled)
	var DEBUG_trackType = 0;

	// "Global" URL prefix variables for
	// the various RGD sites we'll be linking
	// to throughout the runtime of this script
	//
	// RGD tools' global URL prefix variables
	var URL_RGD_GENE = "/rgdweb/report/gene/main.html?id=";
	var URL_RGD_GA_TOOL =
	[
		[ "data_rgd6", "/rgdweb/ga/ui.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=25&x=30&x=45&x=29&x=44&x=20&x=23&x=32&x=27&x=17&x=2&x=42&x=41&x=9&x=3&x=5&x=28&x=12&x=13&x=8&x=1&x=10&x=35&x=7&x=6&x=38&x=39&x=34&x=15&x=18&x=36&x=37&x=21&x=31&x=43&x=24&x=33&x=26&x=22&x=46&x=4&x=40&x=14&ortholog=1&ortholog=2&species=3&mapKey=360&rgdId=&idType=rgd&genes=" ],
		[ "data_rgd5", "/rgdweb/ga/ui.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=25&x=30&x=45&x=29&x=44&x=20&x=23&x=32&x=27&x=17&x=2&x=42&x=41&x=9&x=3&x=5&x=28&x=12&x=13&x=8&x=1&x=10&x=35&x=7&x=6&x=38&x=39&x=34&x=15&x=18&x=36&x=37&x=21&x=31&x=43&x=24&x=33&x=26&x=22&x=46&x=4&x=40&x=14&ortholog=1&ortholog=2&species=3&mapKey=70&rgdId=&idType=rgd&genes=" ],
		[ "data_rgd3_4", "/rgdweb/ga/ui.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=25&x=30&x=45&x=29&x=44&x=20&x=23&x=32&x=27&x=17&x=2&x=42&x=41&x=9&x=3&x=5&x=28&x=12&x=13&x=8&x=1&x=10&x=35&x=7&x=6&x=38&x=39&x=34&x=15&x=18&x=36&x=37&x=21&x=31&x=43&x=24&x=33&x=26&x=22&x=46&x=4&x=40&x=14&ortholog=1&ortholog=2&species=3&mapKey=60&rgdId=&idType=rgd&genes=" ],
		[ "data_mm37", "/rgdweb/ga/ui.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=25&x=30&x=45&x=29&x=44&x=20&x=23&x=32&x=27&x=17&x=2&x=42&x=41&x=9&x=3&x=5&x=28&x=12&x=13&x=8&x=1&x=10&x=35&x=7&x=6&x=38&x=39&x=34&x=15&x=18&x=36&x=37&x=21&x=31&x=43&x=24&x=33&x=26&x=22&x=46&x=4&x=40&x=14&ortholog=1&ortholog=3&species=2&mapKey=18&rgdId=&idType=rgd&genes=" ],
		[ "data_hg18", "/rgdweb/ga/ui.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=25&x=30&x=45&x=29&x=44&x=20&x=23&x=32&x=27&x=17&x=2&x=42&x=41&x=9&x=3&x=5&x=28&x=12&x=13&x=8&x=1&x=10&x=35&x=7&x=6&x=38&x=39&x=34&x=15&x=18&x=36&x=37&x=21&x=31&x=43&x=24&x=33&x=26&x=22&x=46&x=4&x=40&x=14&ortholog=3&ortholog=2&species=1&mapKey=13&rgdId=&idType=rgd&genes=" ],
		[ "data_hg19", "/rgdweb/ga/ui.html?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=25&x=30&x=45&x=29&x=44&x=20&x=23&x=32&x=27&x=17&x=2&x=42&x=41&x=9&x=3&x=5&x=28&x=12&x=13&x=8&x=1&x=10&x=35&x=7&x=6&x=38&x=39&x=34&x=15&x=18&x=36&x=37&x=21&x=31&x=43&x=24&x=33&x=26&x=22&x=46&x=4&x=40&x=14&ortholog=3&ortholog=2&species=1&mapKey=17&rgdId=&idType=rgd&genes=" ]
	];
	var URL_RGD_QTL = "/rgdweb/report/qtl/main.html?id=";
	var URL_RGD_STRAIN = "/rgdweb/report/strain/main.html?id=";
	var URL_RGD_ONTOLOGY = "/rgdweb/ontology/annot.html?acc_id=";
	var URL_RGD_ONTOLOGY_BASE = "/rgdweb/ontology/annot.html?";
	var URL_RGD_ONTOLOGY_TABLE = "/rgdweb/report/annotation/table.html?";
	var URL_RGD_MARKER = "/rgdweb/report/marker/main.html?id=";
	var URL_RGD_PROMOTER = "/rgdweb/report/ge/main.html?id=";
	var URL_RGD_VARIANT = "/rgdweb/report/variant/main.html?id=";
	var URL_NCBI_NUCCORE = "https://www.ncbi.nlm.nih.gov/nuccore/";

	// Global URL prefix variables for the
	// "writeDBXrefs" function written above
	var URL_ENSEMBL_GENE =
	[
		[ "data_rgd6", "http://www.ensembl.org/Rattus_norvegicus/Gene/Summary?g=" ],
		[ "data_rgd5", "http://www.ensembl.org/Rattus_norvegicus/Gene/Summary?g=" ],
		[ "data_rgd3_4", "http://www.ensembl.org/Rattus_norvegicus/Gene/Summary?g=" ],
		[ "data_mm37", "http://www.ensembl.org/Mus_musculus/Gene/Summary?g=" ],
		[ "data_hg18", "http://www.ensembl.org/Homo_sapiens/Gene/Summary?g=" ],
		[ "data_hg19", "http://www.ensembl.org/Homo_sapiens/Gene/Summary?g=" ]
	];
	var URL_ENTREZ_GENE = "https://www.ncbi.nlm.nih.gov/gene/?term=";
	var URL_KEGG_PATHWAY = "http://www.genome.jp/dbget-bin/www_bget?pathway:map";
	var URL_OMIM = "http://omim.org/entry/";
	var URL_PHARM_GKB = "https://www.pharmgkb.org/gene/";
	var URL_UNIGENE =
	[
		[ "data_rgd6", "https://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=Rn&CID=" ],
		[ "data_rgd5", "https://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=Rn&CID=" ],
		[ "data_rgd3_4", "https://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=Rn&CID=" ],
		[ "data_mm37", "https://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=Mm&CID=" ],
		[ "data_hg18", "https://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=Hs&CID=" ],
		[ "data_hg19", "https://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=Hs&CID=" ]
	];
	var URL_UNIPROT = "http://www.uniprot.org/uniprot/";

	// Global URL prefix variables for the
	// SNP, micro-satellite, and miRNA tracks
	var URL_NCBI_SNP = "https://www.ncbi.nlm.nih.gov/SNP/snp_ref.cgi?rs=";
	var URL_ENSEMBL_SNP =
	[
		[ "data_rgd6", "http://www.ensembl.org/Rattus_norvegicus/Variation/Explore?v=" ],
		[ "data_rgd5", "http://www.ensembl.org/Rattus_norvegicus/Variation/Explore?v=" ],
		[ "data_rgd3_4", "http://www.ensembl.org/Rattus_norvegicus/Variation/Explore?v=" ],
		[ "data_mm37", "http://www.ensembl.org/Mus_musculus/Variation/Explore?v=" ],
		[ "data_hg18", "http://www.ensembl.org/Homo_sapiens/Variation/Explore?v=" ],
		[ "data_hg19", "http://www.ensembl.org/Homo_sapiens/Variation/Explore?v=" ]
	];
	var URL_MI_RBASE = "http://www.mirbase.org/cgi-bin/mirna_entry.pl?id=";
	// *******************************************************************

	// The variable that controls determination
	// (and switching) of track type - valid
	// track type determinants are limited to:
	//
	// rn5 track types:
	// ----------------
	// QTL
	// congenicStrains (includes mutantStrains and multiCongenicStrains)
	// synteny
	// transcripts
	// RNAseqFeatures
	// dbSNP
	// ensemblSNP
	// microSatellite
	// diseaseOntology
	// drugGeneOntology
	// DEFAULT (genericGeneFeatures)
	//
	// rn3.4 track types:
	// ------------------
	// diseaseQTLontology
	// diseaseStrainOntology
	// entrezGene
	// entrezNonGeneFeature
	// miRNA
	// EPDpromoter
	// methylation
	// indelHubrecht
	// indelICL
	// physGenStrains
	// misassembly
	// CNV
	//
	// hg18 track types:
	// -----------------
	// 1000Genomes
	var trackType;

	// General Gene Model track variables
	var source, type, seq_id, start, end, name,
		fullName, geneType, refSeqStatus, species,
		note, id, rgdID, dbxRef, dbxRef_rgdID;

	// QTL track-associated variables
	//
	// For some reason, the "ID" parameter for QTL tracks
	// doesn't work, and we need to fetch "dbxRef" instead
	var LOD, mappingMethod, pValue, relatedGenes,
		relatedStrains, relatedQTLs;

	// Congenic Strains track variables
	//
	// The "id" parameter for Congenic Strains
	// can only be fetched correctly from "alias"
	var alias, aliasID, diseaseOntologyAssociation,
		alias_rgdID, phenotypeOntologyAssociation;

	// Synteny track variables
	var synBlockLength, synStart, synEnd, synChrNum;

	// Gene Model Transcripts track variables
	//
	// This variable doesn't actually
	// need to be defined, because it is otherwise
	// defined from the standard "name" variable
	// var mRNA_id;
	var gene, isNonCoding;

	// RNA-seq Features track variables
	// (NO ADDITIONAL VARIABLES REQUIRED)

	// dbSNP track variables
	var mapWeight, allele, functionClass, clinicalSignificance;

	// ensemblSNP track variables
	var strain;

	// Micro-satellite marker track variables
	var expectedSize;

	// Disease-related features track variables
	var symbol, ontologyTerms;

	// Drug-Gene Interactions features track variables
	// (NO ADDITIONAL VARIABLES REQUIRED)

	// rn3.4 disease QTL ontology features track variables
	// (NO ADDITIONAL VARIABLES REQUIRED)

	// rn3.4 disease strain ontology features track variables
	var symbolArray;

	// rn3.4 Entrez (NCBI) gene features track variables
	var dbxRef_entrezID, dbxRef_mgcID, dbxRef_imageID;

	// rn3.4 Entrez (NCBI) transcript and pseudogene
	// features track variables
	var product, transcriptID, proteinID, codonStart,
		dbxRef_giID;

	// rn3.4 miRNA features track variables
	// (NO ADDITIONAL VARIABLES REQUIRED)

	// rn3.4 EPD promoter features track variables
	var promoterGeneRlt, experimentMethods, regulation,
		objectType, tissues, densities;

	// rn3.4 methylation features track variables
	var score;

	// rn3.4 Hubrecht Institute indel variables
	var referenceSeq, infoDP, variantType, variantSeq,
		infoAC;

	// rn3.4 Imperial College of London (ICL) indel
	// track variables
	var infoAN, formatGQ, formatPL, infoVQSLOD, formatDP,
		infoAB, infoHaplotypeScore, infoMQ0, formatAD,
		infoAF, infoSB, formatGT, infoMQ, infoHRun, infoFS,
		infoBaseQRankSum, infoQD, infoReadPosRankSum;

	// rn3.4 PhysGen mutant strains track variables
	var id2, rgdID2;

	// rn3.4 Hubrecht Institute misassemblies track variables
	var method, reference;

	// rn3.4 Hubrecht Institute CNVs track variables
	// (NO ADDITIONAL VARIABLES REQUIRED)

	// hg18 1000Genomes track variables
	// (NO ADDITIONAL VARIABLES REQUIRED)

	// clinvar variables
	var cvMethodType, cvMolecularConsequence, cvAgeOfOnset, cvPrevalence, cvSubmitter, cvTraitName;

	var URLparts = window.location.search.substring( 1 ).split( "&" );

	for( var i = 0; i < URLparts.length; i++ )
	{
		// document.write( URLparts[ i ] + "<br />" );
		//
		// The following variable, "URL_subParts", is a temporary
		// array variable declared within the scope of the above
		// for-loop. Each instance of "URL_subParts", for every
		// iteration of the loop, has only two value in the 0th and
		// 1st array nodes. The 0th node contains the "key", and
		// the 1st node contains the "value" for current loop's
		// key-value pair.
		var URL_subParts = URLparts[ i ].split( "=" );

		// document.write( URL_subParts[ 0 ] + "&nbsp;" + URL_subParts[ 1 ] + "<br /><br />" );

		switch( URL_subParts[ 0 ] )
		{
			case "source":
				source = decodeURIComponent( URL_subParts[ 1 ] ).replace( /\+/g, " " );
				break;
			case "type":
				type = URL_subParts[ 1 ];
				break;
			case "seq_id":
				seq_id = URL_subParts[ 1 ];
				break;
			case "start":
				if( start == null ) start = URL_subParts[ 1 ];
				break;
			case "end":
				if( end == null ) end = URL_subParts[ 1 ];
				break;
			case "name":
				name = decodeURIComponent( URL_subParts[ 1 ] );
				if( name.match( /^QTL:/i ) != null ) name = name.substring( 4 );
				break;
			case "fullName":
				fullName = decodeURIComponent( URL_subParts[ 1 ] );
				break;
			case "geneType":
				geneType = URL_subParts[ 1 ].replace( /rna/i, "RNA" ).replace( /_/, " " );
				geneType = geneType.replace( /null null/i, "null" ).replace( /pseudo/i, "pseudogene" );
				break;
			case "refSeqStatus":
				refSeqStatus = testEmpty( URL_subParts[ 1 ] );
				break;
			case "species":
				species = URL_subParts[ 1 ];
				break;
			case "note":
				note = decodeURIComponent( URL_subParts[ 1 ].replace( /%EF%BF%BD/g, "%2C" ) );
				note = testEmpty( note.replace( /\+/g, " " ) );

				// Because Internet Explorer is completely fickle
				// and automatically decodes URI components
				// *before* any attempt has been made to change
				// the base HTML encoding characters
				note = note.replace( new RegExp( String.fromCharCode( 65535 ), "g" ), "," );
				break;
			case "id":
				id = testEmpty( URL_subParts[ 1 ] );
				rgdID = id.replace( /^RGD|_.*$/gi, "" );
				break;
			case "LOD":
				LOD = testEmpty( URL_subParts[ 1 ] );
				break;
			case "mappingMethod":
				mappingMethod = decodeURIComponent( URL_subParts[ 1 ] );
				break;
			case "pValue":
				pValue = testEmpty( URL_subParts[ 1 ] );
				break;
			case "relatedGenes":
				relatedGenes = URL_subParts[ 1 ];
				break;
			case "relatedStrains":
				relatedStrains = URL_subParts[ 1 ];
				break;
			case "dbxRef":
				dbxRef = URL_subParts[ 1 ];
				dbxRef_rgdID = testEmpty( assignDBXrefs( dbxRef, /^RGD:/i, "" ) );
				dbxRef_entrezID = testEmpty( assignDBXrefs( dbxRef, /^GeneID:/i, "" ) );
				dbxRef_mgcID = testEmpty( assignDBXrefs( dbxRef, /^MGC:/i, "" ) );
				dbxRef_imageID = testEmpty( assignDBXrefs( dbxRef, /^IMAGE:/i, "" ) );
				dbxRef_giID = testEmpty( assignDBXrefs( dbxRef, /^GI:/i, "" ) );
				break;
			case "relatedQTLs":
				relatedQTLs = URL_subParts[ 1 ];
				break;
			case "alias":
				alias = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				
				if( alias != "NA" )
					aliasID = alias.split( "," )[ 0 ].substring( 4 );
				if( alias != "NA" && alias.split( "," ).length > 1 )
					alias_rgdID = alias.split( "," )[ 1 ].substring( 3 );
				
				break;
			case "diseaseOntologyAssociation":
				diseaseOntologyAssociation = URL_subParts[ 1 ];
				break;
			case "phenotypeOntologyAssociation":
				phenotypeOntologyAssociation = URL_subParts[ 1 ];
				break;
			case "synBlockLength":
				synBlockLength = URL_subParts[ 1 ];
				break;
			case "synStart":
				synStart = URL_subParts[ 1 ];
				break;
			case "synEnd":
				synEnd = URL_subParts[ 1 ];
				break;
			case "synChrNum":
				synChrNum = URL_subParts[ 1 ];
				break;
			case "gene":
				gene = testEmpty( URL_subParts[ 1 ] );
				break;
			case "isNonCoding":
				isNonCoding = URL_subParts[ 1 ];
				break;
			case "mapWeight":
				mapWeight = testEmpty( URL_subParts[ 1 ] );
				break;
			case "allele":
				allele = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "functionClass":
				functionClass = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "strain":
				strain = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "expectedSize":
				expectedSize = testEmpty( URL_subParts[ 1 ] );
				break;
			case "symbol":
				symbol = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				if( symbol != "NA" )
					symbolArray = symbol.split( ")/" );
				
				break;
			case "ontologyTerms":
				ontologyTerms = URL_subParts[ 1 ];
				break;
			case "product":
				product = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "transcriptID":
				transcriptID = testEmpty( URL_subParts[ 1 ] );
				break;
			case "proteinID":
				proteinID = testEmpty( URL_subParts[ 1 ] );
				break;
			case "codonStart":
				codonStart = testEmpty( URL_subParts[ 1 ] );
				break;
			case "promoterGeneRlt":
				promoterGeneRlt = testEmpty( URL_subParts[ 1 ] );
				break;
			case "experimentMethods":
				experimentMethods = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "regulation":
				regulation = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "objectType":
				objectType = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "tissues":
				tissues = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "densities":
				densities = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "score":
				score = testEmpty( URL_subParts[ 1 ] );
				break;
			case "referenceSeq":
				referenceSeq = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoDP":
				infoDP = testEmpty( URL_subParts[ 1 ] );
				break;
			case "variantType":
				variantType = testEmpty( URL_subParts[ 1 ] );
				break;
			case "variantSeq":
				variantSeq = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoAC":
				infoAC = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoAN":
				infoAN = testEmpty( URL_subParts[ 1 ] );
				break;
			case "formatGQ":
				formatGQ = testEmpty( URL_subParts[ 1 ] );
				break;
			case "formatPL":
				formatPL = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoVQSLOD":
				infoVQSLOD = testEmpty( URL_subParts[ 1 ] );
				break;
			case "formatDP":
				formatDP = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoAB":
				infoAB = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoHaplotypeScore":
				infoHaplotypeScore = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoMQ0":
				infoMQ0 = testEmpty( URL_subParts[ 1 ] );
				break;
			case "formatAD":
				formatAD = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoAF":
				infoAF = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoSB":
				infoSB = testEmpty( URL_subParts[ 1 ] );
				break;
			case "formatGT":
				formatGT = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ) );
				break;
			case "infoMQ":
				infoMQ = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoHRun":
				infoHRun = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoFS":
				infoFS = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoBaseQRankSum":
				infoBaseQRankSum = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoQD":
				infoQD = testEmpty( URL_subParts[ 1 ] );
				break;
			case "infoReadPosRankSum":
				infoReadPosRankSum = testEmpty( URL_subParts[ 1 ] );
				break;
			case "id2":
				id2 = testEmpty( URL_subParts[ 1 ] );
				rgdID2 = id2.replace( /^RGD:/i, "" );
				break;
			case "method":
				method = testEmpty( decodeURIComponent( URL_subParts[ 1 ] ).replace( /\+/g, " " ) );
				break;
			case "reference":
				reference = window.location.search.match( /reference=[0-9]*&start=[0-9]*&end=[0-9]*/i );
				if( reference != null ) {
					reference = reference.toString().replace( /&/g, " " );
					reference = reference.replace( /^reference=/i, "chr:" );
				}
				break;

			case "clinicalSignificance":
				clinicalSignificance = decodeURIComponent(testEmpty(URL_subParts[1]));
				break;
			case "methodType":
				cvMethodType = decodeURIComponent(testEmpty(URL_subParts[1]));
				break;
			case "molecularConsequence":
				cvMolecularConsequence = decodeURIComponent(testEmpty(URL_subParts[1]));
				break;
			case "ageOfOnset":
				cvAgeOfOnset = decodeURIComponent(testEmpty(URL_subParts[1]));
				break;
			case "prevalence":
				cvPrevalence = decodeURIComponent(testEmpty(URL_subParts[1]));
				break;
			case "submitter":
				cvSubmitter = decodeURIComponent(testEmpty(URL_subParts[1]));
				break;
			case "traitName":
				cvTraitName = decodeURIComponent(testEmpty(URL_subParts[1]));
				break;

			default:
				break;
		}
	}

	// Determine the type of track to display
	trackType = determineTrackType( source, type );

	// Apply the Class values fix for "transcripts" tracks
	if( trackType == "transcripts" ) type = fixTranscriptsType( isNonCoding );

	// Initial table setup
	document.write( "<table cellspacing=\"0\" cellpadding=\"0\">" );

	if( DEBUG_trackType == 1 )
	{
		if( trackType == null ) writeRow( "Track Type:", "genericGene", 1, null, null );
		else writeRow( "Track Type:", trackType, 1, null, null );

		writeTableBreaks( 1 );
	}

	writeRow( "Source:", source, 1, null, null );
	writeRow( "Class:", type.split( "," )[ 0 ], 1, null, null );
	writeLocationRow( "Genome Location: (Chr:Start..Stop)", seq_id, start, end, 1 );
	writeFeatureLengthRow( "Feature Length:", start, end, 1, 2 );

	switch( trackType )
	{
		case "ClinVar":
			writeClinVar();
			break;
		case "QTL": // rn5 (and rn3.4) generic QTL tracks
			writeRow( "Name:", name, 1, null, null );
			writeRow( "Full Name:", fullName, 1, null, null );
			writeRow( "Mapping Method:", mappingMethod, 1, null, null );
			writeRow( "LOD:", LOD, 1, null, null );
			writeRow( "p-value:", pValue, 1, null, null );
			if( dbxRef_rgdID != "NA" ) writeRow( "RGD ID:", dbxRef_rgdID, 1, URL_RGD_QTL, dbxRef_rgdID );
			writeRelatedQTLs( relatedQTLs );
			writeRelatedFeatures( relatedStrains, "Related Strains:", ",", ":", URL_RGD_STRAIN, 1, 0 );
			writeRelatedFeatures( relatedGenes, "Candidate Genes:", ",", ":", URL_RGD_GENE, 1, 1 );
			break;
		case "congenicStrains": // Rat congenic, multi-congenic, and mutant strains tracks
			writeRow( "RGD Rat Strain:", name, 1, URL_RGD_STRAIN, aliasID );
			if( type.match( /^multicongenic/i ) != null )
				writeMultiCongenicStrains( "Additional Locations:", 1, "Location #", ":", 0 );
			writeOntologyFeatures( phenotypeOntologyAssociation, "Phenotype Ontologies:",
									",", ":", URL_RGD_ONTOLOGY, 2, ":" );
			writeOntologyFeatures( diseaseOntologyAssociation, "Disease Ontologies:",
									",", ":", URL_RGD_ONTOLOGY, 2, ":" );
			writeRow( "Description:", note, 1, null, null );
			writeOrigin( "Origin:", 1 );
			break;
		case "synteny": // rn5 synteny tracks
			writeRow( "Synteny Block ID:", name, 1, null, null );
			writeSyntenyRow( "Corresponding Synteny Block Location:", type, synChrNum, synStart, synEnd, 1 );
			writeRow( "Synteny Block Length", synBlockLength, 1, null, null );
			break;
		case "transcripts": // Generic rn5 gene transcript features
			writeRow( "Gene:", gene, 1, null, null );
			writeRow( "Transcript ID:", name, 1, URL_NCBI_NUCCORE, name );
			writeRow( "Ref Seq Status:", refSeqStatus, 1, null, null );
			writeRow( "Is Non-Coding:", isNonCoding, 1, null, null );
			break;
		case "RNAseqFeatures": // rn5 RNA-seq feature tracks
			writeRow( "Length:", end - start + " bp", 1, null, null );
			writeRow( "Name:", name.split( "_" )[ 0 ].split( "." )[ 0 ], 1, null, null );
			writeRow( "Load ID:", name + "_" + start + "_" + end, 1, null, null );
			writeRow( "Primary ID:", id, 1, null, null );
			break;
		case "dbSNP": // rn5 dbSNP feature tracks
			if( alias!=null && alias !== 'NA' ) {
				writeRow("ID:", alias, 1, URL_NCBI_SNP, alias.substring(2));
			}
			if( name!=null && name.indexOf('rs')==0 ) {
				writeRow("Accession:", name, 1, URL_NCBI_SNP, name);
			} else {
				writeRow("Accession:", name, 1, null, null);
			}
			writeRow( "Clinical Significance:", clinicalSignificance, 1, null, null );
			var snpType = testEmpty( type.split( "," )[ 1 ] );
			if( snpType!='NA' ) {
				writeRow("Type:", snpType, 1, null, null);
			}
			writeRow( "Allele:", allele, 1, null, null );
			writeRow( "Map Weight:", mapWeight, 1, null, null );
			writeRow( "Function Class:", functionClass, 1, null, null );
			break;
		case "ensemblSNP": // rn5 ensemblSNP tracks
			writeDynamicURLrow( URL_ENSEMBL_SNP, 0, "ID:", name, 1 );
			writeRow( "Strain(s):", strain, 1, null, null );
			writeRow( "Map Weight:", mapWeight, 1, null, null );
			writeRow( "Type:", testEmpty( type.split( "," )[ 1 ] ), 1, null, null );
			writeRow( "Allele:", allele, 1, null, null );
			break;
		case "microSatellite": // rn5 microsatellite tracks
			writeRow( "Name:", name.split( ":" )[ 1 ], 1, null, null );
			writeRow( "RGD Marker Report:", dbxRef_rgdID, 1, URL_RGD_MARKER, dbxRef_rgdID );
			writeRow( "Expected Size:", expectedSize, 1, null, null );
			break;
		case "diseaseOntology": // rn5 disease-related gene ontology tracks
			writeRow( "Gene Symbol:", symbol, 1, URL_RGD_GENE, dbxRef_rgdID );
			writeRow( "Gene Name:", name, 1, null, null );
			writeRow( "Gene Type:", geneType, 1, null, null );
			writeDiseaseOntologyTerms( ontologyTerms, "Disease Ontology Terms:", ",", "_", "||", "%7C%7C", URL_RGD_ONTOLOGY );
			writeRow( "Description:", note, 1, null, null );
			writeSpannedRow( "RGD Gene Report for " + symbol, 1, URL_RGD_GENE, dbxRef_rgdID );
			writeDynamicURLrow( URL_RGD_GA_TOOL, 1, "RGD Gene Annotation Analysis for " + symbol,
								dbxRef_rgdID, 1 );
			break;
		case "drugGeneOntology": // rn5 gene-chemical interaction ontology tracks
			writeRow( "Gene Symbol:", symbol, 1, URL_RGD_GENE, dbxRef_rgdID );
			writeRow( "Gene Name:", name, 1, null, null );
			writeRow( "Gene Type:", geneType, 1, null, null );
			writeDrugGeneOntologyTerms( ontologyTerms, "Drug-Gene Interaction Ontology Terms:", ",", "_",
										"%7C%7C", "||", URL_RGD_ONTOLOGY_BASE, URL_RGD_ONTOLOGY_TABLE );
			writeRow( "Description:", note, 1, null, null );
			writeSpannedRow( "RGD Gene Report for " + symbol, 1, URL_RGD_GENE, dbxRef_rgdID );
			writeDynamicURLrow( URL_RGD_GA_TOOL, 1, "RGD Gene Annotation Analysis for " + symbol,
								dbxRef_rgdID, 1 );
			break;
		case "diseaseQTLontology": // rn3.4 disease QTL ontology tracks
			writeRow( "Symbol:", symbol, 1, URL_RGD_QTL, dbxRef_rgdID );
			writeRow( "Full Name:", name, 1, null, null );
			writeRow( "LOD:", LOD, 1, null, null );
			writeRow( "p-value:", pValue, 1, null, null );
			writeDiseaseOntologyTerms( ontologyTerms, "Disease Ontology Terms:", ",", "_", "||", "%7C%7C", URL_RGD_ONTOLOGY );
			writeRelatedQTLs( relatedQTLs );
			writeRelatedFeatures( relatedStrains, "Related Strains:", ",", ":", URL_RGD_STRAIN, 1, 0 );
			writeRelatedFeatures( relatedGenes, "Candidate Genes:", ",", ":", URL_RGD_GENE, 1, 1 );
			break;
		case "diseaseStrainOntology": // rn3.4 disease strain ontology tracks
			writeRow( "RGD Rat Strain:", symbol, 1, URL_RGD_STRAIN, dbxRef_rgdID );
			writeRow( "Parent Strain:", symbolArray[ 0 ] + ")", 1, null, null );
			writeRow( "Sub-strain:", symbolArray[ 1 ], 1, null, null );
			writeDiseaseOntologyTerms( ontologyTerms, "Disease Ontology Terms:", ",", "_", "||", "%7C%7C", URL_RGD_ONTOLOGY );
			writeRow( "Description:", note, 1, null, null );
			break;
		case "entrezGene": // rn3.4 Entrez (NCBI) gene feature tracks
			writeRow( "Gene Symbol:", gene, 1, URL_RGD_GENE, dbxRef_rgdID );
			writeRow( "Description:", note, 1, null, null );
			writeRow( "RGD ID:", dbxRef_rgdID, 1, URL_RGD_GENE, dbxRef_rgdID );
			writeRow( "EntrezGene ID:", dbxRef_entrezID, 1, URL_ENTREZ_GENE, dbxRef_entrezID );
			writeRow( "MGC ID:", dbxRef_mgcID, 1, null, null );
			writeRow( "Image ID:", dbxRef_imageID, 1, null, null );
			writeSpannedRow( "RGD Gene Report for " + gene, 1, URL_RGD_GENE, dbxRef_rgdID );
			writeDynamicURLrow( URL_RGD_GA_TOOL, 1, "RGD Gene Annotation Analysis for " + gene,
								dbxRef_rgdID, 1 );
			break;
		case "entrezNonGeneFeature": // rn3.4 Entrez (NCBI) transcript tracks
			if( gene != "NA" )
			{
				if( dbxRef_rgdID != "NA" ) writeRow( "Gene Symbol:", gene, 1, URL_RGD_GENE, dbxRef_rgdID );
				else writeRow( "Gene Symbol:", gene, 1, null, null );
			}
			writeRow( "Description:", note, 1, null, null );
			if( product != "NA" ) writeRow( "Product:", product, 1, null, null );
			if( transcriptID != "NA" ) writeRow( "Transcript ID:", transcriptID, 1, null, null );
			if( proteinID != "NA" ) writeRow( "Protein ID:", proteinID, 1, null, null );
			if( codonStart != "NA" ) writeRow( "Codon start:", codonStart, 1, null, null );
			if( dbxRef_rgdID != "NA" ) writeRow( "RGD ID:", dbxRef_rgdID, 1, URL_RGD_GENE, dbxRef_rgdID );
			writeRow( "EntrezGene ID:", dbxRef_entrezID, 1, URL_ENTREZ_GENE, dbxRef_entrezID );
			if( dbxRef_giID != "NA" ) writeRow( "GI ID:", dbxRef_giID, 1, null, null );
			if( gene != "NA" && dbxRef_rgdID != "NA" )
			{
				writeSpannedRow( "RGD Gene Report for " + gene, 1, URL_RGD_GENE, dbxRef_rgdID );
				writeDynamicURLrow( URL_RGD_GA_TOOL, 1, "RGD Gene Annotation Analysis for " + gene,
									dbxRef_rgdID, 1 );
			}
			break;
		case "miRNA": // rn3.4 miRNA tracks
			writeRow( "Name:", name, 1, URL_MI_RBASE, name );
			break;
		case "EPDpromoter": // rn3.4 EPD promoter-to-gene relationship tracks
			writeRow( "Promoter Symbol:", name, 1, URL_RGD_PROMOTER, alias.split( "," )[ 0 ] );
			writeRow( "Promoter Name:", alias.split( "," )[ 1 ], 1, null, null );
			writeRow( "Promoter Type:", objectType, 1, null, null );
			writeRow( "Promoter Description:", alias.split( "," )[ 2 ], 1, null, null );
			writeRow( "Promoter Regulation:", regulation, 1, null, null );
			writeRow( "Description:", note.replace( "->", " --> " ), 1, null, null );
			writeRow( "Experiment Methods:", experimentMethods, 1, null, null );
			writeTissueDensities( "Tissues:", "ChIP-seq Density:", tissues, densities );
			writePromoterGeneRelation( promoterGeneRlt, "Promoter-to-Gene Relation:", ",", "_" );
			break;
		case "methylation": // rn3.4 Beutler Lab methylation tracks
			writeRow( "Score:", score, 1, null, null );
			writeRow( "Name:", name, 1, null, null );
			writeRow( "Alias:", alias, 1, null, null );
			writeRow( "Primary ID:", id, 1, null, null );
			break;
		case "indelHubrecht": // rn3.4 Indel feature data tracks from the Hubrecht Institute
			writeRow( "Variant ID:", alias, 1, null, null );
			writeRow( "Variant type:", variantType, 1, null, null );
			writeRow( "Reference:", referenceSeq, 1, null, null );
			writeRow( "Strain:", strain, 1, null, null );
			writeRow( "Filtered depth:", infoDP, 1, null, null );
			writeTableBreaks( 1 );
			writeVariantCallAnalysis( variantSeq, infoAC, "Variant call analysis:", "Variant sequence",
										"Variant allele count (in genotypes)" );
			break;
		case "indelICL": // rn3.4 Indel feature data tracks from the Imperial College of London (ICL)
			writeRow( "Variant ID:", alias, 1, null, null );
			writeRow( "Variant type:", variantType, 1, null, null );
			writeRow( "Reference:", referenceSeq, 1, null, null );
			writeRow( "Strain:", strain, 1, null, null );
			writeRow( "Read Depth (only filtered reads used for calling):", formatDP, 1, null, null );
			writeTableBreaks( 1 );
			writeICL_allelicDepth( variantSeq, formatAD, formatGT, formatGQ,
									"Allelic depths for variants/reference at this position:",
									"Variant sequence", "Variant allelic depth" );
			writeTableBreaks( 1 );
			writeSpannedRow( "Normalized, phred-scaled likelihoods for AA, AB, BB genotypes where A = ref"
							+ " and B = alt (not applicable if site is not bi-allelic):", 1, null, null );
			writeRow( "Homozygous ref (0/0):", formatPL.split( "," )[ 0 ], 0, null, null );
			writeRow( "Heterozygous (0/1):", formatPL.split( "," )[ 1 ], 0, null, null );
			writeRow( "Homozygous var (1/1):", formatPL.split( "," )[ 2 ], 0, null, null );
			writeTableBreaks( 1 );
			writeSpannedRow( "Variant call analysis:", 1, null, null );
			writeRow( "Allele balance for hets (ref / (ref + alt)):", infoAB, 0, null, null );
			writeRow( "Allele count (in genotypes):", infoAC, 0, null, null );
			writeRow( "Allele frequency:", infoAF, 0, null, null );
			writeRow( "Total allele number (in called genotypes):", infoAN, 0, null, null );
			writeRow( "Z-score from Wilcoxon rank sum test of Alt vs. Ref base qualities:",
						infoBaseQRankSum, 0, null, null );
			writeRow( "Filtered depth:", infoDP, 0, null, null );
			writeRow( "Phred-scaled p-value using Fisher's exact test to detect strand bias:",
						infoFS, 0, null, null );
			writeRow( "Site consistency (with at most two segregating haplotypes):",
						infoHaplotypeScore, 0, null, null );
			writeRow( "RMS mapping quality:", infoMQ, 0, null, null );
			writeRow( "Variant confidence/quality (by depth):", infoQD, 0, null, null );
			writeRow( "Z-score from Wilcoxon rank sum test of Alt vs. Ref read position bias:",
						infoReadPosRankSum, 0, null, null );
			writeRow( "Strand bias:", infoSB, 0, null, null );
			break;
		case "physGenStrains": // rn3.4 PhysGen mutant strains feature data tracks
			writeRow( "Gene Name:", alias.split( ":" )[ 1 ], 1, null, null );
			writeRow( "Strain:", name, 1, null, null );
			writeRow( "RGD Strain ID:", rgdID2, 1, URL_RGD_STRAIN, rgdID2 );
			break;
		case "misassembly": // rn3.4 Hubrecht Institute misassemblies track
			writeRow( "Type:", type.split( "," )[ 1 ], 1, null, null );
			writeRow( "Method:", method, 1, null, null );
			writeRow( "Reference:", reference, 1, null, null );
			break;
		case "CNV": // rn3.4 Hubrecht Institute CNVs track
			writeRow( "Type:", type.split( "," )[ 1 ], 1, null, null );
			writeRow( "Method:", method, 1, null, null );
			writeRow( "Strain:", strain, 1, null, null );
			writeRow( "CNV ID:", dbxRef.split( "_" )[ 1 ], 1, null, null );
			break;
		case "1000Genomes": // hg18 1000 Genomes variant track
			writeRow( "ID:", id, 1, null, null );
			writeRow( "Variant:", variantSeq, 1, null, null );
			writeRow( "Reference:", referenceSeq, 1, null, null );
			break;
		default: // rn5 generic gene features (example: from "rn5.gff3")
			writeRow( "Gene Symbol:", name, 1, URL_RGD_GENE, alias_rgdID );
			writeRow( "Gene Name:", fullName, 1, null, null );
			writeRow( "Gene Type:", geneType, 1, null, null );
			writeRow( "Ref Seq Status:", refSeqStatus, 1, null, null );
			writeRow( "Species:", species, 1, null, null );
			writeRow( "Description:", note, 1, null, null );
			writeSpannedRow( "RGD Gene Report for " + name, 1, URL_RGD_GENE, alias_rgdID );
			writeDynamicURLrow( URL_RGD_GA_TOOL, 1, "RGD Gene Annotation Analysis for " + name,
								alias_rgdID, 1 );
			writeTableBreaks( 1 );
			writeDBXrefs( dbxRef );
			break;
	}

	document.write( "</table>" );
	resize_iFrame();

</script>

<style type="text/css">
	table { width: 400px; font-size: 14px; font-family: "Lucida", Serif; }
	td { padding: 5px; }
	tr:hover { background-color: skyblue; }
</style>

<%--
	LinkedHashMap<String,String> nameMap = new LinkedHashMap();
	nameMap.put("fullName", "Full Name");
	nameMap.put("source", "Source");
	nameMap.put("type", "Class");
	nameMap.put("seq_id", "Genome Location (Chr:Start..Stop)");
	nameMap.put("name", "Gene Name");
	nameMap.put("refSeqStatus", "Ref Seq Status");
	nameMap.put("species", "Species");
	nameMap.put("note", "Description");
	nameMap.put("id", "The");

	HashMap<String, String> linkMap = new HashMap();
	linkMap.put("name","http://rgd.mcw.edu/rgdweb/report/gene/main.html?id=" + request.getParameter("id"));
	linkMap.put("type", "http://www.yahoo.com");

	HashMap<String, String> override = new HashMap();
	override.put("seq_id", request.getParameter("seq_id") + "." + request.getParameter("start") + ".." + request.getParameter("end"));
--%>

<%--
	<table cellspacing="0" cellpadding="0">
	<% for (Map.Entry<String,String> entry: nameMap.entrySet()) { %>
		<% if ((request.getParameter(entry.getKey()) != null && !request.getParameter(entry.getKey()).equals("")) || override.containsKey(entry.getKey())) { %>
			<tr>
				<td><%=entry.getValue()%></td>
				<td>
					<% if (linkMap.containsKey(entry.getKey())) { %>
						<a href="<%=linkMap.get(entry.getKey())%>">
					<% } %>
						<% if (override.containsKey(entry.getKey())) { %>
							<%=override.get(entry.getKey())%>
						<% }else { %>
							<%=request.getParameter(entry.getKey())%>
						<% } %>
					<% if (linkMap.containsKey(entry.getKey())) { %>
						<a href="<%=linkMap.get(entry.getKey())%>">
					<% } %>
				</td>
			</tr>
		<% } %>
	<% } %>
	</table>
--%>
