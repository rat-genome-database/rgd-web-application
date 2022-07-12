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
	private static boolean isTest; // true iff host is local development machine
	private static boolean isDev; // true iff host is HANSEN (DEV)
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

            isProduction = hostname.contains("apollo") || hostname.contains("booker");
            isPipelines = hostname.contains("reed");
            isDev = hostname.contains("hansen");
            isCurator = isPipelines || isDev;
            isTest = hostname.contains("rgd-27p8tr1") || hostname.contains("rgd-c6vhv52");

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
        String indexName=null;
		try {
		    switch(index){
                case "genome":
                case "phenominer":
                    if( isProduction() ) {
                        indexName= index+"_index_prod";
                    }else
                    if( isPipelines() ) {
                        indexName= index+"_index_cur";
                    }else
                    if( isDev() ) {
                        indexName= index+"_index_dev";
                    }else
                    indexName= index+"_index_dev";
                    break;


                case "search":
                case "variant":
                    if( isProduction() ) {
                        indexName= index+"_index_prod";
                    }else
                    if( isPipelines() ) {
                        indexName= index+"_index_cur";
                    }else
                    if( isDev() ) {
                        indexName= index+"_index_dev"+","+"variant_index_dev";
                    }else
                        indexName= index+"_index_dev"+","+"variant_index_dev";
                    break;

                default:
            }

			
		} catch( UnknownHostException e ) {
			return null;
		}
        return indexName;
	}
    public static String getESVariantIndexName(String index) {
        try {
            if( isProduction() ) {
                //	return index+"_index_prod";
                return index+"_cur";
            }
            if( isPipelines() ) {
                return index+"_prod";
                //   return index+"_index_prod";
            }
            if( isDev() ) {
                return index+"_dev";
            }

        } catch( UnknownHostException e ) {
            return null;
        }
        return index+"_dev";
    }

}
