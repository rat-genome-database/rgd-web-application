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
        Properties props= getProperties();
        if(RgdContext.isProduction() || RgdContext.isPipelines())
        return new RestHighLevelClient(
                RestClient.builder(
                        new HttpHost((String) props.get("HOST1"), 9200, "http"),
                        new HttpHost((String) props.get("HOST2"), 9200, "http"),
                        new HttpHost((String) props.get("HOST3"), 9200, "http"),
                        new HttpHost((String) props.get("HOST4"), 9200, "http"),
                        new HttpHost((String) props.get("HOST5"), 9200, "http")

                ));
        else
            return new RestHighLevelClient(
                    RestClient.builder(
                           new HttpHost((String) props.get("DEV_HOST"), 9200, "http")
                         /*   new HttpHost((String) props.get("HOST1"), 9200, "http"),
                            new HttpHost((String) props.get("HOST2"), 9200, "http"),
                            new HttpHost((String) props.get("HOST3"), 9200, "http"),
                            new HttpHost((String) props.get("HOST4"), 9200, "http"),
                            new HttpHost((String) props.get("HOST5"), 9200, "http")*/

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


    static Properties getProperties(){
        Properties props= new Properties();
        FileInputStream fis=null;


        try{
         //    fis=new FileInputStream("C:/Apps/elasticsearchProps.properties");
          fis=new FileInputStream("/data/properties/elasticsearchProps.properties");
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
