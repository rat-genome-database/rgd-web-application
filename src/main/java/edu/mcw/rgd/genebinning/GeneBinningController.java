package edu.mcw.rgd.genebinning;

import edu.mcw.rgd.dao.impl.GeneBinAssigneeDAO;
import edu.mcw.rgd.dao.impl.GeneBinDAO;
import edu.mcw.rgd.datamodel.GeneBin.GeneBinAssignee;
import edu.mcw.rgd.security.User;
import edu.mcw.rgd.security.UserManager;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

public class GeneBinningController implements Controller {

    private final GeneBinAssigneeDAO geneBinAssigneeDAO;
    private final GeneBinDAO geneBinDAO;

    public GeneBinningController() {
        geneBinAssigneeDAO = new GeneBinAssigneeDAO();
        geneBinDAO = new GeneBinDAO();
    }

    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        String accessToken = httpServletRequest.getParameter("accessToken");
        String sessionId = httpServletRequest.getParameter("sessionId");
        String newSession = httpServletRequest.getParameter("newSession");
        String deleteSession = httpServletRequest.getParameter("deleteSession");
        String renameFrom = httpServletRequest.getParameter("renameFrom");
        String renameTo = httpServletRequest.getParameter("renameTo");

        User u = UserManager.getInstance().getUser(accessToken);
        String username = (u != null) ? u.getUsername() : null;

        String message = null;

        // Create a new binning session on demand, then make it the selected one
        if (newSession != null && !newSession.trim().isEmpty()) {
            newSession = newSession.trim();
            if (geneBinAssigneeDAO.sessionExists(newSession)) {
                message = "A session named '" + newSession + "' already exists.";
                sessionId = newSession;
            } else {
                // Seed the new session's bin definitions. Prefer copying from the template session;
                // fall back to any existing session; if the table is empty, bootstrap from the ontology.
                List<String> existing = geneBinAssigneeDAO.getSessions();
                String template = null;
                if (existing.contains(GeneBinAssigneeDAO.TEMPLATE_SESSION)) {
                    template = GeneBinAssigneeDAO.TEMPLATE_SESSION;
                } else if (!existing.isEmpty()) {
                    template = existing.get(0);
                }
                if (template != null) {
                    geneBinAssigneeDAO.createSession(newSession, template);
                } else {
                    new PerformBinningController().seedSessionFromOntology(newSession);
                }
                sessionId = newSession;
                message = "Created session '" + newSession + "'.";
            }
        }

        // Rename a session (moves both genes and bin definitions)
        if (renameFrom != null && !renameFrom.trim().isEmpty()
                && renameTo != null && !renameTo.trim().isEmpty()) {
            renameFrom = renameFrom.trim();
            renameTo = renameTo.trim();
            if (renameFrom.equals(GeneBinAssigneeDAO.TEMPLATE_SESSION)) {
                message = "The '" + GeneBinAssigneeDAO.TEMPLATE_SESSION + "' template session cannot be renamed.";
                sessionId = renameFrom;
            } else if (renameTo.equals(renameFrom)) {
                sessionId = renameFrom;
            } else if (geneBinAssigneeDAO.sessionExists(renameTo)) {
                message = "Cannot rename: a session named '" + renameTo + "' already exists.";
                sessionId = renameFrom;
            } else {
                geneBinDAO.renameSession(renameFrom, renameTo);
                geneBinAssigneeDAO.renameSession(renameFrom, renameTo);
                sessionId = renameTo;
                message = "Renamed '" + renameFrom + "' to '" + renameTo + "'.";
            }
        }

        // Delete a session (both genes and bin definitions)
        if (deleteSession != null && !deleteSession.trim().isEmpty()) {
            deleteSession = deleteSession.trim();
            if (deleteSession.equals(GeneBinAssigneeDAO.TEMPLATE_SESSION)) {
                message = "The '" + GeneBinAssigneeDAO.TEMPLATE_SESSION + "' template session cannot be deleted.";
                sessionId = deleteSession;
            } else {
                geneBinDAO.deleteAllGeneBins(deleteSession);
                geneBinAssigneeDAO.deleteSession(deleteSession);
                message = "Deleted session '" + deleteSession + "'.";
                if (deleteSession.equals(sessionId)) {
                    sessionId = null;
                }
            }
        }

        List<String> sessions = geneBinAssigneeDAO.getSessions();

        // peptidase count drives the >15 branching on the landing page; only meaningful once a session is chosen
        GeneBinAssignee pepDetail = null;
        if (sessionId != null && !sessionId.isEmpty()) {
            List<GeneBinAssignee> peps = geneBinAssigneeDAO.getAssigneeName("GO:0008233", sessionId);
            if (!peps.isEmpty()) {
                pepDetail = peps.get(0);
            }
        }

        ModelMap model = new ModelMap();
        model.put("pepDetail", pepDetail);
        model.put("sessions", sessions);
        model.put("sessionId", sessionId);
        model.put("message", message);
        model.put("username", username);
        model.put("accessToken", accessToken);
        model.put("binLimit", PerformBinningController.BIN_LIMIT);
        return new ModelAndView("/WEB-INF/jsp/curation/gene_binning/index.jsp","model", model);
    }
}
