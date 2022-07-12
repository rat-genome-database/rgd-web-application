package edu.mcw.rgd.phenominer.elasticsearch.service;

import com.google.gson.Gson;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;


import java.awt.*;
import java.util.*;
import java.util.List;

public class Colors {
   public static final Map<Integer, String> colors;
    static{

            colors = new HashMap<>();
            for (int i = 0; i < 300; i++) {
                Random rand = new Random();
                float r = rand.nextFloat();
                float g = rand.nextFloat();
                float b = rand.nextFloat();
                Color randomColor = new Color(r, g, b);
                String color = "rgb(" + (randomColor.brighter().getRed()) + "," + (randomColor.brighter().getGreen()) + "," + (randomColor.brighter().getBlue()) + "," + 0.5 +")";
               colors.put(i, color);

            }



    }




}
