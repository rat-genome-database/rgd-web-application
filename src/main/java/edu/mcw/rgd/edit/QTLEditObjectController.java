package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.dao.spring.StringListQuery;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public class QTLEditObjectController extends EditObjectController {

    QTLDAO dao = new QTLDAO();

    /** A QTL symbol in a numbered series is letters, then the series number, then an optional
     *  suffix - Cm132, GWAS10_R, Eae18a. Of the 2410 rat QTLs 2391 are the plain letters+number
     *  form. A symbol with no digits at all (Eaex) is not part of a numbered series and gets no
     *  numbering check. */
    private static final Pattern NUMBERED_SYMBOL = Pattern.compile("^([A-Za-z]+)([0-9]+)(.*)$");

    public String getViewUrl() throws Exception {
       return "editQTL.jsp";
    }

    /** The series prefix of a numbered symbol ("Cm" for Cm132), or null if it is not numbered. */
    static String symbolSeriesPrefix(String symbol) {
        if (Utils.isStringEmpty(symbol)) {
            return null;
        }
        Matcher m = NUMBERED_SYMBOL.matcher(symbol.trim());
        return m.matches() ? m.group(1) : null;
    }

    /** QTLs already carrying this exact symbol, each as "1234567 (ACTIVE)", excluding the one
     *  being edited. Withdrawn QTLs count: a number that was used and later retired must not be
     *  handed out again either, so there is no object_status filter.
     *
     *  This runs its own query rather than calling QTLDAO.getQTLBySymbol because that method
     *  throws as soon as a symbol has more than one active QTL - which is precisely the state
     *  this check exists to report on, and the reason an already duplicated symbol made the
     *  existing QTL's page fail too. */
    List<String> getQtlsUsingSymbol(String symbol, int speciesTypeKey, int exceptRgdId) throws Exception {
        String sql = "SELECT r.rgd_id||' ('||r.object_status||')' FROM qtls q, rgd_ids r "
                   + "WHERE r.rgd_id=q.rgd_id AND r.species_type_key=? AND q.qtl_symbol_lc=? "
                   + "AND r.rgd_id<>? ORDER BY 1";
        return StringListQuery.execute(dao, sql, speciesTypeKey, symbol.trim().toLowerCase(), exceptRgdId);
    }

    /** Highest series number in use for a prefix, or null when nothing is numbered under it yet.
     *  Every status is counted, for the same reason getQtlsUsingSymbol counts them.
     *
     *  The LIKE narrows the scan to the indexed lowercase symbol column before the regexp
     *  decides what really belongs to the series, so "Cm" cannot pick up a "Cmo..." symbol and
     *  a prefix shared by hundreds of thousands of human GWAS QTLs still answers from the index.
     *  A suffixed symbol stays in its series - Eae18a counts as Eae number 18. */
    Integer getHighestNumberInSeries(String prefix, int speciesTypeKey) throws Exception {
        String lc = prefix.trim().toLowerCase();
        String sql = "SELECT MAX(CAST(SUBSTRING(q.qtl_symbol_lc FROM '^[a-z]+([0-9]+)') AS NUMERIC)) "
                   + "FROM qtls q, rgd_ids r "
                   + "WHERE r.rgd_id=q.rgd_id AND r.species_type_key=? "
                   + "AND q.qtl_symbol_lc LIKE ? AND REGEXP_LIKE(q.qtl_symbol_lc, ?)";
        List<String> res = StringListQuery.execute(dao, sql, speciesTypeKey, lc + "%", "^" + lc + "[0-9]+");
        String max = res.isEmpty() ? null : res.get(0);
        if (Utils.isStringEmpty(max)) {
            return null;   // MAX over no rows comes back as a single null row
        }
        // the aggregate comes back as a number string; take the integer part only, and
        // treat anything unparseable as "series unknown" rather than failing the whole save.
        Matcher m = Pattern.compile("^([0-9]+)").matcher(max.trim());
        if (!m.find()) {
            return null;
        }
        try {
            return Integer.valueOf(m.group(1));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Where a series currently ends: "Highest Cm in use is 133 - next free is Cm134." Empty
     *  when the symbol is not numbered, so callers can append it unconditionally.
     *
     *  The numbering is advisory, so a failure to read it returns "" rather than propagating:
     *  it must never be the reason a QTL cannot be saved, nor turn the symbol-conflict error
     *  below into a database error the curator cannot act on. */
    String describeSeriesNumbering(String symbol, int speciesTypeKey) {
        String prefix = symbolSeriesPrefix(symbol);
        if (prefix == null) {
            return "";
        }
        Integer highest;
        try {
            highest = getHighestNumberInSeries(prefix, speciesTypeKey);
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
        if (highest == null) {
            return "No numbered " + prefix + " QTL exists yet for "
                    + SpeciesType.getCommonName(speciesTypeKey) + ".";
        }
        return "Highest " + prefix + " in use is " + highest
                + " - next free is " + prefix + (highest + 1) + ".";
    }

    /** The whole hint the edit form shows under the Symbol box: whether this exact symbol is
     *  taken, and where the series ends either way. */
    String describeSymbolSeries(String symbol, int speciesTypeKey, int rgdId) throws Exception {
        if (symbolSeriesPrefix(symbol) == null) {
            return "";
        }
        String numbering = describeSeriesNumbering(symbol, speciesTypeKey);
        List<String> inUse = getQtlsUsingSymbol(symbol, speciesTypeKey, rgdId);
        if (inUse.isEmpty()) {
            return numbering;
        }
        return symbol.trim() + " is already used by RGD:" + Utils.concatenate(inUse, ", RGD:")
                + ". " + numbering;
    }

    public int getObjectTypeKey() {
        return 6;
    }

    /** The edit form asks for the symbol hint as the curator types, so a clash shows up before
     *  the QTL is submitted rather than as an error afterwards. Handled here instead of in
     *  EditObjectController's action switch so that shared switch stays object-type agnostic;
     *  everything else still goes to the base class untouched. */
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        if (!"qtlSymbolInfo".equals(request.getParameter("act"))) {
            return super.handleRequest(request, response);
        }

        // same curator login gate the base class applies before it will show or change anything
        if (!checkToken(getAccessToken(request))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        String symbol = request.getParameter("symbol");
        int speciesTypeKey = SpeciesType.parse(request.getParameter("speciesType"));
        int rgdId = -1;
        try {
            rgdId = Integer.parseInt(request.getParameter("rgdId"));
        } catch (NumberFormatException ignored) {}

        String hint;
        try {
            hint = describeSymbolSeries(symbol, speciesTypeKey, rgdId);
        } catch (Exception e) {
            // a hint is advisory - never let it put an error on the curator's screen
            e.printStackTrace();
            hint = "";
        }
        response.setContentType("text/plain; charset=UTF-8");
        response.getWriter().print(hint);
        return null;
    }

    /** The accessToken cookie, read the way EditObjectController reads it. */
    private static String getAccessToken(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) {
            return null;
        }
        for (Cookie c : cookies) {
            if (c.getName().equalsIgnoreCase("accessToken")) {
                return c.getValue();
            }
        }
        return null;
    }
    
    public Object getObject(int rgdId) throws Exception{        
        return dao.getQTL(rgdId);
    }

    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }

    public Object newObject() throws Exception{
        QTL qtl = new QTL();
        qtl.setRgdId(-1);        
        qtl.setKey(-1);
        return qtl;
    }

    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        if (req.getParameter("key").equals("")) {
            return null;
        }

        List<NomenclatureEvent> nomenEvents = new ArrayList<>();
        List<Alias> aliases = new ArrayList<>();

        boolean isNew = false;

        String symbol = req.getParameter("symbol");
        this.checkSet("Symbol", symbol);

        String name = req.getParameter("name");
        this.checkSet("Name", name);

        int rgdId = Integer.parseInt(req.getParameter("rgdId"));
        int speciesTypeKey = SpeciesType.parse(req.getParameter("speciesType"));

        // Refuse a symbol another QTL already carries, before anything is written. Without this
        // a duplicate went in and left two QTLs sharing a symbol, which then broke symbol lookup
        // for the original as well. The message carries the next free number so the curator can
        // fix it in one step. The QTL being edited is excluded, so re-saving it is not a clash.
        List<String> symbolInUse = getQtlsUsingSymbol(symbol, speciesTypeKey, rgdId);
        if (!symbolInUse.isEmpty()) {
            throw new Exception("symbol conflict - QTL " + symbol.trim() + " already exists: RGD:"
                    + Utils.concatenate(symbolInUse, ", RGD:") + ". "
                    + describeSeriesNumbering(symbol, speciesTypeKey));
        }

        QTL qtl;
        if (rgdId == -1) {
            isNew = true;
            qtl = new QTL();
        } else {
            qtl = dao.getQTL(rgdId);

            if (!Utils.stringsAreEqual(qtl.getSymbol(), symbol) || !Utils.stringsAreEqual(qtl.getName(), name)) {
                NomenclatureEvent ne = new NomenclatureEvent();
                ne.setDesc("Symbol and/or name change");
                ne.setEventDate(new Date());
                ne.setName(name);
                ne.setSymbol(symbol);
                ne.setNomenStatusType("APPROVED");
                ne.setOriginalRGDId(qtl.getRgdId());
                ne.setPreviousName(qtl.getName());
                ne.setPreviousSymbol(qtl.getSymbol());
                ne.setRefKey("853");
                ne.setRgdId(rgdId);
                nomenEvents.add(ne);

                if( !Utils.stringsAreEqual(qtl.getSymbol(), symbol) ) {
                    Alias alias = new Alias();
                    alias.setRgdId(rgdId);
                    alias.setTypeName("old_qtl_symbol");
                    alias.setValue(qtl.getSymbol());
                    alias.setNotes("created by QTL Edit on "+new Date());
                    aliases.add(alias);
                }

                if( !Utils.stringsAreEqual(qtl.getName(), name) ) {
                    Alias alias = new Alias();
                    alias.setRgdId(rgdId);
                    alias.setTypeName("old_qtl_name");
                    alias.setValue(qtl.getName());
                    alias.setNotes("created by QTL Edit on "+new Date());
                    aliases.add(alias);
                }
            }
        }

        qtl.setSymbol(symbol);
        qtl.setName(name);

        if (this.checkInteger("Peak Offset", req.getParameter("peakOffset"), false)) {
            qtl.setPeakOffset(Integer.parseInt(req.getParameter("peakOffset")));
        }

        if (this.checkChromosome(req.getParameter("chromosome"), false)) {
            qtl.setChromosome(req.getParameter("chromosome"));
        }

        if (this.checkNumeric("LOD", req.getParameter("lod"), false)) {
            qtl.setLod(Double.parseDouble(req.getParameter("lod")));
        } else {
            qtl.setLod(null);
        }

        if (this.checkNumeric("P Value", req.getParameter("pValue"), false)) {
            qtl.setPValue(Double.parseDouble(req.getParameter("pValue")));
        } else {
            qtl.setPValue(null);
        }

        if (this.checkNumeric("Variance", req.getParameter("variance"), false)) {
            qtl.setVariance(Double.parseDouble(req.getParameter("variance")));
        } else {
            qtl.setVariance(null);
        }

        String flank1RgdIdStr = request.getParameter("flank1RgdId");
        if( flank1RgdIdStr!=null ) {
            int flank1RgdId = 0;
            try {
                flank1RgdId = Integer.parseInt(flank1RgdIdStr);
            } catch( NumberFormatException e) {}
            qtl.setFlank1RgdId( flank1RgdId > 0 ? flank1RgdId : null );
        }
        String flank2RgdIdStr = request.getParameter("flank2RgdId");
        if( flank2RgdIdStr!=null ) {
            int flank2RgdId = 0;
            try {
                flank2RgdId = Integer.parseInt(flank2RgdIdStr);
            } catch( NumberFormatException e) {}
            qtl.setFlank2RgdId( flank2RgdId > 0 ? flank2RgdId : null );
        }
        String peakRgdIdStr = request.getParameter("peakRgdId");
        if( peakRgdIdStr!=null ) {
            int peakRgdId = 0;
            try {
                peakRgdId = Integer.parseInt(peakRgdIdStr);
            } catch( NumberFormatException e) {}
            qtl.setPeakRgdId( peakRgdId > 0 ? peakRgdId : null );
        }

        qtl.setInheritanceType(req.getParameter("inheritanceType"));
        qtl.setLodImage(req.getParameter("lodImage"));
        qtl.setLinkageImage(req.getParameter("linkageImage"));
        qtl.setSourceUrl(req.getParameter("sourceUrl"));
        qtl.setMostSignificantCmoTerm(req.getParameter("mostSignificantCmoTerm"));

        if (persist) {
            if (isNew) {
                dao.insertQTL(qtl, req.getParameter("objectStatus"), SpeciesType.parse(req.getParameter("speciesType")));
            } else {
                System.out.println("QTL UPDATE FLANK1="+qtl.getFlank1RgdId()+", FLANK2="+qtl.getFlank2RgdId()+", PEAK="+qtl.getPeakRgdId());
                dao.updateQTL(qtl);
                addNomenEvents(nomenEvents);
                insertAliases(aliases);
            }
        }
        return qtl;
    }
}
