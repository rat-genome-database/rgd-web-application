package edu.mcw.rgd.pubmed;

import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.dao.impl.XdbIdDAO;
import edu.mcw.rgd.datamodel.Author;
import edu.mcw.rgd.datamodel.Reference;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.XdbId;
import edu.mcw.rgd.process.FileDownloader;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.xml.XomAnalyzer;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import nu.xom.Element;
import nu.xom.Elements;
import org.apache.commons.collections4.CollectionUtils;
import org.jaxen.XPath;
import org.jaxen.xom.XOMXPath;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.io.StringReader;
import java.util.*;

/**
 * Created by mtutaj on 12/14/2016.
 */
public class ReferenceImport implements Controller {

    ReferenceDAO refDAO = new ReferenceDAO();
    RGDManagementDAO rgdDAO = new RGDManagementDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        State state = new State();
        String action = Utils.NVL(request.getParameter("action"), "retrieve");
        if( Utils.defaultString(request.getParameter("mode")).equals("update") ) {
            state.updateMode = true;
        }

        // parse pmid_list parameter: one or more PMIDs separated by ','
        Map<String,Integer> pmid2RefRgdId = new HashMap<>();
        Collection<String> pmidsIncoming = getIncomingPubmedIds(request);

        // validate PubMed ids and determine ones that are not in RGD yet
        Collection<String> pmidsNotInRgd = getPmidsNotInRgd(pmidsIncoming, pmid2RefRgdId);
        //System.out.println("PMIDS not in rgd "+pmidsNotInRgd.size());

        int articlesProcessed = 0;
        for( String pmid: pmidsNotInRgd ) {
            if( articlesProcessed>0 ) {
                Thread.sleep(7000); // sleep 7sec before attempting next download -- be usage friendly for NCBI eutils
            }

            String article = downloadArticleFromPubmed(pmid, "xml");
            // a valid article in xml format must be at least 300 chars long
            if( article==null || article.length()<300 ) {
                if( action.equals("bucket") ) {
                    response.sendRedirect("/rgdCuration/?module=curation&func=referencesNotFound");
                } else if( action.equals("phenominer") ) {
                    response.sendRedirect("/rgdweb/curation/phenominer/home.html?error=ReferencesNotFound");
                }
                return null;
            }

            parseArticle(state, article);
            insertArticle(state);

            articlesProcessed++;
            pmid2RefRgdId.put(pmid, state.ref.getRgdId());
        }

        // in UPDATE mode, process all articles that are already in RGD and update the article data
        if( state.updateMode ) {
            response.setContentType("text/plain");

            Collection<String> pmidsForUpdate = CollectionUtils.subtract(pmidsIncoming, pmidsNotInRgd);
            for( String pmid: pmidsForUpdate ) {

                if( articlesProcessed>0 ) {
                    Thread.sleep(7000); // sleep 7sec before attempting next download -- be usage friendly for NCBI eutils
                }

                String article = downloadArticleFromPubmed(pmid, "xml");
                if( article==null ) {
                    return null;
                }

                parseArticle(state, article);
                try {
                    String updateStats = updateArticle(state, pmid2RefRgdId.get(pmid));
                    response.getWriter().print("PMID:" + pmid + " REF_RGD_ID:" + state.ref.getRgdId() + "\n");
                    response.getWriter().print(updateStats);
                    response.getWriter().print("\n");
                } catch(Exception e) {
                    e.printStackTrace();
                }
                articlesProcessed++;
            }
            return null;
        }

        // get first incoming article and return it
        if( !pmidsIncoming.isEmpty() ) {
            String pmid = pmidsIncoming.iterator().next();
            Integer refRgdId = pmid2RefRgdId.get(pmid);
            if( refRgdId!=null  && refRgdId!=0 ) {
                switch( action ) {
                    case "bucket":
                        response.sendRedirect("/rgdCuration/?module=curation&func=addReferenceToBucket&RGD_ID="+refRgdId);
                        return null;
                    case "phenominer":
                        response.sendRedirect("/rgdweb/curation/phenominer/studies.html?act=edit&referenceId="+refRgdId);
                        return null;
                    case "pathway":
                        String row = request.getParameter("row");
                        if( !Utils.isStringEmpty(row) ) {
                            response.setContentType("text/xml");
                            response.getWriter().print("<rgdid>" + refRgdId + "\t"+row+"</rgdid>\n");
                            return null;
                        }
                }
            }
        }

