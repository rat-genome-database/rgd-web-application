package edu.mcw.rgd.web;

import org.apache.commons.logging.LogFactory;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 8/28/12
 * Time: 11:57 AM
 * <p>
 * contains information global for the application
 */
public class RgdContext {

    private static boolean isCurator; // true iff host is KYLE or HASTINGS
    private static boolean isProduction; // true iff host is HORAN/HANCOCK or OSLER/OWEN
    private static String hostname;


    public static String getLongSiteName(ServletRequest request) {
        if (RgdContext.isChinchilla(request)) {
            return "Chinchilla Research Resource Database";
        }else {
            return "Rat Genome Database";
        }
    }


    public static String getSiteName(ServletRequest request) {
        if (RgdContext.isChinchilla(request)) {
            return "CRRD";
        }else {
            return "RGD";
        }
    }


    public static boolean isChinchilla(ServletRequest request) {
        boolean isChin = (Boolean) request.getAttribute("isChin");
        return isChin;
    }

    public static void setChinchilla(ServletRequest request) throws UnknownHostException {
        LogFactory.getLog(RgdContext.class).debug("RgdContext.setChinchilla "+request.getServerName()+", "+request.toString());
        boolean isChin = (request.getServerName().contains("ngc.mcw.edu") || request.getServerName().contains("crrd.mcw.edu"));
        //|| InetAddress.getLocalHost().getHostName().toLowerCase().contains("rgd-27p8tr1");
        request.setAttribute("isChin", isChin);
    }

    static void parseHostName() throws UnknownHostException {
        if( hostname!=null )
            return;
        try {

            InetAddress addr = InetAddress.getLocalHost();

            hostname = addr.getHostName().toLowerCase();
            isCurator = hostname.contains("kyle") || hostname.contains("hastings") || hostname.contains("rgd-27p8tr1");
            isProduction = hostname.contains("horan") || hostname.contains("osler") || hostname.contains("hancock") || hostname.contains("owen");
            //System.out.println("RgdContext: HOSTNAME="+hostname);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static boolean isCurator() throws UnknownHostException {
        parseHostName();
        return isCurator;
    }

    public static boolean isProduction() throws UnknownHostException {
        parseHostName();
        return isProduction;
    }
}
