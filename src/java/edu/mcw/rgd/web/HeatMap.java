package edu.mcw.rgd.web;

import java.util.TreeMap;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 9/24/12
 * Time: 9:45 AM
 * To change this template use File | Settings | File Templates.
 */
public class HeatMap {

    private int cellWidth=24;
    private int headerHeight=300;
    private int cellFontSize=9;
    private int maxValue=33;

    private int[][] mapData = null;
    private String[][] mapToolTips = null;

    private TreeMap xAxis = new TreeMap();
    private TreeMap yAxis = new TreeMap();

    private int yAxisSelectedIndex = 1;
    private int xAxisSelectedIndex = 2;


    public int getCellWidth() {
        return cellWidth;
    }

    public void setCellWidth(int cellWidth) {
        this.cellWidth = cellWidth;
    }

    public int getHeaderHeight() {
        return headerHeight;
    }

    public void setHeaderHeight(int headerHeight) {
        this.headerHeight = headerHeight;
    }

    public int getCellFontSize() {
        return cellFontSize;
    }

    public void setCellFontSize(int cellFontSize) {
        this.cellFontSize = cellFontSize;
    }

    public int getMaxValue() {
        return maxValue;
    }

    public void setMaxValue(int maxValue) {
        this.maxValue = maxValue;
    }

    public int[][] getMapData() {
        return mapData;
    }

    public void setMapData(int[][] mapData) {
        this.mapData = mapData;
    }

    public String[][] getMapToolTips() {
        return mapToolTips;
    }

    public void setMapToolTips(String[][] mapToolTips) {
        this.mapToolTips = mapToolTips;
    }

    public TreeMap getxAxis() {
        return xAxis;
    }

    public void setxAxis(TreeMap xAxis) {
        this.xAxis = xAxis;
    }

    public TreeMap getyAxis() {
        return yAxis;
    }

    public void setyAxis(TreeMap yAxis) {
        this.yAxis = yAxis;
    }

    public int getyAxisSelectedIndex() {
        return yAxisSelectedIndex;
    }

    public void setyAxisSelectedIndex(int yAxisSelectedIndex) {
        this.yAxisSelectedIndex = yAxisSelectedIndex;
    }

    public int getxAxisSelectedIndex() {
        return xAxisSelectedIndex;
    }

    public void setxAxisSelectedIndex(int xAxisSelectedIndex) {
        this.xAxisSelectedIndex = xAxisSelectedIndex;
    }
}
