package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.Ortholog;
import edu.mcw.rgd.datamodel.RgdId;

import java.util.List;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 7/31/13
 * Time: 9:34 AM
 */
public class DropManualOrthologsBean {

    private String filter; // gene symbol filter
    private List<OrthologInfo> infos;
    private String msg; // action message(s)
    private Map<Integer, String> orthologTypeMap;

    public String getFilter() {
        return filter;
    }

    public void setFilter(String filter) {
        this.filter = filter;
    }

    public List<OrthologInfo> getInfos() {
        return infos;
    }

    public void setInfos(List<OrthologInfo> infos) {
        this.infos = infos;
    }

    public String getMsg() {
        return msg;
    }

    public void addMsg(String msg) {
        if( msg==null )
            return;
        if( this.msg==null )
            this.msg = msg;
        else
            this.msg += "<br>" + msg;
    }

    public Map<Integer, String> getOrthologTypeMap() {
        return orthologTypeMap;
    }

    public void setOrthologTypeMap(Map<Integer, String> orthologTypeMap) {
        this.orthologTypeMap = orthologTypeMap;
    }

    public String getOrthologTypeName(int orthologTypeKey) {
        return orthologTypeMap.get(orthologTypeKey);
    }

    OrthologInfo createInfo(Ortholog o) {
        OrthologInfo info = new OrthologInfo();
        info.ortholog = o;
        return info;
    }

    public class OrthologInfo {
        public Ortholog ortholog;
        public Gene sourceGene;
        public Gene destGene;
        public RgdId sourceRgdId;
        public RgdId destRgdId;
    }
}
