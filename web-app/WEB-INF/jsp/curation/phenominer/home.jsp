<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Experiment" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>
<%@ page import="edu.mcw.rgd.datamodel.Transcript" %>
<%@ page import="edu.mcw.rgd.datamodel.TranscriptFeature" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>


<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";


%>


<%@ include file="editHeader.jsp"%>


<span class="phenominerPageHeader">Phenominer Curation</span>
<br><br>

<table>
    <tr>
        <td><a href="studies.html?act=new"><li>Create a New Study</a> </td>
    </tr>
    <tr>
        <td><a href="studies.html"><li>View All Studies</a> </td>
    </tr>
    <tr>
        <td><a href="search.html"><li>Search Phenominer</a> </td>
    </tr>
    <tr>
        <td><a href="pgaload.html"><li>PGA Load</a> </td>
    </tr>
</table>


<%
if (req.getParameter("fix").equals("1")) {

    try{

    dao = new PhenominerDAO();
    List<Study> sList = dao.getStudies();

    for (Study s: sList) {
        List<Experiment> eList = dao.getExperiments(s.getId());

        for (Experiment e: eList) {
            List<Record> rList = dao.getRecords(e.getId());
            for (Record r: rList) {
                r.getClinicalMeasurement().setAccId(Ontology.formatId(r.getClinicalMeasurement().getAccId()));
                r.getSample().setStrainAccId(Ontology.formatId(r.getSample().getStrainAccId()));
                r.getMeasurementMethod().setAccId(Ontology.formatId(r.getMeasurementMethod().getAccId()));

                for (Condition c: r.getConditions()) {
                    c.setOntologyId(Ontology.formatId(c.getOntologyId()));
                }

                dao.updateRecord(r);
            }


        }
    }
    

    }catch (Exception e) {
        e.printStackTrace();
    }
}
%>


<%

/*
     if (strand != null && strand == "-") {
    logFile << "Switching UTrs as we're dealing with - strand ... \n"
    Feature temp = threeUtr
    threeUtr = fiveUtr
    fiveUtr = temp
  }

  // OK we' have a variant in an Exom  for only plus stranded genes !!!!!!
  for (Feature feature: exomsArray) {

    // if we have a 3'utr to deal with  at end
    if (threeUtr != null) {
      //  println  "comparing 3prime: " <<  threeUtr.start << "," << threeUtr.stop << " feature: " <<  feature.start << ", " << feature.stop
      if (feature.stop < threeUtr.start) {
        // use entire feature
      } else if (feature.start < threeUtr.start) {
        logFile << "feature start reset to " << threeUtr.start - 1 << "\n"
        feature.stop = threeUtr.start - 1
      } else {
        // remove all of exome
        logFile << "3Prime removed  feature \n"
        feature.start = -1
        feature.stop = -1
      }
    }
    // if we have a 5' utr to deal with at start
    if (fiveUtr != null) {
      // println  "comparing 5prime: " <<  fiveUtr.start << "," << fiveUtr.stop << " feature: " <<  feature.start << ", " << feature.stop
      if (feature.start > fiveUtr.stop) {
        // use entire feature
      } else if (feature.stop > fiveUtr.stop) {
        logFile << "feature stop reset to " << fiveUtr.stop + 1 << "\n"
        feature.start = fiveUtr.stop + 1
      } else {
        // remove all of exome
        logFile << "5Prime removed feature" << "\n"
        feature.start = -1
        feature.stop = -1
      }
    }
     */

  /*
    GeneDAO gdao = new edu.mcw.rgd.dao.impl.GeneDAO();
    TranscriptDAO tdao = new TranscriptDAO();
    List<Transcript> tList = tdao.getTranscripts(13);
   List<Transcript> tList = tdao.getTranscriptsForGene(1347773);


    boolean debug = false;
    int count0 = 0;
    int count1 = 0;
    int count2=0;

    for (Transcript t: tList) {

         List<TranscriptFeature> tfList = tdao.getFeatures(t.getRgdId(), TranscriptFeature.FeatureType.EXON);
         int len = 0;

        List<TranscriptFeature> utr5 = tdao.getFeatures(t.getRgdId(), TranscriptFeature.FeatureType.UTR5);
        List<TranscriptFeature> utr3 = tdao.getFeatures(t.getRgdId(), TranscriptFeature.FeatureType.UTR3);
        TranscriptFeature u5=null;
        TranscriptFeature u3=null;

        if (utr5.size() > 0 ) {
            if (utr5.get(0).getStrand().equals("+")) {
                u5 = utr5.get(0);
            }else {
                u3 = utr5.get(0);
            }
        }

        if (utr3.size() > 0 ) {
            if (utr3.get(0).getStrand().equals("+")) {
                u3 = utr3.get(0);
            }else {
                u5 = utr3.get(0);
            }
        }

      if (debug) {
        if (u5 != null) {
            out.print("<br>u5:" + u5.getStartPos() + " : " + u5.getStopPos());
        }

        if (u3 != null) {
            out.print("<br>u3:" + u3.getStartPos() + " : " + u3.getStopPos());
        }
      }

        for (TranscriptFeature tf: tfList) {

            int start = tf.getStartPos();
            int stop = tf.getStopPos();

          if (debug)  out.print("<br><span style='color:black;'>'ex-" + start + " : " + stop + "</span>");

            boolean skip = false;
            boolean adjust = false;

            if (u5 != null) {
                if (tf.getStartPos() > u5.getStopPos()) {
                    //use entire feature
                }else if (tf.getStopPos() > u5.getStopPos())  {
                        start = u5.getStopPos() + 1;
                if (debug)     out.print("<br><span style='color:blue;'>ex-" + start + " : " + stop + "</span>");
                } else {
                   skip=true;
             if (debug)        out.print("<br><span style='color:red;'>ex-" + start + " : " + stop + "</span>");

                }
            }

            if (u3 != null) {
                if (tf.getStopPos() < u3.getStartPos()) {
                    //use entire feature
                }else if (tf.getStartPos() < u3.getStartPos())  {
                        stop = u3.getStartPos() - 1;
               if (debug)     out.print("<br><span style='color:blue;'>ex-" + start + " : " + stop + "</span>");
                } else {
                    skip=true;
                if (debug)     out.print("<br><span style='color:red;'>ex-" + start + " : " + stop + "</span>");
                }
            }



            if (! skip) {
                len = len + stop - start + 1;
            }    

        }

       if ((len % 3) == 0) {
            count0++;
        }else if ((len % 3) == 1) {
            count1++;
            Gene gene = gdao.getGene(t.getGeneRgdId());
            out.print("<br>Gene:" + gene.getSymbol() + ":TranId:" + t.getAccId() + ":TranId:" + t.getRgdId() + ":GeneRGDId" + t.getGeneRgdId() + " ListSize " + tList.size());
        }else if ((len % 3) == 2) {
            count2++;
           Gene gene = gdao.getGene(t.getGeneRgdId());
           out.print("<br>Gene:" + gene.getSymbol() + ":TranId:" + t.getAccId() + ":TranId:" + t.getRgdId() + ":GeneRGDId" + t.getGeneRgdId() + " ListSize " + tList.size());
        }


    }

    out.print("<br>0: " + count0 + "<br>1: " + count1 + "<br>2:" + count2);
    */
%>


<%@ include file="editFooter.jsp"%>