package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.SequenceDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainDao;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.SSLP;
import edu.mcw.rgd.dao.impl.SSLPDAO;
import edu.mcw.rgd.datamodel.Sequence;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class SSLPEditObjectController extends EditObjectController {

    SSLPDAO dao = new SSLPDAO();
    SequenceDAO seqDao = new SequenceDAO();
    RGDManagementDAO rdao = new RGDManagementDAO();

    public String getViewUrl() throws Exception {
       return "editSSLP.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new SSLPDAO().getSSLP(rgdId);
    }

    public Object newObject() throws Exception{
        return new SSLP();
    }
    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }
    public int getObjectTypeKey() {
        return RgdId.OBJECT_KEY_SSLPS;
    }

    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

         // new sslp: both parameters 'key' and 'rgdId' are 0
        int rgdId = Integer.parseInt(req.getParameter("rgdId"));
        SSLP sslp;
        if( rgdId==0 ) {
            // create a new sslp
            sslp = createNewSslp(req);
        }
        else {
            sslp = dao.getSSLP(rgdId);
            if (!req.getParameter("key").equals("")) {
                sslp.setName(req.getParameter("name"));
                if (!req.getParameter("expectedSize").isEmpty()) {
                   sslp.setExpectedSize(Integer.parseInt(req.getParameter("expectedSize")));
                }
                sslp.setNotes(req.getParameter("notes"));
                sslp.setSslpType(req.getParameter("sslp_type"));

                if (persist) {
                    dao.updateSSLP(sslp);
                    updateSequences(rgdId, req);
                }
            }
        }

        return sslp;
    }

    SSLP createNewSslp(HttpRequestFacade req) throws Exception {

        // create new rgd id
        RgdId id = rdao.createRgdId(this.getObjectTypeKey() ,req.getParameter("objectStatus"), SpeciesType.parse(req.getParameter("speciesType")));

        // now create a gene object
        SSLP obj = new SSLP();
        obj.setRgdId(id.getRgdId());
        obj.setSpeciesTypeKey(id.getSpeciesTypeKey());
        obj.setName(req.getParameter("name"));
        obj.setNotes(req.getParameter("notes"));
        obj.setSslpType(req.getParameter("sslp_type"));
        String expectedSize = req.getParameter("expectedSize");
        if( !expectedSize.isEmpty() )
            obj.setExpectedSize(Integer.parseInt(expectedSize));
        dao.insertSSLP(obj);
        return obj;
    }

    void updateSequences(int rgdId, HttpRequestFacade req) throws Exception {

        // in RGD, an SSLP may have at most one forward-reverse primer seq pair or one template sequence
        List<Sequence> seqList = seqDao.getObjectSequences(rgdId);
        updateTemplateSequence(rgdId, req, seqList);
        updateSequencePrimerPair(rgdId, req, seqList);
    }

    void updateTemplateSequence(int rgdId, HttpRequestFacade req, List<Sequence> inRgdSeqs) throws Exception {

        // get template sequence in rgd
        Sequence inRgdSeq = null;
        for( Sequence seq: inRgdSeqs ) {
            if( !Utils.isStringEmpty(seq.getCloneSeq()) ) {
                inRgdSeq = seq;
                break;
            }
        }

        // get incoming template sequence (and strip all whitespace from it)
        String template = req.getParameter("templateSeq").replaceAll("[\\s]+","");

        // CASE1: there is no incoming template seq, and template sequence is not in RGD
        //   action: nothing to do
        if( template.isEmpty() && inRgdSeq==null ) {
            return;
        }

        // CASE2: there is incoming template sequence, and template sequence is not in RGD
        //   action: insert a new template sequence
        if( !template.isEmpty() && inRgdSeq==null ) {
            RgdId sslp = rdao.getRgdId2(rgdId);
            RgdId id = rdao.createRgdId(RgdId.OBJECT_KEY_SEQUENCES, "ACTIVE", sslp.getSpeciesTypeKey());
            int seqKey = seqDao.createSequence(id.getRgdId(), 11, null, null);
            seqDao.bindSequence(seqKey, 5, rgdId);
            seqDao.insertSeqClone(seqKey, null, template);
            return;
        }

        // CASE3: there is no incoming template sequence, and template sequence is in RGD
        //   action: unbind existing template sequence
        if( template.isEmpty() && inRgdSeq!=null ) {
            seqDao.unbindSequence(inRgdSeq.getSeqKey(), 5, rgdId);
            return;
        }

        // CASE4: there is incoming template sequence, and template sequence is in RGD
        //   action: update template sequence if needed
        if( !template.isEmpty() && inRgdSeq!=null ) {
            if( !inRgdSeq.getCloneSeq().equals(template) ) {
                seqDao.updateSeqCloneByKey(inRgdSeq.getSeqKey(), template);
            }
        }
    }

    void updateSequencePrimerPair(int rgdId, HttpRequestFacade req, List<Sequence> inRgdSeqs) throws Exception {

        // get template sequence in rgd
        Sequence inRgdSeq = null;
        for( Sequence seq: inRgdSeqs ) {
            if( !Utils.isStringEmpty(seq.getForwardSeq()) || !Utils.isStringEmpty(seq.getReverseSeq())) {
                inRgdSeq = seq;
                break;
            }
        }

        // get incoming primer pair (and strip all whitespace from it)
        String forward = req.getParameter("forwardPrimer").replaceAll("[\\s]+","");
        String reverse = req.getParameter("reversePrimer").replaceAll("[\\s]+","");

        boolean incomingPrimerPairIsEmpty = forward.isEmpty() && reverse.isEmpty();
        boolean inRgdPrimerPairIsEmpty = inRgdSeq==null
                || (Utils.isStringEmpty(inRgdSeq.getForwardSeq()) && Utils.isStringEmpty(inRgdSeq.getReverseSeq()));

        // CASE1: incoming and in-rgd is empty
        //   action: nothing to do
        if( incomingPrimerPairIsEmpty && inRgdPrimerPairIsEmpty ) {
            return;
        }

        // CASE2: there is incoming primer sequence pair, which is not in RGD
        //   action: insert a new primer sequence pair
        if( !incomingPrimerPairIsEmpty && inRgdPrimerPairIsEmpty ) {
            RgdId sslp = rdao.getRgdId2(rgdId);
            RgdId id = rdao.createRgdId(RgdId.OBJECT_KEY_SEQUENCES, "ACTIVE", sslp.getSpeciesTypeKey());
            int seqKey = seqDao.createSequence(id.getRgdId(), 4, null, null);
            seqDao.bindSequence(seqKey, 6, rgdId);
            seqDao.insertPrimerPairs(null, null, forward, reverse, null, seqKey);
            return;
        }

        // CASE3: there is no incoming primer sequence pair, and primer sequence pair is in RGD
        //   action: unbind existing primer sequence pair
        if( incomingPrimerPairIsEmpty && !inRgdPrimerPairIsEmpty ) {
            seqDao.unbindSequence(inRgdSeq.getSeqKey(), 6, rgdId);
            return;
        }

        // CASE4: there is incoming primer sequence pair, and there is primer sequence in RGD
        //   action: update primer sequence pair if needed
        if( !incomingPrimerPairIsEmpty && !inRgdPrimerPairIsEmpty ) {
            if( !Utils.stringsAreEqual(inRgdSeq.getForwardSeq(), forward) ||
                !Utils.stringsAreEqual(inRgdSeq.getReverseSeq(), reverse) ) {

                inRgdSeq.setForwardSeq(forward);
                inRgdSeq.setReverseSeq(reverse);
                seqDao.updatePrimerPairs(inRgdSeq);
            }
        }
    }
}