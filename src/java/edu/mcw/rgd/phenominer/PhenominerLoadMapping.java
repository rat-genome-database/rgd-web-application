package edu.mcw.rgd.phenominer;

/**
 * Created by IntelliJ IDEA. <br>
 * User: mtutaj <br>
 * Date: 7/18/11 <br>
 * Time: 1:06 PM <br>
 * To change this template use File | Settings | File Templates.
 * <p/>
 * represents a mapping stored during pga load in table PGALOAD_MAPPINGS
 */
public class PhenominerLoadMapping {

    private String type;
    private String name;
    private String value;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
