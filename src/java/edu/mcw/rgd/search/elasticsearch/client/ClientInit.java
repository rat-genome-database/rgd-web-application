package edu.mcw.rgd.search.elasticsearch.client;


import io.netty.util.internal.InternalThreadLocalMap;
import org.elasticsearch.client.RestHighLevelClient;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;


/**
 * Created by jthota on 8/9/2017.
 */
public class ClientInit {
    private static RestHighLevelClient client=null;
    private static List<String> hosts;
    public void init(){
        System.out.println("Initializing Elasticsearch Client...");
        if(client==null){
            hosts=this.getHostNames();
            ElasticSearchClient.setHosts(hosts);
            System.out.println("CLIENT IS NULL, CREATING NEW CLIENT...");
            client=ElasticSearchClient.getInstance();
            System.out.println("Initialized elasticsearch client ...");
        }
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


        }
    }
    public static RestHighLevelClient getClient() {
        return client;
    }

    public static List<String> getHosts() {
        return hosts;
}

    public static void setHosts(List<String> hosts) {
        ClientInit.hosts = hosts;
    }
    public List<String> getHostNames(){
      //    return this.getNodeURLs();
        List<String> hostNames=new ArrayList<>();
        Properties props= new Properties();
//    try(InputStream input= new FileInputStream("C:/Apps/elasticsearchProps.properties")){
    try(InputStream input= new FileInputStream("/data/properties/elasticsearchProps.properties")){
            props.load(input);
            hostNames.add(props.get("HOST1").toString());
            hostNames.add(props.get("HOST2").toString());
            hostNames.add(props.get("HOST3").toString());
            hostNames.add(props.get("HOST4").toString());
            hostNames.add(props.get("HOST5").toString());

        }catch (Exception e){
            e.printStackTrace();
        }
    return hostNames;
    }

    public List<String> getNodeURLs() {
        ArrayList hostNames = new ArrayList();
      List<String> nodeUrls = new ArrayList<>(Arrays.asList("http://erika01.rgd.mcw.edu:9200", "http://erika02.rgd.mcw.edu:9200", "http://erika03.rgd.mcw.edu:9200", "http://erika04.rgd.mcw.edu:9200", "http://erika05.rgd.mcw.edu:9200"));
           Iterator var2 = nodeUrls.iterator();

        while(var2.hasNext()) {
            String str = (String)var2.next();

            try {
                URL e = new URL(str);
                HttpURLConnection conn = (HttpURLConnection)e.openConnection();
                conn.setRequestMethod("GET");
                if(conn.getResponseMessage().equals("OK")) {
                    hostNames.add(str.substring(0, str.lastIndexOf(":")).replace("http://", ""));
                }

                conn.disconnect();
            } catch (Exception var6) {
                var6.printStackTrace();
            }
        }

        return hostNames;
    }
    public static void main(String[] args) throws IOException {
        ClientInit c= new ClientInit();
        c.init();
        c.destroy();
        System.out.println("DONE!!!!!!!!!!");
    }

}
