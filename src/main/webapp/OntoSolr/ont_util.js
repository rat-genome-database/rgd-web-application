function getOntTerms(IdStr, termField) {
   var Ids = IdStr.split('|');
    var result = [];
    $.each(Ids, function(i, value) {
            if ( $.trim(value) )
                    result[i] = '"' + value + '"^'+(Ids.length-i);
    });
    var qValue = result.join(' ');
    var qURL = "https://ontomate.rgd.mcw.edu/OntoSolr/select?q=id:("+qValue+")&wt=velocity&v.template=termsstring&v.contentType=text/html;charset=UTF-8";
    $.ajaxSetup ({
         cache: false
     });
    $(termField).val("");
if(typeof String.prototype.trim !== 'function') {
  String.prototype.trim = function() {
    return this.replace(/^\s\s*/, '').replace(/\s\s*$/, ''); 
  }
}
    $.get(qURL, {}, function(data){$(termField).val(data.trim());});
}
