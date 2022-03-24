package edu.mcw.rgd.phenominer.elasticsearch.service;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;


import java.awt.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

public class Colors {
    public  Map<String, Color> colors;
    public Colors() throws Exception {
        OntologyXDAO xdao=new OntologyXDAO();
        Map<String, Color> colors=new HashMap<>();
        List<Term> xcoTerms=xdao.getAllActiveTermDescendants("XCO:0000000");
        for(Term t:xcoTerms) {
            Random rand = new Random();
            float r = rand.nextFloat();
            float g = rand.nextFloat();
            float b = rand.nextFloat();
            Color randomColor = new Color(r, g, b);
            colors.put(t.getOntologyId(), randomColor.brighter());
            this.colors=colors;
        }
    }

    public Map<String, Color> getColors() {
        return colors;
    }

    public void setColors(Map<String, Color> colors) {
        this.colors = colors;
    }
}
