package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.SequenceDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainDao;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.Sequence;
import edu.mcw.rgd.web.HttpRequestFacade;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Feb 5, 2012
 * Time: 8:59:47 AM
 */
public class SequenceEditObjectController extends EditObjectController {

    public String getViewUrl() throws Exception {
       return "editSequence.jsp";
    }

    public Object getObject(int rgdId) throws Exception{
        List<Sequence> sequences = new SequenceDAO().getObjectSequences(rgdId);
        if( sequences.isEmpty() )
            return null;
        else
            return sequences.get(0);
    }
    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }
    public Object newObject() throws Exception{
        return new Sequence();
    }

    public int getObjectTypeKey() {
        return RgdId.OBJECT_KEY_SEQUENCES;
    }

    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        SequenceDAO dao = new SequenceDAO();
        int seqRgdId = Integer.parseInt(req.getParameter("rgdId"));
        List<Sequence> seqs = dao.getObjectSequences(seqRgdId);

        if( seqs.size()>0 ) {
            Sequence seq = seqs.get(0);
            seq.setCloneSeq(req.getParameter("sequence"));

            if (persist) {
                dao.updateSeqClone(seqRgdId, seq.getCloneSeq());
            }
        }

        return seqs.get(0);
    }
}