package edu.mcw.rgd.testplan;

import edu.mcw.rgd.dao.impl.TestPlanDAO;
import edu.mcw.rgd.datamodel.TestPlanItem;
import edu.mcw.rgd.web.RgdContext;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Site test plan for the PostgreSQL switch: every page and tool, who tests it, the result and the tester's sign-off.
 * GET shows the plan; POST applies one change (assign, take, status, notes, sign off, withdraw) and redirects back.
 * <p>
 * Changes need a GitHub sign-in by a member of rat-genome-database (the curation login), because the
 * curation interceptor does not check access on dev servers and the sign-off must record who signed.
 */
public class TestPlanController implements Controller {

    TestPlanDAO dao = new TestPlanDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String login = getLogin(request);

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String itemId = request.getParameter("itemId");
            String message = (login == null) ? "Sign in with GitHub to make changes." : applyChange(request, login, itemId);
            String back = request.getContextPath() + "/curation/testPlan.html";
            if (message != null) {
                back += "?msg=" + URLEncoder.encode(message, StandardCharsets.UTF_8);
            }
            if (itemId != null && itemId.matches("[a-z0-9-]+")) {
                back += "#" + itemId;
            }
            response.sendRedirect(back);
            return null;
        }

        List<TestPlanItem> items = dao.getItems();
        request.setAttribute("items", items);
        request.setAttribute("testers", dao.getTesters());
        request.setAttribute("login", login);
        request.setAttribute("signInUrl", RgdContext.getGithubOauthRedirectUrl());
        String historyFor = request.getParameter("history");
        if (historyFor != null) {
            request.setAttribute("historyFor", historyFor);
            request.setAttribute("history", dao.getHistory(historyFor));
        }
        return new ModelAndView("/WEB-INF/jsp/testplan/testPlan.jsp");
    }

    /**
     * @return a message for the page when the change was refused, or null when it was applied
     */
    String applyChange(HttpServletRequest request, String login, String itemId) throws Exception {
        TestPlanItem item = itemId == null ? null : dao.getItem(itemId);
        if (item == null) {
            return "That test item no longer exists.";
        }
        String action = request.getParameter("action");
        if (action == null) {
            return null;
        }
        switch (action) {
            case "assign": {
                String assignee = request.getParameter("assignee");
                dao.assign(itemId, (assignee == null || assignee.isEmpty()) ? null : assignee, login);
                return null;
            }
            case "take":
                if (item.getAssignee() != null) {
                    return "This item is already assigned.";
                }
                dao.assign(itemId, login, login);
                return null;
            case "status": {
                if (!login.equals(item.getAssignee())) {
                    return "Only the assigned tester can record a result.";
                }
                String status = request.getParameter("status");
                String notes = trimToNull(request.getParameter("notes"));
                if (("Failed".equals(status) || "Blocked".equals(status)) && notes == null && item.getNotes() == null) {
                    return status + " needs a note: the URL, the ID you used, and what went wrong.";
                }
                dao.setStatus(itemId, status, notes, login);
                return null;
            }
            case "notes":
                if (!login.equals(item.getAssignee())) {
                    return "Only the assigned tester can edit the notes.";
                }
                dao.setNotes(itemId, trimToNull(request.getParameter("notes")), login);
                return null;
            case "signoff":
                return dao.signOff(itemId, login) ? null : "Only the assigned tester can sign off, and only after the item has Passed.";
            case "withdraw":
                if (!login.equals(item.getSignedBy()) && !login.equals(item.getAssignee())) {
                    return "Only the tester who signed off can withdraw the sign-off.";
                }
                dao.withdrawSignOff(itemId, login);
                return null;
            default:
                return null;
        }
    }

    /**
     * GitHub login of the signed-in curator, or null. The login is kept in the session once checked;
     * otherwise the curation sign-in's accessToken cookie (or a token parameter) is checked with GitHub,
     * including membership of the rat-genome-database organization.
     */
    String getLogin(HttpServletRequest request) {
        String login = (String) request.getSession().getAttribute("login");
        if (login != null && !login.isEmpty() && !"rgd".equals(login)) {
            return login;
        }
        String token = request.getParameter("accessToken");
        if (token == null && request.getCookies() != null) {
            for (Cookie c : request.getCookies()) {
                if ("accessToken".equalsIgnoreCase(c.getName()) && !c.getValue().isEmpty()) {
                    token = c.getValue();
                }
            }
        }
        if (token == null || token.length() < 10) {
            return null;
        }
        try {
            login = new JSONObject(readGitHub("https://api.github.com/user", token)).getString("login");
            URL checkUrl = new URL("https://api.github.com/orgs/rat-genome-database/members/" + login);
            HttpURLConnection conn = (HttpURLConnection) checkUrl.openConnection();
            conn.setRequestProperty("User-Agent", "RGD");
            conn.setRequestProperty("Authorization", "Token " + token);
            if (conn.getResponseCode() != 204) {
                return null;
            }
            request.getSession().setAttribute("login", login);
            return login;
        } catch (Exception e) {
            return null;
        }
    }

    String readGitHub(String url, String token) throws Exception {
        HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
        conn.setRequestProperty("User-Agent", "RGD");
        conn.setRequestProperty("Authorization", "Token " + token);
        StringBuilder sb = new StringBuilder();
        try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = in.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    static String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        s = s.trim();
        return s.isEmpty() ? null : s;
    }
}
