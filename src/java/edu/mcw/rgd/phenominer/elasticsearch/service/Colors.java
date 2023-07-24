package edu.mcw.rgd.phenominer.elasticsearch.service;

import java.awt.*;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

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
