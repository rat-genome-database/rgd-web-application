package edu.mcw.rgd.webservice;

import com.google.gson.*;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.MyDAO;
import edu.mcw.rgd.datamodel.*;

import edu.mcw.rgd.datamodel.myrgd.MyList;
import edu.mcw.rgd.process.mapping.ObjectMapper;

import edu.mcw.rgd.security.UserManager;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 9/26/13
 * Time: 12:49 PM
 */
public class MyRgdServiceController implements Controller {

    //private HttpServletRequest request = null;
    //private HttpServletResponse response = null;
    //private HashMap watched = new HashMap();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String methodParam = request.getParameter("method");
        if (methodParam != null) {
            try {

                Method method = this.getClass().getMethod(methodParam, HttpServletRequest.class, HttpServletResponse.class);
                method.invoke(this, request, response);

            } catch (InvocationTargetException e) {
                e.getTargetException().printStackTrace();
            }
        }

        return null;
    }
    public void logout(HttpServletRequest request, HttpServletResponse response) throws Exception {
        UserManager.getInstance().myLogout(request);
    }

    public void addWatcher(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String user = UserManager.getInstance().getMyUser(request).getUsername();

        HashMap watched= new HashMap();
        if(user!=null) {
            MyDAO mdao = new MyDAO();

            JsonParser parser = new JsonParser();
            JsonObject obj = (JsonObject) parser.parse(request.getReader());

            JsonElement elm = obj.get("rgdId");

            if (isRgdId(elm.getAsString())) {
                //Integer rgdId = elm.getAsInt();

                JsonArray arr = obj.getAsJsonArray("geneWatchAttributes");

                //HashMap itemsToWatch = new HashMap();
                Iterator it = arr.iterator();
                while (it.hasNext()) {
                    JsonPrimitive jobj = (JsonPrimitive) it.next();

                    watched.put(jobj.getAsString(), null);

                }

                mdao.insertOrUpdateObjectWatcher(user, elm.getAsInt(), exists(WatchedObject.NOMEN_LABEL, watched),
                        exists(WatchedObject.GO_LABEL, watched), exists(WatchedObject.DISEASE_LABEL, watched), exists(WatchedObject.PHENOTYPE_LABEL, watched),
                        exists(WatchedObject.PATHWAY_LABEL, watched), exists(WatchedObject.STRAIN_LABEL, watched), exists(WatchedObject.REFERENCE_LABEL, watched), false,
                        exists(WatchedObject.PROTEIN_LABEL, watched), exists(WatchedObject.INTERACTION_LABEL, watched), exists(WatchedObject.REFSEQ_STATUS_LABEL, watched), exists(WatchedObject.EXDB_LABEL, watched));

            } else {
                JsonArray arr = obj.getAsJsonArray("geneWatchAttributes");

                //HashMap itemsToWatch = new HashMap();
                Iterator it = arr.iterator();
                while (it.hasNext()) {

                    JsonPrimitive jobj = (JsonPrimitive) it.next();

                    watched.put(jobj.getAsString(), null);

                }

                mdao.insertOrUpdateTermWatcher(user, elm.getAsString(), exists(WatchedTerm.GENES_RAT_LABEL, watched), exists(WatchedTerm.GENES_MOUSE_LABEL, watched),
                        exists(WatchedTerm.GENES_HUMAN_LABEL, watched), exists(WatchedTerm.QTLS_RAT_LABEL, watched), exists(WatchedTerm.QTLS_MOUSE_LABEL, watched), exists(WatchedTerm.QTLS_HUMAN_LABEL, watched),
                        exists(WatchedTerm.STRAINS_LABEL, watched), exists(WatchedTerm.VARIANTS_RAT_LABEL, watched));

            }
        }
    }

    private boolean exists(String value, HashMap watched) {

        if (watched.containsKey(value)) {
            return true;
        }else {
            return false;
        }

    }

    private boolean isRgdId(String id) {
        try {
            Integer.parseInt(id);
            return true;
        }catch (Exception e) {
            return false;
        }

    }

    public void removeWatcher(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String user = UserManager.getInstance().getMyUser(request).getUsername();

        MyDAO mdao = new MyDAO();
        if(user!=null) {
            JsonParser parser = new JsonParser();
            JsonObject obj = (JsonObject) parser.parse(request.getReader());

            JsonElement elm = obj.get("rgdId");

            if (isRgdId(elm.getAsString())) {
                mdao.removeObjectWatcher(user, elm.getAsInt());
            } else {
                mdao.removeTermWatcher(user, elm.getAsString());
            }


            HashMap returnMap = new HashMap();
            List<WatchedObject> woList = mdao.getWatchedObjects(user);

            returnMap.put("objects", woList);

            List<WatchedTerm> tList = mdao.getWatchedTerms(user);
            returnMap.put("terms", tList);

            Gson gson = new Gson();
            response.getWriter().print(gson.toJson(returnMap));
        }
    }

    public void getAllWatchedObjects(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String user = UserManager.getInstance().getMyUser(request).getUsername();

        if(user!=null) {
        HashMap returnMap = new HashMap();

        MyDAO mdao = new MyDAO();
        List<WatchedObject> woList = mdao.getWatchedObjects(user);

        returnMap.put("objects", woList);

        List<WatchedTerm> tList = mdao.getWatchedTerms(user);

        returnMap.put("terms", tList);
        returnMap.put("messageCount", mdao.getAllMessagesFromMessageCenterWithoutPayload(user).size());

        Gson gson = new Gson();

        response.getWriter().print(gson.toJson(returnMap));
    }
    }

    private void getObjectWatchers( HttpServletResponse response, int rgdId, String username) throws Exception {

        MyDAO mdao = new MyDAO();
        List<WatchedObject> wo = mdao.getWatchedObjects(username,rgdId);

        Gson gson = new Gson();

        HashMap returnMap = new HashMap();
        if (wo.size()==0) {
            //returnMap.put("selected", new ArrayList());
        }else {
            returnMap.put("selected", wo.get(0).getActiveWatchedLabels());
        }

        returnMap.put("all",WatchedObject.getAllWatchedLabels());
        response.getWriter().print(gson.toJson(returnMap));
    }

    private void getTermWatchers(HttpServletResponse response, String accId, String username) throws Exception {
        MyDAO mdao = new MyDAO();
        List<WatchedTerm> wo = mdao.getWatchedTerms(username,accId);

        Gson gson = new Gson();

        HashMap returnMap = new HashMap();

        if (wo.size()==0) {
        }else {
            returnMap.put("selected", wo.get(0).getActiveWatchedLabels());
        }
        returnMap.put("all",WatchedTerm.getAllWatchedLabels());

        response.getWriter().print(gson.toJson(returnMap));
    }

    public void getWatchers(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String user = UserManager.getInstance().getMyUser(request).getUsername();

        if(user!=null) {
            if (user.equals("anonymousUser")) {
                return;
            }

            JsonParser parser = new JsonParser();

            JsonObject obj = (JsonObject) parser.parse(request.getReader());
            JsonElement elm = obj.get("rgdId");

            if (elm == null) {
                return;
            }

            String id = elm.getAsString();

            //int rgdId = 0;
            try {
                getObjectWatchers(response, Integer.parseInt(id), user);
            } catch (Exception e) {
                getTermWatchers(response, id, user);

            }
        }
    }

    public void getUsername(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String user = UserManager.getInstance().getMyUser(request).getUsername();

        if(user!=null)
        response.getWriter().println(user);
    }

    public void getLists(HttpServletRequest request, HttpServletResponse response) throws Exception {

        try {

            String user = UserManager.getInstance().getMyUser(request).getUsername();

            if(user!=null) {
                String name = user;

                Gson gson = new Gson();
                MyDAO mydao = new MyDAO();
                List<MyList> myLists = mydao.getUserObjectLists(name);

                response.getWriter().print(gson.toJson(myLists));
            }
        }catch (Exception e)  {
            response.getWriter().println(e.getMessage());
        }

    }

    public void removeList(HttpServletRequest request, HttpServletResponse response) throws Exception {

        try {

            int listId = Integer.parseInt(request.getParameter("lid"));

            String user = UserManager.getInstance().getMyUser(request).getUsername();

            if(user!=null) {
                String name = user;

                //Gson gson = new Gson();
                MyDAO mydao = new MyDAO();

                MyList myList = mydao.getUserObjectList(listId);

                if (!myList.getUsername().equals(name)) {
                    throw new Exception("Permission Denied");
                }

                mydao.deleteUserObjectList(listId);
            }
        }catch (Exception e)  {
            response.getWriter().println(e.getMessage());
        }

    }

    public void getGenes(HttpServletRequest request, HttpServletResponse response) throws Exception {

        try {

            int listId = Integer.parseInt(request.getParameter("lid"));

            String user = UserManager.getInstance().getMyUser(request).getUsername();

            if (user != null) {
                String name = user;

                Gson gson = new Gson();


                MyDAO mydao = new MyDAO();

                MyList myList = mydao.getUserObjectList(listId);

                if (!myList.getUsername().equals(name)) {
                    throw new Exception("Permission Denied");
                }

                List<Gene> genes = mydao.getGenes(listId);

                response.getWriter().print(gson.toJson(genes));
            }
            }catch(Exception e){
                response.getWriter().println(e.getMessage());
            }

    }


    public void saveList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JsonParser parser = new JsonParser();

        JsonObject obj = (JsonObject) parser.parse(request.getReader());
        String name = obj.get("name").getAsString();
        String action = obj.get("action").getAsString();
        String desc = obj.get("desc").getAsString();
        String link = obj.get("url").getAsString();
        JsonArray genes = obj.get("genes").getAsJsonArray();

        String user = UserManager.getInstance().getMyUser(request).getUsername();


        if (user == null) {
            response.getWriter().print("Error - user anonymous");
            return;
        }
        if (user!=null) {
            MyDAO mdao = new MyDAO();
            MyList mList = new MyList();

            mList.setUsername(user);
            mList.setObjectType(1);
            mList.setName(name);
            mList.setDesc(desc);
            mList.setLink(link);

            mdao.insertList(mList);

            //GeneDAO gdao = new GeneDAO();

            ArrayList<String> sym = new ArrayList<String>();

            Iterator it = genes.iterator();
            while (it.hasNext()) {
                JsonObject gene = (JsonObject) it.next();
                sym.add(gene.get("gene").getAsString());
            }

            ObjectMapper om = new ObjectMapper();

            om.mapSymbols(sym, 3);

            List<Integer> ids = om.getMappedRgdIds();

            mdao.insertGenes(mList.getId(), ids);
        }
    }

    public void getGeneList(HttpServletRequest request, HttpServletResponse response) throws Exception {

        try {
            JsonParser parser = new JsonParser();

            JsonObject obj = (JsonObject) parser.parse(request.getReader());
            String chr= obj.get("chr").getAsString();

            GeneDAO geneDAO = new GeneDAO();
            List<Gene> genes = geneDAO.getActiveGenesSortedBySymbol(chr,1000000,2000000,60);
            Gson gson = new Gson();

            response.getWriter().print(gson.toJson(genes));

        }catch (Exception e)  {
            e.printStackTrace();
            response.getWriter().println(e.getMessage());
        }

    }

    public void deleteMessageCenterMessage(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String user = UserManager.getInstance().getMyUser(request).getUsername();

        if(user!=null) {
            JsonParser parser = new JsonParser();

            JsonObject obj = (JsonObject) parser.parse(request.getReader());
            String messageId = obj.get("mid").getAsString();

            MyDAO mdao = new MyDAO();
            mdao.deleteMessageCenterMessage(Integer.parseInt(messageId), user);

            Gson gson = new Gson();

            response.getWriter().print(gson.toJson(mdao.getAllMessagesFromMessageCenterWithoutPayload(user)));
        }
    }

    public void getMessageCenterMessages(HttpServletRequest request, HttpServletResponse response) throws Exception {


        String user = UserManager.getInstance().getMyUser(request).getUsername();

        System.out.println("user in message center = " + user);

        if(user!=null) {
            Gson gson = new Gson();
            MyDAO mdao = new MyDAO();
            if (user != null)
                response.getWriter().print(gson.toJson(mdao.getAllMessagesFromMessageCenterWithoutPayload(user)));
        }
    }

    public void updateDigestSetting(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String user = UserManager.getInstance().getMyUser(request).getUsername();

        if(user!=null) {
            JsonParser parser = new JsonParser();

            JsonObject obj = (JsonObject) parser.parse(request.getReader());
            String digestString = obj.get("digest").getAsString();

            MyDAO mdao = new MyDAO();

            if (digestString.equals("true")) {
                mdao.updateDigest(user, true);
            } else {
                mdao.updateDigest(user, false);

            }

            Gson gson = new Gson();

            response.getWriter().print(gson.toJson(digestString));
        }
    }


}
