/**
 * Reusable ontology term autocomplete component.
 * Queries Elasticsearch via /rgdweb/ontology/autocomplete.html
 *
 * Usage:
 *   setupOntologyAutocomplete('#myInput', 'RDO', {
 *       accIdField: '#myHiddenAccId',
 *       onSelect: function(termName, accId) { ... },
 *       max: 20
 *   });
 *
 * @param {string|HTMLElement} input - selector or element for the text input
 * @param {string} ont - ontology prefix (RDO, GO, MP, PW, CHEBI, VT, HP, RS, CMO, MMO, XCO, EFO, BP, MF, CC)
 * @param {object} options
 *   - accIdField {string} selector for hidden input to receive the accession ID
 *   - onSelect {function(termName, accId)} callback when a term is selected
 *   - max {number} max results (default 20)
 *   - minChars {number} min chars before searching (default 2)
 *   - delay {number} debounce delay in ms (default 300)
 *   - annotationCheck {boolean|function} when truthy, after each search the
 *       autocomplete asks /rgdweb/gviewer/termCounts.html for the unique-
 *       object count for each term in the dropdown; terms with zero count
 *       are greyed out and a banner is shown when none have annotations.
 *       Pass a function returning the mapKey, or true to read the value
 *       of #assemblyVersion at search time. Direct counts only — descendant
 *       expansion via the ontology DAG is not considered here.
 */