        if( action.equals("retrieve") ) {
            response.setContentType("text/plain");
            for( Map.Entry<String,Integer> entry: pmid2RefRgdId.entrySet() ) {
                response.getWriter().print("PMID:" + entry.getKey() + " REF_RGD_ID:" + entry.getValue() + "\n");
            }
        }
        return null;
    }

    void insertArticle(State state) throws Exception {

        // create reference rgd id
        RgdId id = new RGDManagementDAO().createRgdId(RgdId.OBJECT_KEY_REFERENCES, "ACTIVE", null, 0);
        state.ref.setRgdId(id.getRgdId());

        // create reference itself
        refDAO.insertReference(state.ref);

        // assign pubmed id for the reference
        state.xdbId.setRgdId(id.getRgdId());
        new XdbIdDAO().insertXdb(state.xdbId);

        // create authors that do not exists in the database
        // and create reference to author associations
        int authorOrder = 0;
        for( Author author: state.authors ) {
            Author authorInRgd = refDAO.findAuthor(author);
            if( authorInRgd!=null ) {
                author.setKey(authorInRgd.getKey());
            } else {
                refDAO.insertAuthor(author);
            }
            refDAO.insertRefAuthorAssociation(state.ref.getKey(), author.getKey(), ++authorOrder);
        }
    }

    String updateArticle(State state, int refRgdId) throws Exception {

        state.refWasUpdated = false;

        // get reference rgd id
        state.ref.setRgdId(refRgdId);

        // update reference if needed
        String updateStats = updateReference(state);

        List<Integer> authorKeysInRgd = refDAO.getRefAuthorAssociations(state.ref.getKey());

        // create authors that do not exists in the database
        // and update reference to author associations
        int authorsInserted = 0;
        int authorsUpToDate = 0;
        int refAuthorAssocUpToDate = 0;
        int refAuthorAssocModified = 0;
        int refAuthorAssocInserted = 0;
        int refAuthorAssocDeleted = 0;

        int authorOrder = 0;
        for( Author author: state.authors ) {
            Author authorInRgd = refDAO.findAuthor(author);
            if( authorInRgd!=null ) {
                author.setKey(authorInRgd.getKey());
                authorsUpToDate++;
            } else {
                refDAO.insertAuthor(author);
                authorsInserted++;
            }

            if( authorOrder<authorKeysInRgd.size() ) {
                if( authorKeysInRgd.get(authorOrder)!=author.getKey() ) {
                    refDAO.updateRefAuthorAssociation(state.ref.getKey(), authorKeysInRgd.get(authorOrder), author.getKey(), authorOrder+1);
                    refAuthorAssocModified++;
                } else {
                    refAuthorAssocUpToDate++;
                }
            } else {
                refDAO.insertRefAuthorAssociation(state.ref.getKey(), author.getKey(), authorOrder+1);
                refAuthorAssocInserted++;
            }
            authorOrder++;
        }

        if( authorKeysInRgd.size() > state.authors.size() ) {
            for( authorOrder=state.authors.size(); authorOrder<authorKeysInRgd.size(); authorOrder++ ) {
                refAuthorAssocDeleted += refDAO.deleteRefAuthorAssociation(state.ref.getKey(), authorKeysInRgd.get(authorOrder), authorOrder+1);
            }
        }

        if( authorsInserted!=0 ) {
            updateStats += "  authors inserted=" + authorsInserted + "\n";
        }
        if( authorsUpToDate!=0 ) {
            updateStats += "  authors up-to-date=" + authorsUpToDate + "\n";
        }
        if( refAuthorAssocInserted!=0 ) {
            updateStats += "  ref-to-author assocs inserted=" + refAuthorAssocInserted + "\n";
        }
        if( refAuthorAssocModified!=0 ) {
            updateStats += "  ref-to-author assocs modified=" + refAuthorAssocModified + "\n";
        }
        if( refAuthorAssocUpToDate!=0 ) {
            updateStats += "  ref-to-author assocs up-to-date=" + refAuthorAssocUpToDate + "\n";
        }
        if( refAuthorAssocDeleted!=0 ) {
            updateStats += "  ref-to-author assocs deleted=" + refAuthorAssocDeleted + "\n";
        }


        if( authorsInserted!=0 || refAuthorAssocInserted!=0 || refAuthorAssocModified!=0 || refAuthorAssocDeleted!=0 ) {
            state.refWasUpdated = true;
        }
        if( state.refWasUpdated ) {
            rgdDAO.updateLastModifiedDate(refRgdId);
        }

        return updateStats;
    }

    String updateReference(State state) throws Exception {

        Reference refIncoming = state.ref;
        Reference refInRgd = refDAO.getReference(refIncoming.getRgdId());

        // copy invariable in-RGD fields that are never touched by ReferenceUpdate pipeline
        refIncoming.setKey(refInRgd.getKey());
        refIncoming.setEditors(refInRgd.getEditors());
        refIncoming.setPubStatus(refInRgd.getPubStatus());
        refIncoming.setNotes(refInRgd.getNotes ());
        refIncoming.setPublisher(refInRgd.getPublisher());
        refIncoming.setPublisherCity(refInRgd.getPublisherCity());
        refIncoming.setUrlWebReference(refInRgd.getUrlWebReference());

        // see if any of the fields for the incoming reference are different in db
        if( !Utils.stringsAreEqualIgnoreCase(refIncoming.getDoi(), refInRgd.getDoi()) ||
            !Utils.stringsAreEqualIgnoreCase(refIncoming.getTitle(), refInRgd.getTitle()) ||
            !Utils.stringsAreEqualIgnoreCase(refIncoming.getPublication(), refInRgd.getPublication()) ||
            !Utils.stringsAreEqualIgnoreCase(refIncoming.getVolume(), refInRgd.getVolume()) ||
            !Utils.stringsAreEqualIgnoreCase(refIncoming.getIssue(), refInRgd.getIssue()) ||
            !Utils.stringsAreEqualIgnoreCase(refIncoming.getPages(), refInRgd.getPages()) ||
            !Utils.datesAreEqual(refIncoming.getPubDate(), refInRgd.getPubDate()) ||
            !Utils.stringsAreEqualIgnoreCase(refIncoming.getRefAbstract(), refInRgd.getRefAbstract()) ||
            !Utils.stringsAreEqualIgnoreCase(refIncoming.getReferenceType(), refInRgd.getReferenceType()) ||
            !Utils.stringsAreEqualIgnoreCase(refIncoming.getCitation(), refInRgd.getCitation()) ) {

            refDAO.updateReference(refIncoming);
            state.refWasUpdated = true;
            return "  REFERENCE was updated\n";
        }
        return "  REFERENCE was up-to-date\n";
    }

    // format: xml | medline
    String downloadArticleFromPubmed(String pmid, String format) throws Exception {

//            String fileN = "/tmp/"+pmid+"."+format;
//            File file = new File(fileN);
//            if( file.exists() ) {
//                return Utils.readFileAsString(fileN);
//            }

        String url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&tool=ReferenceImport&email=mtutaj@mcw.edu"+
                "&rettype="+format+"&id="+pmid;
        System.out.println(url);
        FileDownloader fd = new FileDownloader();
        fd.setExternalFile(url);
        fd.setMaxRetryCount(1);
        String content = "";
        try {
            content = fd.download();
            return content;
        } catch(Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            Utils.writeStringToFile(content, "/tmp/pmid"+pmid+"."+format);
        }
    }

    protected Collection<String> getIncomingPubmedIds(HttpServletRequest request) {
        String paramPmidList = Utils.defaultString(request.getParameter("pmid_list"));
        String[] pmids = paramPmidList.split("[,]");
        Set<String> incomingPubmedIds = new HashSet<>();
        for( String pmid: pmids ) {
            // PMID should be only digits; strip any non-digit character from the input
            StringBuffer pmidBuf = new StringBuffer();
            for( int i=0; i<pmid.length(); i++ ) {
                char c = pmid.charAt(i);
                if( Character.isDigit(c) ) {
                    pmidBuf.append(c);
                }
            }
            if( pmidBuf.length() > 0 ) {
                incomingPubmedIds.add(pmidBuf.toString());
            }
        }
        return incomingPubmedIds;
    }

    protected Collection<String> getPmidsNotInRgd(Collection<String> pmidsIncoming, Map<String,Integer> pmid2RefRgdId) throws Exception {

        List<String> pmidsNotInRgd = new ArrayList<>();
        for( String pmid: pmidsIncoming ) {
            int refRgdId = refDAO.getReferenceRgdIdByPubmedId(pmid);
            if( refRgdId==0 ) {
                pmidsNotInRgd.add(pmid);
            } else {
                pmid2RefRgdId.put(pmid, refRgdId);
            }
        }
        return pmidsNotInRgd;
    }

    protected MyXomAnalyzer parseArticle(State state, String article) throws Exception {
        state.reset();

        MyXomAnalyzer parser = new MyXomAnalyzer();
        parser.setState(state);
        parser.setValidate(false);
        parser.parse(new StringReader(article));
        return parser;
    }

    // pubmed article
    static XPath xpPubmedId, xpDoi, xpTitle, xpJournal, xpVolume, xpIssue, xpPages, xpPubYear, xpPubMonth, xpPubDay;
    static XPath xpAbstract, xpAuthors;
    // books
    static XPath xpbPubmedId, xpbDoi, xpbTitle, xpbJournal, xpbPages, xpbPubYear, xpbPubMonth, xpbPubDay;
    static XPath xpbAbstract, xpbAuthors;

    static { try {
        xpPubmedId = new XOMXPath("PubmedData/ArticleIdList/ArticleId[@IdType='pubmed']");
        xpDoi = new XOMXPath("PubmedData/ArticleIdList/ArticleId[@IdType='doi']");
        xpTitle = new XOMXPath("MedlineCitation/Article/ArticleTitle");
        xpJournal = new XOMXPath("MedlineCitation/MedlineJournalInfo/MedlineTA");
        xpVolume = new XOMXPath("MedlineCitation/Article/Journal/JournalIssue/Volume");
        xpIssue = new XOMXPath("MedlineCitation/Article/Journal/JournalIssue/Issue");
        xpPages = new XOMXPath("MedlineCitation/Article/Pagination/MedlinePgn");
        xpPubYear = new XOMXPath("MedlineCitation/Article/Journal/JournalIssue/PubDate/Year");
        xpPubMonth = new XOMXPath("MedlineCitation/Article/Journal/JournalIssue/PubDate/Month");
        xpPubDay = new XOMXPath("MedlineCitation/Article/Journal/JournalIssue/PubDate/Day");
        xpAbstract = new XOMXPath("MedlineCitation/Article/Abstract/AbstractText");
        xpAuthors = new XOMXPath("MedlineCitation/Article/AuthorList/Author[@ValidYN='Y']");

        xpbPubmedId = new XOMXPath("PubmedBookData/ArticleIdList/ArticleId[@IdType='pubmed']");
        xpbDoi = new XOMXPath("PubmedBookData/ArticleIdList/ArticleId[@IdType='doi']");
        xpbTitle = new XOMXPath("BookDocument/ArticleTitle");
        xpbJournal = new XOMXPath("BookDocument/Book/BookTitle");
        xpbPages = new XOMXPath("BookDocument/Book/Pagination/MedlinePgn");
        xpbPubYear = new XOMXPath("BookDocument/Book/PubDate/Year");
        xpbPubMonth = new XOMXPath("BookDocument/Book/PubDate/Month");
        xpbPubDay = new XOMXPath("BookDocument/Book/PubDate/Day");
        xpbAbstract = new XOMXPath("BookDocument/Abstract/AbstractText");
        xpbAuthors = new XOMXPath("BookDocument/AuthorList/Author");
    } catch(Exception e) {
        e.printStackTrace();
    }}

    class MyXomAnalyzer extends XomAnalyzer {

        XdbId xdbId = new XdbId();
        Reference ref = new Reference();
        List<Author> authors = new ArrayList<>();

        public void setState(State state) {
            xdbId = state.xdbId;
            ref = state.ref;
            authors = state.authors;
        }

        public Element parseRecord(Element element) {

            xdbId.setXdbKey(XdbId.XDB_KEY_PUBMED);

            String pubYear, pubMonth, pubDay;
            List<Element> authors;
            try {
                if( element.getLocalName().equals("PubmedArticle") ) {
                    ref.setReferenceType("JOURNAL ARTICLE");
                    xdbId.setAccId(xpPubmedId.stringValueOf(element));
                    ref.setDoi(xpDoi.stringValueOf(element));
                    ref.setTitle(xpTitle.stringValueOf(element));
                    ref.setPublication(xpJournal.stringValueOf(element));
                    ref.setVolume(xpVolume.stringValueOf(element));
                    ref.setIssue(xpIssue.stringValueOf(element));
                    ref.setPages(xpPages.stringValueOf(element));
                    pubYear = xpPubYear.stringValueOf(element);
                    pubMonth = xpPubMonth.stringValueOf(element);
                    pubDay = xpPubDay.stringValueOf(element);
                    ref.setRefAbstract(getAbstract(xpAbstract.selectNodes(element)));
                    authors = xpAuthors.selectNodes(element);
                } else {
                    ref.setReferenceType("BOOK REVIEW");
                    xdbId.setAccId(xpbPubmedId.stringValueOf(element));
                    ref.setDoi(xpbDoi.stringValueOf(element));
                    ref.setTitle(xpbTitle.stringValueOf(element));
                    ref.setPublication(xpbJournal.stringValueOf(element));
                    ref.setPages(xpbPages.stringValueOf(element));
                    pubYear = xpbPubYear.stringValueOf(element);
                    pubMonth = xpbPubMonth.stringValueOf(element);
                    pubDay = xpbPubDay.stringValueOf(element);
                    ref.setRefAbstract(getAbstract(xpbAbstract.selectNodes(element)));
                    authors = xpbAuthors.selectNodes(element);
                }
                ref.setPubDate(getPubDate(pubYear, pubMonth, pubDay));
                parseAuthors(authors);
                createCitation();
            } catch(Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        String getAbstract(List nodes) {
            String abstractText = "";
            for( Element el: (List<Element>)nodes ) {
                String label = el.getAttributeValue("Label");
                if( !Utils.isStringEmpty(label) ) {
                    abstractText += "<br><b>"+label+": </b>";
                }
                abstractText += el.getValue();
            }
            return fixFancyCharacters(abstractText);
        }

        Date getPubDate(String pubYear, String pubMonth, String pubDay) throws Exception {
            int year = 0;
            int month = 12;
            int day = 1;

            switch(pubMonth) {
                case "Jan": month = 1; break;
                case "Feb": month = 2; break;
                case "Mar": month = 3; break;
                case "Apr": month = 4; break;
                case "May": month = 5; break;
                case "Jun": month = 6; break;
                case "Jul": month = 7; break;
                case "Aug": month = 8; break;
                case "Sep": month = 9; break;
                case "Oct": month = 10; break;
                case "Nov": month = 11; break;
                case "Dec": month = 12; break;
            }

            Scanner scanner = new Scanner(pubYear);
            if( scanner.hasNextInt() ) {
                year = scanner.nextInt();
            }

            scanner = new Scanner(pubDay);
            if( scanner.hasNextInt() ) {
                day = scanner.nextInt();
            }

            return new Date(year-1900, month-1, day);
        }

        void parseAuthors(List<Element> authors) {

            for( Element el: authors ) {
                Author author = new Author();

                Elements fields = el.getChildElements();
                for( int i=0; i<fields.size(); i++ ) {
                    Element field = fields.get(i);
                    String value = field.getValue();
                    switch( field.getLocalName() ) {
                        case "LastName":
                        case "CollectiveName": author.setLastName(value); break;
                        case "ForeName": author.setFirstName(value); break;
                        case "Initials": author.setInitials(value); break;
                        case "Suffix": author.setSuffix(value); break;
                    }
                }
                this.authors.add(author);
            }
        }

        void createCitation() throws Exception {
            if( ref.getReferenceType().equals("BOOK REVIEW") ) {
                ref.setCitation("PubMed Book Article");
                return;
            }

            // authors go first
            StringBuilder buf = new StringBuilder(100);
            if( authors.size()==0 ) {
                buf.append("NO_AUTHOR");
            } else {
                String author = authors.get(0).getAuthorForCitation();
                if( authors.size()==1 ) {
                    buf.append(author);
                } else if( authors.size()==2 ) {
                    buf.append(author).append(" and ").append(authors.get(1).getAuthorForCitation());
                } else {
                    buf.append(author).append(", etal.");
                }
            }

            String citation = downloadCitation();
            if( citation!=null ) {
                buf.append(", ").append(citation);
            }
            ref.setCitation(buf.toString());
        }

        String downloadCitation() throws Exception {
            String content = downloadArticleFromPubmed(xdbId.getAccId(), "medline");
            String lines[] = content.split("[\\n\\r]");
            String citation = null;
            // look for line starting with "SO  - ";
            for( int i=0; i<lines.length; i++ ) {
                if( lines[i].startsWith("SO  - ") ) {
                    citation = lines[i].substring(6).trim();
                    // citation could span multiple lines, starting with ' '
                    for( ++i; i<lines.length; i++ ) {
                        if( lines[i].startsWith(" ") ) {
                            citation += " "+lines[i].trim();
                        }
                    }
                    break;
                }
            }
            return citation;
        }

        String fixFancyCharacters(String s) {

            // text is stored in Oracle db as very limiting 'Windows-1252' format;
            // we need to convert some UTF-8 chars into human readable format
            return s.replace("≥", ">=")
                    .replace("≤", "<=")
                    .replace(" ", " ")
                    .replace("α", "&alpha;")
                    .replace("γ", "&gamma;")
                    .replace("κ", "&kappa;")
                    .replace("→", "->");
        }
    }

    class State {
        public boolean updateMode;
        public boolean refWasUpdated;
        public XdbId xdbId;
        public Reference ref;
        public List<Author> authors;

        public State() {
            reset();
        }

        public void reset() {
            refWasUpdated = false;
            xdbId = new XdbId();
            ref = new Reference();
            authors = new ArrayList<>();
        }
    }
}
