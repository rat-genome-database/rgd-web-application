package edu.mcw.rgd.search.elasticsearch.client;


import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestClientBuilder;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.cluster.node.DiscoveryNode;
import org.elasticsearch.common.settings.Settings;

import org.elasticsearch.common.transport.TransportAddress;
import org.elasticsearch.transport.client.PreBuiltTransportClient;
import java.net.InetAddress;

import java.util.List;


/**
 * Created by jthota on 2/22/2017.
 */
public class ElasticSearchClient {
    private static List<String> hosts;

    private ElasticSearchClient(){}
    public static RestHighLevelClient getInstance() {

        RestHighLevelClient client = new RestHighLevelClient(
                RestClient.builder(
                      new HttpHost("green.rgd.mcw.edu", 9200, "http")
                     /*  new HttpHost("erika01.rgd.mcw.edu",9200,"http"),
                        new HttpHost( "erika02.rgd.mcw.edu",9200,"http"),
                        new HttpHost("erika03.rgd.mcw.edu",9200,"http"),
                        new HttpHost("erika04.rgd.mcw.edu",9200,"http"),
                        new HttpHost("erika05.rgd.mcw.edu",9200,"http")*/
                       ));
        return client;
    /*    TransportClient client=null;

            Settings settings = Settings.builder()
                   //  .put("client.transport.sniff", true)
                      .put("cluster.name", "green")

                    .build();

        try {
                client = new PreBuiltTransportClient(settings);
               for(String host:hosts){
                 client.addTransportAddress(new TransportAddress(InetAddress.getByName(host), 9300));
               }

            } catch (Exception e) {
                e.printStackTrace();
    }

        return client;*/
    }

    public static List<String> getHosts() {
        return hosts;
    }

    public static void setHosts(List<String> hosts) {
        ElasticSearchClient.hosts = hosts;
    }
}