function setupOntologyAutocomplete(input, ont, options) {
    options = options || {};
    var max = options.max || 20;
    var minChars = options.minChars || 2;
    var delay = options.delay || 300;

    var jq = (typeof jQuery !== 'undefined') ? jQuery :
             (typeof jq14 !== 'undefined') ? jq14 :
             (typeof jQuery_1_3_2 !== 'undefined') ? jQuery_1_3_2 :
             (typeof $ !== 'undefined') ? $ : null;

    if (!jq) return;

    var $input = jq(input);
    var timer = null;
    var $dropdown = null;
    var selectedIndex = -1;
    var currentResults = [];

    function createDropdown() {
        if ($dropdown) $dropdown.remove();
        $dropdown = jq('<div class="ont-ac-results"></div>');
        $dropdown.css({
            position: 'absolute',
            zIndex: 99999,
            background: '#fff',
            border: '1px solid #ccc',
            borderTop: 'none',
            maxHeight: '300px',
            overflowY: 'auto',
            display: 'none',
            boxShadow: '0 2px 6px rgba(0,0,0,0.15)',
            borderRadius: '0 0 4px 4px'
        });
        jq('body').append($dropdown);
        positionDropdown();
        return $dropdown;
    }

    function positionDropdown() {
        if (!$dropdown) return;
        var offset = $input.offset();
        $dropdown.css({
            left: offset.left + 'px',
            top: (offset.top + $input.outerHeight()) + 'px',
            width: $input.outerWidth() + 'px'
        });
    }

    function hideDropdown() {
        if ($dropdown) $dropdown.hide();
        selectedIndex = -1;
    }

    function getMapKeyForCheck() {
        if (!options.annotationCheck) return null;
        if (typeof options.annotationCheck === 'function') {
            try { return options.annotationCheck(); } catch (e) { return null; }
        }
        var el = document.getElementById('assemblyVersion');
        return el ? el.value : null;
    }

    function showResults(results) {
        currentResults = results;
        selectedIndex = -1;
        if (!$dropdown) createDropdown();
        $dropdown.empty();

        if (results.length === 0) {
            hideDropdown();
            return;
        }

        for (var i = 0; i < results.length; i++) {
            (function(idx) {
                var item = jq('<div class="ont-ac-item"></div>');
                var label = jq('<span class="ont-ac-label"></span>').text(
                    results[idx].term + ' (' + results[idx].accId + ')');
                var count = jq('<span class="ont-ac-count"></span>').css({
                    float: 'right',
                    color: '#888',
                    fontSize: '12px',
                    marginLeft: '8px'
                });
                item.append(label).append(count);
                item.css({
                    padding: '6px 10px',
                    cursor: 'pointer',
                    fontSize: '13px',
                    borderBottom: '1px solid #f0f0f0'
                });
                item.on('mouseenter', function() {
                    jq('.ont-ac-item', $dropdown).css('background', '#fff');
                    jq(this).css('background', '#e8f0fe');
                    selectedIndex = idx;
                });
                item.on('mouseleave', function() {
                    jq(this).css('background', '#fff');
                });
                item.on('mousedown', function(e) {
                    e.preventDefault();
                    selectItem(idx);
                });
                $dropdown.append(item);
            })(i);
        }

        positionDropdown();
        $dropdown.show();

        var mapKey = getMapKeyForCheck();
        if (mapKey) {
            applyAnnotationCounts(results, mapKey);
        }
    }

    function applyAnnotationCounts(results, mapKey) {
        var accs = [];
        for (var i = 0; i < results.length; i++) accs.push(results[i].accId);
        if (!accs.length) return;

        jq.ajax({
            url: '/rgdweb/gviewer/termCounts.html',
            data: { accs: accs.join(','), mapKey: mapKey },
            dataType: 'json',
            success: function(counts) {
                if (!$dropdown || !$dropdown.is(':visible')) return;

                // Drop unannotated terms from both the DOM and the
                // currentResults array so keyboard navigation and the
                // blur auto-select keep working with the filtered list.
                var kept = [];
                jq('.ont-ac-item', $dropdown).each(function(idx) {
                    var acc = results[idx] ? results[idx].accId : null;
                    var n = (acc && counts && (acc in counts)) ? counts[acc] : 0;
                    if (n > 0) {
                        kept.push(results[idx]);
                        jq(this).find('.ont-ac-count').text(n).css('color', '#2c3e50');
                    } else {
                        jq(this).remove();
                    }
                });

                currentResults = kept;
                selectedIndex = -1;

                // Re-bind item indices since DOM nodes were removed.
                jq('.ont-ac-item', $dropdown).each(function(newIdx) {
                    var $row = jq(this);
                    $row.off('mouseenter mouseleave mousedown');
                    $row.on('mouseenter', function() {
                        jq('.ont-ac-item', $dropdown).css('background', '#fff');
                        jq(this).css('background', '#e8f0fe');
                        selectedIndex = newIdx;
                    });
                    $row.on('mouseleave', function() {
                        jq(this).css('background', '#fff');
                    });
                    $row.on('mousedown', function(e) {
                        e.preventDefault();
                        selectItem(newIdx);
                    });
                });

                renderEmptyBanner(kept.length === 0);
            }
        });
    }

    function renderEmptyBanner(show) {
        if (!$dropdown) return;
        $dropdown.find('.ont-ac-banner').remove();
        if (!show) return;
        var banner = jq('<div class="ont-ac-banner"></div>')
            .text('No annotations for any matching term on this assembly')
            .css({
                padding: '6px 10px',
                fontSize: '12px',
                color: '#8a6d3b',
                background: '#fcf8e3',
                borderBottom: '1px solid #faebcc'
            });
        $dropdown.prepend(banner);
    }

    function selectItem(idx) {
        var result = currentResults[idx];
        if (!result) return;

        $input.val(result.term);

        if (options.accIdField) {
            var accField = document.querySelector(options.accIdField);
            if (accField) accField.value = result.accId;
        }

        if (typeof options.onSelect === 'function') {
            options.onSelect(result.term, result.accId);
        }

        hideDropdown();
    }

    function doSearch(term) {
        jq.ajax({
            url: '/rgdweb/ontology/autocomplete.html',
            data: { term: term, ont: ont, max: max },
            dataType: 'text',
            success: function(data) {
                var results = [];
                var lines = data.split('\n');
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line) {
                        var parts = line.split('|');
                        if (parts.length >= 2) {
                            results.push({ term: parts[0], accId: parts[1] });
                        }
                    }
                }
                showResults(results);
            }
        });
    }

    $input.on('input', function() {
        var val = $input.val().trim();
        if (timer) clearTimeout(timer);
        if (val.length < minChars) {
            hideDropdown();
            return;
        }
        timer = setTimeout(function() {
            doSearch(val);
        }, delay);
    });

    $input.on('keydown', function(e) {
        if (!$dropdown || !$dropdown.is(':visible')) return;

        var items = jq('.ont-ac-item', $dropdown);
        if (e.keyCode === 40) { // down
            e.preventDefault();
            selectedIndex = Math.min(selectedIndex + 1, currentResults.length - 1);
            items.css('background', '#fff');
            items.eq(selectedIndex).css('background', '#e8f0fe');
        } else if (e.keyCode === 38) { // up
            e.preventDefault();
            selectedIndex = Math.max(selectedIndex - 1, 0);
            items.css('background', '#fff');
            items.eq(selectedIndex).css('background', '#e8f0fe');
        } else if (e.keyCode === 13 || e.keyCode === 9) { // enter or tab
            if (selectedIndex >= 0) {
                e.preventDefault();
                selectItem(selectedIndex);
            }
        } else if (e.keyCode === 27) { // escape
            hideDropdown();
        }
    });

    $input.on('blur', function() {
        setTimeout(function() {
            // Auto-select the top result if input text matches
            if (currentResults.length > 0 && $input.val().trim()) {
                var inputVal = $input.val().trim().toLowerCase();
                var accField = options.accIdField ? document.querySelector(options.accIdField) : null;
                var alreadySelected = accField && accField.value;

                if (!alreadySelected) {
                    // Check for exact match first, then fall back to top result
                    var bestMatch = 0;
                    for (var i = 0; i < currentResults.length; i++) {
                        if (currentResults[i].term.toLowerCase() === inputVal) {
                            bestMatch = i;
                            break;
                        }
                    }
                    selectItem(bestMatch);
                }
            }
            hideDropdown();
        }, 200);
    });

    // Return control object for changing ontology dynamically
    return {
        setOntology: function(newOnt) {
            ont = newOnt;
        },
        destroy: function() {
            if ($dropdown) $dropdown.remove();
            $input.off('input keydown blur');
            if (timer) clearTimeout(timer);
        }
    };
}
