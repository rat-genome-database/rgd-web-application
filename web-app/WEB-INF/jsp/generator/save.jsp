<%@ page import="edu.mcw.rgd.dao.impl.RGDUserDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.RGDUser" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.RGDUserList" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.util.Iterator" %>

<%

    int mapKey=Integer.parseInt(request.getParameter("mapKey"));
    String genes = request.getParameter("genes");
    String listName=request.getParameter("listName");
    int objectType=Integer.parseInt(request.getParameter("oKey"));

    List resultSet = (List) request.getAttribute("resultSet");
    Iterator it = resultSet.iterator();
    while (it.hasNext()) {
        out.println("<br> " + (String) it.next());
    }

    if (objectType == 1) {
        GeneDAO gdao = new GeneDAO();
        //gdao.getActiveMappedGenes(mapKey)

    }else if (objectType == 6) {


    }else if (objectType == 5) {


    }

    List<Integer> geneList = new ArrayList<Integer>();

    RGDUserDAO ruDAO = new RGDUserDAO();
    RGDUser user = null;

    Cookie[] cookies = request.getCookies();

    //set a cookie for this user
    boolean foundCookie = false;
    for(int i = 0; i < cookies.length; i++) {
         Cookie c = cookies[i];
         if (c.getName().equals("userId")) {
             try {
                user = ruDAO.getUser(Integer.parseInt(c.getValue()));
                foundCookie = true;
             }catch (Exception e) {

             }
         }
     }

    if (!foundCookie) {
        user = ruDAO.insertRGDUser();
        Cookie c = new Cookie("userId", user.getUserId() + "");
        c.setMaxAge(24*60*60);
        response.addCookie(c);
    }


   // geneList.add(2004);
   // geneList.add(3001);

    edu.mcw.rgd.datamodel.RGDUserList existingList = null;

    try {
      existingList = ruDAO.getUserList(listName);
      ruDAO.deleteUserList(existingList);
    } catch (Exception e) {

    }

    int listId = ruDAO.insertRGDUserList(user.getUserId(), objectType,mapKey, listName, geneList);

    List<RGDUserList> lists = ruDAO.getUserLists(user.getUserId());

    if (lists.size() > 0) {
        %>
        <table>
            <tr>
                <td>
                    My RGD Lists
                </td>
            </tr>

        <% for (RGDUserList lst: lists) { %>
           <tr><td><%=lst.getListName()%></td></tr>

           <%
            List<Integer> ids = ruDAO.getUserListObjects(lst.getListId());
            for (Integer id: ids) {
        %>
            <tr>
            <td><%=id%></td>
            </tr>
        <% }
        }
        %>
        </table>
 <% } %>
