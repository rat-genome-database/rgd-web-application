package edu.mcw.rgd.web;

import org.apache.commons.logging.LogFactory;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.ServletRequest;
import jakarta.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Properties;

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
        //put in hack to always return false
        if (true) return false;

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
                case "chromosome":
                case "genome":
                case "phenominer":
                case "models":
                case "gviewer":
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
                case "variant": // variants part of general search
                    if( isProduction() ) {
                        indexName= index+"_index_prod"+","+"variant_index_prod"+","+"expression-search_index_prod";
                    }else
                    if( isPipelines() ) {
                        indexName= index+"_index_cur"+","+"variant_index_cur"+","+"expression-search_index_cur";

                    }else
                    if( isDev() ) {
                        indexName= index+"_index_dev"+","+"variant_index_dev"+","+"expression-search_index_dev";
                    }else
                        indexName= index+"_index_dev"+","+"variant_index_dev"+","+"expression-search_index_dev";
                    break;

                default:
            }


        } catch( UnknownHostException e ) {
            return null;
        }
        return indexName;
	}

    /**
     * Variant Visualizer index
     * @param index
     * @return
     */
    public static String getESVariantIndexName(String index) {
        try {
            if( isProduction() ) {
                return index+"_prod";
            }
            if( isPipelines() ) {
                return index+"_cur";
            }
            if( isDev() ) {
                return index+"_dev";
            }

        } catch( UnknownHostException e ) {
            return null;
        }
        return index+"_dev";
    }
    public static String getGithubOauthRedirectUrl(){
        Properties properties=getGitHubProperties();
        Object clientId=properties.getProperty("CLIENT_ID");
        String url="https://github.com/login/oauth/authorize?client_id="+clientId+"&scope=user&redirect_uri=";
        String redirectURI=properties.getProperty("REDIRECT_URI");
        String page=properties.getProperty("PAGE");
        return url+redirectURI+page;
    }
    public static String getHostname(){
        try {
            if( isProduction() ) {
                return "https://rgd.mcw.edu";
            }
            if( isPipelines() ) {
                return "https://pipelines.rgd.mcw.edu";
            }
            if( isDev() ) {
                return "https://dev.rgd.mcw.edu";
            }

        } catch( UnknownHostException e ) {
            return null;
        }
        return "http://localhost:8080";

      //  return "http://127.0.0.1:8080";
    }
    /**
     * GitHub OAuth settings (CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, PAGE).
     * A GitHub OAuth app has a single callback URL, so a host that shares a server with another
     * (newdev.rgd.mcw.edu runs beside dev.rgd.mcw.edu) can have its own app in
     * /data/properties/github-oauth-&lt;host&gt;.properties; otherwise github-oauth.properties is used.
     */
    public static Properties getGitHubProperties(){
        String fileName="/data/properties/github-oauth.properties";
        String host=getRequestHost();
        if( host!=null ) {
            String hostFileName="/data/properties/github-oauth-"+host+".properties";
            if( new File(hostFileName).isFile() ) {
                fileName=hostFileName;
            }
        }

        Properties props= new Properties();
        FileInputStream fis=null;


        try{

             fis=new FileInputStream(fileName);
            props.load(fis);

        }catch (Exception e){
            e.printStackTrace();
        }
        try {
            if (fis != null) {
                fis.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return props;
    }

    /**
     * The host name the browser used for the current request (behind the Apache proxy, from X-Forwarded-Host),
     * or null outside a Spring MVC request. Only plain host names are returned, since the value is used in a file name.
     */
    static String getRequestHost(){
        RequestAttributes attrs=RequestContextHolder.getRequestAttributes();
        if( !(attrs instanceof ServletRequestAttributes) ) {
            return null;
        }
        HttpServletRequest request=((ServletRequestAttributes) attrs).getRequest();
        String host=request.getHeader("X-Forwarded-Host");
        if( host==null || host.isEmpty() ) {
            host=request.getServerName();
        } else {
            host=host.split(",")[0].trim();
        }
        if( host==null ) {
            return null;
        }
        int colon=host.indexOf(':');
        if( colon>0 ) {
            host=host.substring(0, colon);
        }
        return host.matches("[A-Za-z0-9.-]+") ? host.toLowerCase() : null;
    }
    public static String getSolrUrl(String collection){
        String url=new String();
        switch (collection.toLowerCase()){
            case "solr":
                if(isProduction || isPipelines){
                    url= "https://ontomate.rgd.mcw.edu/QueryBuilder";
                }else{
                    url= "https://dev.rgd.mcw.edu/QueryBuilder";
                }
                break;
//            case "ontosolr":
//                if(isProduction || isPipelines){
//                    url="/solr/OntoSolr";
//                }else{
//                    url="/solr/OntoSolr";
//                }
//                break;
//            case "preprintsolr":
//                if(isProduction || isPipelines){
//                    url= "https://ontomate.rgd.mcw.edu/preprintSolr";
//                }else{
//                    url=  "/solr/preprintSolr";
//                }
//                break;


        }
        return url;
    }
}
