package edu.mcw.rgd.report.GenomeModel;

import edu.mcw.rgd.dao.impl.XdbIdDAO;


/**
 * Created by jthota on 12/13/2017.
 */
public class ExternalDBLinks {
  public  ExternalDbs getXLinks(int mapKey, String chr, String locus) throws Exception {
      ExternalDbs xdbs= new ExternalDbs();
      XdbIdDAO xdbIdDAO= new XdbIdDAO();
      String ncbinuccore=xdbIdDAO.getXdbUrlnoSpecies(1);
      String ncbiGenomeURL=xdbIdDAO.getXdbUrlnoSpecies(61);
      String ncbiAssemblyURL=xdbIdDAO.getXdbUrlnoSpecies(57);
      String ucscURL="https://genome.ucsc.edu/cgi-bin/hgGateway?db=" ;
      String ucscTracksURL="https://genome.ucsc.edu/cgi-bin/hgTracks?lastVirtModeType=default&virtModeType=default&virtMode=0&db=";

/************************************************RAT********************************************/
      if(mapKey==372){
          if(chr==null) {
              xdbs.setNcbiGenome(ncbiGenomeURL+"?term=mRatBN7.2");
              xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_015227675.2");
              xdbs.setUcsc(ucscURL+"rn7");
              xdbs.setEnsembl("http://www.ensembl.org/Rattus_norvegicus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://www.ensembl.org/Rattus_norvegicus/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"rn6"+"&position=chr"+chr);
          }
      }
      if(mapKey==360){
          if(chr==null) {
          xdbs.setNcbiGenome(ncbiGenomeURL+"?term=Rnor_6.0");
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000001895.5");
          xdbs.setUcsc(ucscURL+"rn6");
          xdbs.setEnsembl("http://www.ensembl.org/Rattus_norvegicus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://www.ensembl.org/Rattus_norvegicus/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"rn6"+"&position=chr"+chr);
      }
      }
      if(mapKey==70){
          if(chr==null) {
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000001895.4");
          xdbs.setUcsc(ucscURL+"rn5");
          xdbs.setEnsembl("http://mar2015.archive.ensembl.org/Rattus_norvegicus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://mar2015.archive.ensembl.org/Rattus_norvegicus/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"rn5"+"&position=chr"+chr);
      }
      }
      if(mapKey==60){
          if(chr==null) {
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000001895.3");
          xdbs.setUcsc(ucscURL+"rn4");
          xdbs.setEnsembl("http://may2012.archive.ensembl.org/Rattus_norvegicus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://may2012.archive.ensembl.org/Rattus_norvegicus/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"rn4"+"&position=chr"+chr);
      }
      }
      /*****************************HUMAN*****************************************************/
      if(mapKey==38){
          if(chr==null) {
          xdbs.setNcbiGenome(ncbiGenomeURL+"?term=GRCh38.p11");
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000001405.26");
          xdbs.setUcsc(ucscURL+"hg38");
          xdbs.setEnsembl("http://www.ensembl.org/Homo_sapiens/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://www.ensembl.org/Homo_sapiens/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"hg38"+"&position=chr"+chr);
      }
      }
      if(mapKey==17){
          if(chr==null) {
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000001405.25");
          xdbs.setUcsc(ucscURL+"hg19");
          xdbs.setEnsembl("http://grch37.ensembl.org/Homo_sapiens/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://grch37.ensembl.org/Homo_sapiens/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"hg19"+"&position=chr"+chr);
      }
      }
      if(mapKey==13){
          if(chr==null) {
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000001405.12");
          xdbs.setUcsc(ucscURL+"hg18");
          xdbs.setEnsembl("http://may2009.archive.ensembl.org/Homo_sapiens/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://may2009.archive.ensembl.org/Homo_sapiens/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"hg18"+"&position=chr"+chr);
      }
      }
      /******************************MOUSE**************************************************/
      if(mapKey==35){
          if(chr==null) {
          xdbs.setNcbiGenome(ncbiGenomeURL+"?term=GRCm38");
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000001635.26");
          xdbs.setUcsc(ucscURL+"mm10");
          xdbs.setEnsembl("http://www.ensembl.org/Mus_musculus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://www.ensembl.org/Mus_musculus/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"mm10"+"&position=chr"+chr);
      }
      }
      if(mapKey==18){
          if(chr==null) {
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000001635.18");
          xdbs.setUcsc(ucscURL+"mm9");
          xdbs.setEnsembl("http://may2012.archive.ensembl.org/Mus_musculus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://may2012.archive.ensembl.org/Mus_musculus/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"mm9"+"&position=chr"+chr);
      }
      }
      if(mapKey==14){
          if(chr==null) {
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000001635.18");
          xdbs.setUcsc(ucscURL+"mm8");
          xdbs.setEnsembl("http://may2009.archive.ensembl.org/Mus_musculus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://may2009.archive.ensembl.org/Mus_musculus/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"mm8"+"&position=chr"+chr);
      }
      }
      /********************************************CHINCHILLA***********************************/
      if(mapKey==44){   //Chinchilla
          if(chr==null) {
          xdbs.setNcbiGenome(ncbiGenomeURL+"?term=Chinchilla ChiLan1.0");
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000276665.1");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);

      }

      }
      if(mapKey==720){  //Squirrel
          if(chr==null) {
          xdbs.setNcbiGenome(ncbiGenomeURL+"?term=Squirrel SpeTri2.0");
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000236235.1");
          xdbs.setUcsc(ucscURL+"speTri2");
          xdbs.setEnsembl("http://www.ensembl.org/Ictidomys_tridecemlineatus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://www.ensembl.org/Ictidomys_tridecemlineatus/Location/View?r=JH393314.1:13,184,404-13,354,375");
              xdbs.setUcsc(ucscTracksURL+"speTri2"+"&position=chr"+chr);
      }
      }
      if(mapKey==631){  //Dog
          if(chr==null) {
          xdbs.setNcbiGenome(ncbiGenomeURL+"?term=Dog CanFam3.1");
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000002285.3");
         xdbs.setUcsc(ucscURL+"canFam3");
          xdbs.setEnsembl("http://www.ensembl.org/Canis_familiaris/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://www.ensembl.org/Canis_familiaris/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"canFam3"+"&position=chr"+chr);
      }
      }
      if(mapKey==511){  //Bonobo
          if(chr==null) {
          xdbs.setNcbiGenome(ncbiGenomeURL+"?term=Bonobo PanPan1.1");
          xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000258655.2");
          xdbs.setUcsc(ucscURL+"panPan1");
          xdbs.setEnsembl("http://www.ensembl.org/Pan_paniscus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://www.ensembl.org/Pan_paniscus/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"panPan1"+"&position=chr"+chr);
      }
      }
      if(mapKey==513){  //Bonobo
          if(chr==null) {
              xdbs.setNcbiGenome(ncbiGenomeURL+"?term=Bonobo Mhudiblu_PPA");
              xdbs.setNcbiAssembly(ncbiAssemblyURL +
                      "GCF_013052645.1");
              xdbs.setUcsc(ucscURL+"panPan3");
              xdbs.setEnsembl("http://www.ensembl.org/Pan_paniscus/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://www.ensembl.org/Pan_paniscus/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"panPan3"+"&position=chr"+chr);
          }
      }

      if(mapKey==911){  //pig
          if(chr==null) {
              xdbs.setNcbiGenome(ncbiGenomeURL+"?term=Pig Sscrofa11.1");
              xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000003025.6");
              xdbs.setUcsc(ucscURL+"susScr11");
              xdbs.setEnsembl("http://www.ensembl.org/Sus_scrofa/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("http://www.ensembl.org/Sus_scrofa/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"susScr11"+"&position=chr"+chr);
          }
      }
      if(mapKey==910){  //pig
          if(chr==null) {
              xdbs.setNcbiGenome(ncbiGenomeURL+"?term=Pig Sscrofa10.2");
              xdbs.setNcbiAssembly(ncbiAssemblyURL+"GCF_000003025.5");
              xdbs.setUcsc(ucscURL+"susScr3");
              xdbs.setEnsembl("https://may2017.archive.ensembl.org/Sus_scrofa/Info/Index");
          }else{
              xdbs.setNcbiChr(ncbinuccore+locus);
              xdbs.setEnsembl("https://may2017.archive.ensembl.org/Sus_scrofa/Location/Chromosome?r="+chr);
              xdbs.setUcsc(ucscTracksURL+"susScr3"+"&position=chr"+chr);
          }
      }
      return xdbs;
  }

}
