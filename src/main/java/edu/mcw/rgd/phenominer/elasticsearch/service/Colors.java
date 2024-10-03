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
            int numColors=300;
            colors = new HashMap<>();
            for (int i = 0; i < 300; i++) {
                int r = (i * 255 / numColors) % 256; // Vary Red
                int g = ((i * 130) % 256);            // Vary Green
                int b = ((i * 50) % 256);             // Vary Blue

                // Create color and add to the list
                Color randomColor = new Color(r, g, b);
                String color = "rgb(" + (randomColor.brighter().getRed()) + "," + (randomColor.brighter().getGreen()) + "," + (randomColor.brighter().getBlue()) + "," + 0.5 +")";
               colors.put(i, color);

            }



    }




}
