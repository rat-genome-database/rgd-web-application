package edu.mcw.rgd.search.elasticsearch.client;


import edu.mcw.rgd.process.search.ElasticNode;
import io.netty.util.internal.InternalThreadLocalMap;
import org.elasticsearch.client.transport.TransportClient;

import java.util.List;


/**
 * Created by jthota on 8/9/2017.
 */
public class ClientInit {
    private static TransportClient client=null;
    private static List<String> hosts;
    public void init(){
        System.out.println("Initializing Elasticsearch Client...");
        if(client==null){
            hosts=this.getHostNames();
        ElasticSearchClient.setHosts(hosts);
      System.out.println("CLIENT IS NULL, CREATING NEW CLIENT...");
           client=ElasticSearchClient.getInstance();
        }
    }

    public static void setClient(TransportClient client) {
        ClientInit.client = client;
    }

    public synchronized void destroy(){
        System.out.println("destroying Elasticsearch Client...");
        if(client!=null) {
            client.close();
            client.threadPool().shutdownNow();
            InternalThreadLocalMap.remove();
            client=null;


        }
    }
    public static TransportClient getClient() {
        return client;
    }

    public static List<String> getHosts() {
        return hosts;
}

    public static void setHosts(List<String> hosts) {
        ClientInit.hosts = hosts;
    }
    public List<String> getHostNames(){
          ElasticNode elastic= new ElasticNode();
            return elastic.getNodeURLs();

    }
}
