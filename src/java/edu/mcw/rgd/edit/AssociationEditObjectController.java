package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.Association;
import edu.mcw.rgd.datamodel.Identifiable;
import edu.mcw.rgd.edit.association.AssociationUpdate;
import org.springframework.web.servlet.mvc.Controller;

import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 */

public abstract class AssociationEditObjectController implements Controller {

    protected void updateAssociations(int rgdId, String[] associations, AssociationUpdate updater) throws Exception {


        if (associations == null) {
            associations = new String[0];
        }

        // gets list of either Identifiables or Associations
        List currAcc = updater.get(rgdId);

        for (String association : associations) {

            association = association.trim();
            if (association.equals("")) {
                continue;
            }

            Iterator it = currAcc.iterator();
            boolean found = false;
            while (it.hasNext()) {
                int assocRgdId = getRgdIdForAssociatedObject(it.next());
                if (Integer.parseInt(association) == assocRgdId) {
                    found = true;
                }
            }

            if (!found) {
                updater.insert(rgdId, Integer.parseInt(association));
            }
        }

        for (Object aCurrAcc : currAcc) {
            int assocRgdId = getRgdIdForAssociatedObject(aCurrAcc);
            boolean found = false;

            for (String association : associations) {

                String assoc = association.trim();
                if (assoc.equals("")) {
                    continue;
                }

                if (Integer.parseInt(assoc) == assocRgdId) {
                    found = true;
                }
            }

            if (!found) {
                updater.remove(rgdId, assocRgdId);
            }
        }
    }

    int getRgdIdForAssociatedObject(Object o) {
        int assocRgdId = 0;
        if( o instanceof Association ) {
            assocRgdId = ((Association)o).getDetailRgdId();
        } else if( o instanceof Identifiable ) {
            assocRgdId = ((Identifiable)o).getRgdId();
        }
        return assocRgdId;
    }
}