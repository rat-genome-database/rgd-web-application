package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontology.Annotation;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 3/19/13
 * Time: 4:21 PM
 * all data used by gene merge tool
 */
public class GeneMergeBean {

    private RgdId rgdIdFrom;
    private RgdId rgdIdTo;
    private Gene geneFrom;
    private Gene geneTo;

    private List<String> geneTypes;

    private List<Alias> aliasesInRgd = new ArrayList<Alias>(); // existing aliases for 'to-gene'
    private List<Alias> aliasesNew = new ArrayList<Alias>(); // new aliases to be inserted
    private List<Alias> aliasesNewIgnored = new ArrayList<Alias>(); // new aliases to be ignored

    private List<Note> notesInRgd = new ArrayList<Note>(); // existing notes for 'to-gene'
    private List<Note> notesNew = new ArrayList<Note>(); // new notes be inserted
    private List<Note> notesNewIgnored = new ArrayList<Note>(); // new notes to be ignored

    private List<Reference> curatedRefInRgd = new ArrayList<Reference>(); // existing curated references for 'to-gene'
    private List<Reference> curatedRefNew = new ArrayList<Reference>(); // curated references be inserted
    private List<Reference> curatedRefIgnored = new ArrayList<Reference>(); // new curated references to be ignored

    private List<Annotation> annotsInRgd = new ArrayList<Annotation>(); // existing annotation for 'to-gene'
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

    public Gene getGeneFrom() {
        return geneFrom;
    }

    public void setGeneFrom(Gene geneFrom) {
        this.geneFrom = geneFrom;
    }

    public Gene getGeneTo() {
        return geneTo;
    }

    public void setGeneTo(Gene geneTo) {
        this.geneTo = geneTo;
    }

    public List<String> getGeneTypes() {
        return geneTypes;
    }

    public void setGeneTypes(List<String> geneTypes) {
        this.geneTypes = geneTypes;
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

    public List<Note> getNotesNewIgnored() {
        return notesNewIgnored;
    }

    public List<Note> getNotesInRgd() {
        return notesInRgd;
    }

    public List<Note> getNotesNew() {
        return notesNew;
    }

    public List<Reference> getCuratedRefInRgd() {
        return curatedRefInRgd;
    }

    public List<Reference> getCuratedRefNew() {
        return curatedRefNew;
    }

    public List<Reference> getCuratedRefIgnored() {
        return curatedRefIgnored;
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
