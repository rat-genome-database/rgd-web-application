package edu.mcw.rgd.edit;

import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.web.HttpRequestFacade;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;
import java.util.Date;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class NotesEditObjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        HttpRequestFacade req = new HttpRequestFacade(request);

        String[] keys = request.getParameterValues("notesKey");
        String[] deleteKeys = request.getParameterValues("notesDelete");

        if (keys == null) {
            keys = new String[0];
        }

        if (deleteKeys == null) {
            deleteKeys = new String[0];
        }

        String[] refKeys = request.getParameterValues("notesRefKey");
        String[] types = request.getParameterValues("notesTypeName");
        String[] notes = request.getParameterValues("notesNotes");
        String[] publics = request.getParameterValues("notesIsPublic");


        NotesDAO ndao = new NotesDAO();

        for (int i = 0; i < keys.length; i++) {
            boolean found = false;
            for (int j=0; j< deleteKeys.length; j++) {
                if (deleteKeys[j].equals(keys[i])) {
                    found=true;
                }
            }

            if (found) continue;

            Note note = null;
            if (keys[i].equals("0")) {
                note = new Note();
                note.setRgdId(Integer.parseInt(request.getParameter("rgdId")));
            }else {
                note = ndao.getNoteByKey(Integer.parseInt(keys[i]));
            }

            note.setNotesTypeName(types[i]);
            note.setNotes(notes[i]);
            note.setPublicYN(publics[i]);
                                                                       
            if (refKeys[i] != null && !refKeys[i].equals("")) {
                note.setRefId(Integer.parseInt(refKeys[i]));
            }else {
                note.setRefId(null);
            }

            ndao.updateNote(note);
        }

        //delete other notes

        if (keys == null) {
            status.add("0 Note Keys Found");
            keys = new String[0];
        }

        for (int i = 0; i < deleteKeys.length; i++) {
            ndao.deleteNote(Integer.parseInt(deleteKeys[i]));
        }


        status.add("Update Successfull");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }



}