package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontology.Annotation;

import java.util.ArrayList;
import java.util.List;

/**
 * @author mtutaj
 * @since March 1, 2021
 * all data used by strain merge tool
 */
public class StrainMergeBean {

    private RgdId rgdIdFrom;
    private RgdId rgdIdTo;
    private Strain strainFrom;
    private Strain strainTo;

    private List<Alias> aliasesInRgd = new ArrayList<Alias>(); // existing aliases for 'to-strain'
    private List<Alias> aliasesNew = new ArrayList<Alias>(); // new aliases to be inserted
    private List<Alias> aliasesNewIgnored = new ArrayList<Alias>(); // new aliases to be ignored

    private List<Annotation> annotsInRgd = new ArrayList<Annotation>(); // existing annotation for 'to-strain'
    private List<Annotation> annotsNew = new ArrayList<Annotation>(); // new annotation be inserted
    private List<Annotation> annotsIgnored = new ArrayList<Annotation>(); // new annotation to be ignored

    private List<XdbId> xdbidsInRgd = new ArrayList<XdbId>();
    private List<XdbId> xdbidsNew = new ArrayList<XdbId>();
    private List<XdbId> xdbidsIgnored = new ArrayList<XdbId>();

    private List<NomenclatureEvent> nomenInRgd = new ArrayList<NomenclatureEvent>();
    private List<NomenclatureEvent> nomenNew = new ArrayList<NomenclatureEvent>();
    private List<NomenclatureEvent> nomenIgnored = new ArrayList<NomenclatureEvent>();

    private List<MapData> mapDataInRgd = new ArrayList<MapData>();
    private List<MapData> mapDataNew = new ArrayList<MapData>();
    private List<MapData> mapDataIgnored = new ArrayList<MapData>();


    public RgdId getRgdIdFrom() {
        return rgdIdFrom;
    }

    public void setRgdIdFrom(RgdId rgdIdFrom) {
        this.rgdIdFrom = rgdIdFrom;
    }

    public RgdId getRgdIdTo() {
        return rgdIdTo;
    }

    public void setRgdIdTo(RgdId rgdIdTo) {
        this.rgdIdTo = rgdIdTo;
    }

    public Strain getStrainFrom() {
        return strainFrom;
    }

    public void setStrainFrom(Strain strainFrom) {
        this.strainFrom = strainFrom;
    }

    public Strain getStrainTo() {
        return strainTo;
    }

    public void setStrainTo(Strain strainTo) {
        this.strainTo = strainTo;
    }

    public List<Alias> getAliasesInRgd() {
        return aliasesInRgd;
    }

    public List<Alias> getAliasesNew() {
        return aliasesNew;
    }

    public List<Alias> getAliasesNewIgnored() {
        return aliasesNewIgnored;
    }

    public List<Annotation> getAnnotsInRgd() {
        return annotsInRgd;
    }

    public List<Annotation> getAnnotsNew() {
        return annotsNew;
    }

    public List<Annotation> getAnnotsIgnored() {
        return annotsIgnored;
    }

    public List<XdbId> getXdbidsInRgd() {
        return xdbidsInRgd;
    }

    public List<XdbId> getXdbidsNew() {
        return xdbidsNew;
    }

    public List<XdbId> getXdbidsIgnored() {
        return xdbidsIgnored;
    }

    public List<NomenclatureEvent> getNomenInRgd() {
        return nomenInRgd;
    }

    public List<NomenclatureEvent> getNomenNew() {
        return nomenNew;
    }

    public List<NomenclatureEvent> getNomenIgnored() {
        return nomenIgnored;
    }

    public List<MapData> getMapDataInRgd() {
        return mapDataInRgd;
    }

    public List<MapData> getMapDataNew() {
        return mapDataNew;
    }

    public List<MapData> getMapDataIgnored() {
        return mapDataIgnored;
    }
}
