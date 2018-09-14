package edu.mcw.rgd.edit.association;

import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Aug 3, 2009
 * Time: 1:42:25 PM
 */
public interface AssociationUpdate {
    public List get(int rgdId) throws Exception;
    public void insert(int objectRgdId, int associationRgdId ) throws Exception;
    public void remove(int associationRgdId, int objectRgdId) throws Exception;
}


