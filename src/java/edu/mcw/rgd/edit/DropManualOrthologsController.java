package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.OrthologDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.Ortholog;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.process.Utils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 3/19/13
 * Time: 4:08 PM
 */
public class DropManualOrthologsController implements Controller {

    OrthologDAO odao = new OrthologDAO();
    GeneDAO gdao = new GeneDAO();
    RGDManagementDAO rdao = new RGDManagementDAO();

    java.util.Map<Integer, Gene> geneMap = new HashMap<Integer, Gene>();
    java.util.Map<Integer, RgdId> rgdIdMap = new HashMap<Integer, RgdId>();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse httpServletResponse) throws Exception {

        DropManualOrthologsBean bean = new DropManualOrthologsBean();

        // load ortholog types
        bean.setOrthologTypeMap(odao.getOrthologTypes());

        // gene symbol filter
        String filter = request.getParameter("filter");
        if( filter==null )
            filter = "";
        else
            filter = filter.toLowerCase();
        bean.setFilter(filter);

        // handle ortholog deletion
        bean.addMsg(deleteOrtholog(request.getParameter("delKey")));


        // load all orthologs, including ortholog with inactive genes
        boolean includeInactive = true;
        List<Ortholog> orthos = odao.getOrthologs("RGD", includeInactive);
        List<DropManualOrthologsBean.OrthologInfo> orthologInfos = new ArrayList<DropManualOrthologsBean.OrthologInfo>();

        if( filter.isEmpty() ) {
            bean.addMsg("There are "+orthos.size()+" manual orthologs; please set a gene symbol filter!");
        }
        else
        {
            // convert Ortholog objects into OrthologInfo objects while observing gene symbol filter
            for( Ortholog o: orthos ) {
                Gene g1 = getGene(o.getSrcRgdId());
                Gene g2 = getGene(o.getDestRgdId());
                String lcSymbol1 = g1.getSymbol().toLowerCase();
                String lcSymbol2 = g2.getSymbol().toLowerCase();
                if( !filter.isEmpty() && !lcSymbol1.contains(filter) && !lcSymbol2.contains(filter) )
                    continue;

                DropManualOrthologsBean.OrthologInfo info = bean.createInfo(o);
                info.sourceGene = g1;
                info.destGene = g2;
                info.sourceRgdId = getRgdId(o.getSrcRgdId());
                info.destRgdId = getRgdId(o.getDestRgdId());
                orthologInfos.add(info);
            }

            if( orthologInfos.isEmpty() ) {
                // after applying the filter, no manual orthologs are found
                bean.addMsg("No manual orthologs matching filter '"+filter+"'. Filter must be part of gene symbol.");
            }
            else {
                // sort results by gene symbol
                Collections.sort(orthologInfos, new Comparator<DropManualOrthologsBean.OrthologInfo>() {
                    public int compare(DropManualOrthologsBean.OrthologInfo o1, DropManualOrthologsBean.OrthologInfo o2) {
                        return Utils.stringsCompareToIgnoreCase(o1.sourceGene.getSymbol(), o2.sourceGene.getSymbol());
                    }
                });
            }
        }
        bean.setInfos(orthologInfos);

        String page = "/WEB-INF/jsp/curation/edit/dropManualOrthologs.jsp";
        ModelAndView mv = new ModelAndView(page);
        mv.addObject("bean", bean);
        return mv;
    }

    Gene getGene(int rgdId) throws Exception {
        Gene gene = geneMap.get(rgdId);
        if( gene==null ) {
            gene = gdao.getGene(rgdId);
            geneMap.put(rgdId, gene);
        }
        return gene;
    }

    RgdId getRgdId(int rgdId) throws Exception {
        RgdId id = rgdIdMap.get(rgdId);
        if( id==null ) {
            id = rdao.getRgdId2(rgdId);
            rgdIdMap.put(rgdId, id);
        }
        return id;
    }

    String deleteOrtholog(String delKey) throws Exception {
        if( delKey!=null ) {
            int key = Integer.parseInt(delKey);
            Ortholog o = odao.getOrthologByKey(key);
            if( o==null )
                return "Error! Can't find ortholog with key "+key;

            List<Ortholog> list = new ArrayList<Ortholog>(1);
            list.add(o);
            odao.deleteOrthologs(list);
            return "Success! Deleted ortholog with SRC_RGD_ID="+o.getSrcRgdId()+" and DEST_RGD_ID="+o.getDestRgdId()+"; XREF_DATA_SRC="+o.getXrefDataSrc();
        }
        return null;
    }
}
