package edu.mcw.rgd.report.GenomeModel;

/**
 * Created by jthota on 12/14/2017.
 */
public class ExternalDbs {

        private String ncbiGenome;
        private String ensembl;
        private String ucsc;
        private String ncbiAssembly;
        private String ncbiChr;

    public String getNcbiChr() {
        return ncbiChr;
    }

    public void setNcbiChr(String ncbiChr) {
        this.ncbiChr = ncbiChr;
    }

        public String getNcbiGenome() {
            return ncbiGenome;
        }

        public void setNcbiGenome(String ncbiGenome) {
            this.ncbiGenome = ncbiGenome;
        }

    public String getNcbiAssembly() {
        return ncbiAssembly;
    }

    public void setNcbiAssembly(String ncbiAssembly) {
        this.ncbiAssembly = ncbiAssembly;
    }

    public String getEnsembl() {
        return ensembl;
    }

    public void setEnsembl(String ensembl) {
        this.ensembl = ensembl;
    }

    public String getUcsc() {
            return ucsc;
        }

        public void setUcsc(String ucsc) {
            this.ucsc = ucsc;
        }
    }
