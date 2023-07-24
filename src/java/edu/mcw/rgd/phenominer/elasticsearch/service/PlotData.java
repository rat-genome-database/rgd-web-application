package edu.mcw.rgd.phenominer.elasticsearch.service;

import java.util.List;
import java.util.Map;

public class PlotData {
    private String label;
    private List<Double> data;
    private String backgroundColor;
    private String borderColor;
    private int borderWidth;
    private Map<String, Map<String, Integer>> errorBars;/*: {
        'January': {plus: 15, minus: 34},
        'February': {plus: 15, minus: 3},
        'March': {plus: 35, minus: 14},
        'April': {plus: 45, minus: 4}
    }*/
    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public List<Double> getData() {
        return data;
    }

    public void setData(List<Double> data) {
        this.data = data;
    }

    public String getBackgroundColor() {
        return backgroundColor;
    }

    public void setBackgroundColor(String backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    public String getBorderColor() {
        return borderColor;
    }

    public void setBorderColor(String borderColor) {
        this.borderColor = borderColor;
    }

    public int getBorderWidth() {
        return borderWidth;
    }

    public void setBorderWidth(int borderWidth) {
        this.borderWidth = borderWidth;
    }

    public Map<String, Map<String, Integer>> getErrorBars() {
        return errorBars;
    }

    public void setErrorBars(Map<String, Map<String, Integer>> errorBars) {
        this.errorBars = errorBars;
    }
}
