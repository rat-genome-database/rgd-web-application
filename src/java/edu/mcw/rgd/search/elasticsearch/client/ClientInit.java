package edu.mcw.rgd.search.elasticsearch.client;


import edu.mcw.rgd.web.RgdContext;
import io.netty.util.internal.InternalThreadLocalMap;
import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;

import java.io.FileInputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.UnknownHostException;
import java.util.*;


/**
 * Created by jthota on 8/9/2017.
 */
public class ClientInit {
    private static RestHighLevelClient client=null;
   // private static List<String> hosts;
    private static ClientInit esClientFactory=null;
    public static void init() throws UnknownHostException {
        if(esClientFactory==null){
            esClientFactory=new ClientInit();
            System.out.println("Initializing Elasticsearch Client...");
            if(client==null){
                System.out.println("CLIENT IS NULL, CREATING NEW CLIENT...");
                client=getInstance();
                System.out.println("Initialized elasticsearch client ...");
            }
        }

    }
    private static RestHighLevelClient getInstance() throws UnknownHostException {
     //   Properties props= getProperties();
        if(RgdContext.isProduction())
        return new RestHighLevelClient(
                RestClient.builder(
                        new HttpHost("erika01.rgd.mcw.edu", 9200, "http"),
                        new HttpHost("erika02.rgd.mcw.edu", 9200, "http"),
                        new HttpHost("erika03.rgd.mcw.edu", 9200, "http"),
                        new HttpHost("erika04.rgd.mcw.edu", 9200, "http"),
                        new HttpHost("erika05.rgd.mcw.edu", 9200, "http")

                ));
        else
            return new RestHighLevelClient(
                    RestClient.builder(
                            new HttpHost("travis.rgd.mcw.edu", 9200, "http")

                    ));
    }
    public static void setClient(RestHighLevelClient client) {
        ClientInit.client = client;
    }

    public synchronized void destroy() throws IOException {
        System.out.println("destroying Elasticsearch Client...");

        if(client!=null) {
            client.close();
         //   client.threadPool().shutdownNow();
            InternalThreadLocalMap.remove();
            client=null;
            esClientFactory=null;
        }
    }
   public static RestHighLevelClient getClient() throws UnknownHostException {
        if(client==null){
            init();
        }
        return client;
    }

  /*  public static List<String> getHosts() {
        return hosts;
}

    public static void setHosts(List<String> hosts) {
        ClientInit.hosts = hosts;
    }
   /* public List<String> getHostNames(){
          return this.getNodeURLs();

    }*/
    static Properties getProperties(){
        Properties props= new Properties();
        FileInputStream fis=null;


        try{
         //    fis=new FileInputStream("C:/Apps/elasticsearchProps.properties");
        //   fis=new FileInputStream("/data/pipelines/properties/es_properties.properties");
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


}
