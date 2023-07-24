package edu.mcw.rgd.genebinning;

import edu.mcw.rgd.dao.impl.GeneBinAssigneeDAO;
import edu.mcw.rgd.datamodel.GeneBin.GeneBinAssignee;
import edu.mcw.rgd.security.User;
import edu.mcw.rgd.security.UserManager;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

public class GeneBinningController implements Controller {

    private GeneBinAssigneeDAO geneBinAssigneeDAO;

    public GeneBinningController() {
        geneBinAssigneeDAO = new GeneBinAssigneeDAO();
    }

    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
        GeneBinAssigneeDAO geneBinAssigneeDAO = new GeneBinAssigneeDAO();
        GeneBinAssignee pepDetail = geneBinAssigneeDAO.getAssigneeName("GO:0008233").get(0);

        User u = UserManager.getInstance().getUser(httpServletRequest.getParameter("accessToken"));
        String username = u.getUsername();

        ModelMap model = new ModelMap();
        model.put("pepDetail", pepDetail);
        model.put("username", username);
        model.put("accessToken", httpServletRequest.getParameter("accessToken"));
        return new ModelAndView("/WEB-INF/jsp/curation/gene_binning/index.jsp","model", model);
    }
}
