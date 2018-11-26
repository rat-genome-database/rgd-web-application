package edu.mcw.rgd.search.elasticsearch.client;


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
    public static TransportClient getInstance() {
        TransportClient client=null;

            Settings settings = Settings.builder()
                     .put("client.transport.sniff", true)
                      .put("cluster.name", "erika")

                    .build();

        try {
                client = new PreBuiltTransportClient(settings);
               for(String host:hosts){
                 client.addTransportAddress(new TransportAddress(InetAddress.getByName(host), 9300));
               }

            } catch (Exception e) {
                e.printStackTrace();
    }

        return client;
    }

    public static List<String> getHosts() {
        return hosts;
    }

    public static void setHosts(List<String> hosts) {
        ElasticSearchClient.hosts = hosts;
    }
}
