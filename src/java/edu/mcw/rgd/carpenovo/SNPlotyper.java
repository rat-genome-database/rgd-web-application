package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.mapping.MapManager;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.math.BigDecimal;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 9/14/12
 * Time: 11:48 AM
 */
public class SNPlotyper {

    protected final Log logger = LogFactory.getLog(getClass());

    TreeMap<Long, List<VariantResult>> genome = new TreeMap<>();
    HashMap<Long, String> ref = new HashMap();
    TreeMap<Integer,TreeMap<Long,List<VariantResult>>> samples = new TreeMap();
    List<VariantResult> variants = new ArrayList();
    HashMap<Long,BigDecimal> conScore = new HashMap();
    List<MappedGene> genes = new ArrayList();
    TreeMap<Long, Boolean> exons = new TreeMap<>();
    List<Integer> sampleIds = new ArrayList<>();


    public void addGeneMappings(List<MappedGene> geneMappings) {
        this.genes = geneMappings;
    }

    public void addExons(List<MapData> mapData) {
        //if there are not any exons.  set them all to false.
        if (mapData == null || mapData.size() == 0) {
            for (Long pos: genome.keySet()) {
                this.exons.put(pos, false);
            }
            return;
        }

        Iterator posIt = genome.keySet().iterator();
        Iterator mdIt = mapData.iterator();

        MapData md = (MapData) mdIt.next();
        Long pos = null;

        boolean next = true;
        while (posIt.hasNext() || !next) {

             if (next) {
                 pos= (Long) posIt.next();
             }

             if (pos < md.getStartPos()) {
                this.exons.put(pos, false);
                next=true;
             }else if (pos >= md.getStartPos() && pos <= md.getStopPos()) {
                 this.exons.put(pos, true);
                 next=true;
             }else {
                 if (mdIt.hasNext()) {
                     md = (MapData) mdIt.next();
                     next=false;
                 }else {
                     this.exons.put(pos, false);
                     next =true;
                 }
             }
        }
    }

    public boolean isInExon(long position) {
        return (Boolean) this.exons.get(position);
    }


    /*
    Returns the number of positions covered by this gene that have variants
     */
    public int getVariantSpan(int rgdId) {

        int count=0;
        for (MappedGene mg: genes) {
             if (mg.getGene().getRgdId() == rgdId) {
                 Iterator it = genome.keySet().iterator();
                 while (it.hasNext()) {
                     Long pos = (Long) it.next();
                     if (pos >= mg.getStart() && pos <= mg.getStop()) {
                        count++;
                     }else {
                         if (count > 0) {
                             return count;
                         }
                     }

                 }

             }
        }
        return count;
    }

    public String getCommaDelimitedGeneSymbolList() {

        String gList = "";
        for (MappedGene mg: genes) {
            if (gList.equals("")) {
                gList += mg.getGene().getSymbol();
            }else {
                gList += "," + mg.getGene().getSymbol();
            }

        }
        return gList;
    }

    public edu.mcw.rgd.datamodel.Gene getGene(long position) {

        for (MappedGene mg: genes) {
            if (position >= mg.getStart() && position <=mg.getStop()) {
                return mg.getGene();
            }
        }
        return null;
    }

    public boolean hasPlusStrandConflict() throws Exception {
        for (Long pos: getPositions()) {
            if (getPlusStrandGene(pos).size() > 1) {
                return true;
            }
        }
        return false;
    }

    public boolean hasMinusStrandConflict() throws Exception {
        for (Long pos: getPositions()) {
            if (getMinusStrandGene(pos).size() > 1) {
                return true;
            }
        }
        return false;
    }

    public List<MappedGene> getPlusStrandGene(long position) throws Exception {
        List <MappedGene> retList = new ArrayList<MappedGene>();

        for (MappedGene mg: genes) {
            if( mg.getStrand()==null ) {
                String assembly = MapManager.getInstance().getMap(mg.getMapKey()).getName();
                throw new VVException("no strand for gene RGD:"+mg.getGene().getRgdId()+" "+mg.getGene().getSymbol() +" in "+assembly+" assembly");
            }

            if (mg.getStrand().equals("+") && position >= mg.getStart() && position <=mg.getStop()) {
                retList.add(mg);
            }
        }
        return retList;
    }


    public List<MappedGene> getMinusStrandGene(long position) throws Exception {
        List <MappedGene> retList = new ArrayList<MappedGene>();

        for (MappedGene mg: genes) {
            if( mg.getStrand()==null ) {
                String assembly = MapManager.getInstance().getMap(mg.getMapKey()).getName();
                throw new VVException("no strand for gene RGD:"+mg.getGene().getRgdId()+" "+mg.getGene().getSymbol()+" in "+assembly+" assembly");
            }

            if (mg.getStrand().equals("-") && position >= mg.getStart() && position <=mg.getStop()) {
                retList.add(mg);
            }
        }
        return retList;
    }


    public void add(VariantResult vr) {

        variants.add(vr);
        Variant v = vr.getVariant();

        //add to genome map
        if (genome.containsKey(v.getStartPos())) {
            List<VariantResult> vars = (List) genome.get(v.getStartPos());
            vars.add(vr);
        }else {
            List<VariantResult> vars = new ArrayList();
            vars.add(vr);
            genome.put(v.getStartPos(), vars);
        }

        //add to sample map
        if (samples.containsKey(v.getSampleId())) {
            TreeMap pos = (TreeMap) samples.get(v.getSampleId());

            if (pos.containsKey(v.getStartPos())) {
                List<VariantResult> vars = (List) pos.get(v.getStartPos());
                vars.add(vr);
            }else {
                List<VariantResult> vars = new ArrayList<VariantResult>();
                vars.add(vr);
                pos.put(v.getStartPos(), vars);
            }
        }else {
            TreeMap pos = new TreeMap();

            List<VariantResult> vars = new ArrayList<VariantResult>();
            vars.add(vr);
            pos.put(v.getStartPos(), vars);

            samples.put(v.getSampleId(), pos);

        }


        if (!conScore.containsKey(v.getStartPos())) {
            if (v.conservationScore.size() == 0) {
                conScore.put(v.getStartPos(), new BigDecimal("-1"));
            }else {
                ConservationScore cs = v.conservationScore.get(0);
                conScore.put(v.getStartPos(),cs.getScore());
            }
        }

        if (!ref.containsKey(v.getStartPos())) {
            ref.put(v.getStartPos(),v.getReferenceNucleotide());
        }

        if (!ref.containsKey(v.getStartPos())) {
            ref.put(v.getStartPos(),v.getReferenceNucleotide());
        }

    }

    public List<VariantResult> get(long startPos) {
        return (List<VariantResult>) genome.get(startPos);
    }

    public List<VariantResult> getNucleotide (int sampleId, long position) {

        if (samples.get(sampleId) == null) {
            return new ArrayList<VariantResult>();
        }

        TreeMap pos = (TreeMap) samples.get(sampleId);

        List<VariantResult> vars  = (List)pos.get(position);

        if (vars == null) {
            vars = new ArrayList<VariantResult>();
        }

        return vars;

    }


    public Set<Long> getPositions() {
        return genome.keySet();
    }

    public void addSampleIds(List<Integer> sampleIds) {
        this.sampleIds= sampleIds;
    }

    public List getSamples() {
        return sampleIds;
    }

    public String getRefNuc(long position) {
        return (String) ref.get(position);
    }

    public BigDecimal getConservation(long position) {
        return (BigDecimal) conScore.get(position);
    }

}
