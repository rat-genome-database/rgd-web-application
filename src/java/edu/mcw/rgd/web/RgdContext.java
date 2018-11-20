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
 * <p>
 * contains information global for the application
 */
public class RgdContext {

    private static boolean isCurator; // isPipelines() || isDev
    private static boolean isProduction; // true iff host is HANCOCK or OWEN
	private static boolean isPipelines; // true iff host is REED
	private static boolean isTest; // true iff host is IRVINE
	private static boolean isDev; // true iff host is HASTINGS
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
        request.setAttribute("isChin", isChin);
    }

    static void parseHostName() throws UnknownHostException {
        if( hostname!=null )
            return;
        try {

            hostname = InetAddress.getLocalHost().getHostName().toLowerCase();
			
            isProduction = hostname.contains("hancock") || hostname.contains("owen");
            isPipelines = hostname.contains("reed");
            isDev = hostname.contains("hastings") || hostname.contains("rgd-27p8tr1");
            isCurator = isPipelines || isDev;
            isTest = hostname.contains("irvine");
			
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

    public static boolean isPipelines() throws UnknownHostException {
        parseHostName();
        return isPipelines;
    }

    public static boolean isTest() throws UnknownHostException {
        parseHostName();
        return isTest;
    }

    public static boolean isDev() throws UnknownHostException {
        parseHostName();
        return isDev;
    }
	
	public static String getESIndexName(String index) {
		try {
			if( isProduction() ) {
				return index+"_index_prod";
			}
			if( isPipelines() ) {
				//return "rgd_index_cur";
                return index+"_index_prod";
			}
			if( isTest() ) {
				return index+"_index_test";
			}
			if( isDev() ) {
				return index+"_index_dev";
			}
			
		} catch( UnknownHostException e ) {
			return null;
		}
        return index+"_index_dev";
	}
}
