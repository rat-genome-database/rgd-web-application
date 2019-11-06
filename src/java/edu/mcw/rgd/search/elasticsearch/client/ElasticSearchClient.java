package edu.mcw.rgd.search.elasticsearch.client;


import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestClientBuilder;
import org.elasticsearch.client.RestHighLevelClient;

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
                  //    new HttpHost("green.rgd.mcw.edu", 9200, "http")
                       new HttpHost("erika01.rgd.mcw.edu",9200,"http"),
                        new HttpHost( "erika02.rgd.mcw.edu",9200,"http"),
                        new HttpHost("erika03.rgd.mcw.edu",9200,"http"),
                        new HttpHost("erika04.rgd.mcw.edu",9200,"http"),
                        new HttpHost("erika05.rgd.mcw.edu",9200,"http")
                       ));
        return client;

    }

    public static List<String> getHosts() {
        return hosts;
    }

    public static void setHosts(List<String> hosts) {
        ElasticSearchClient.hosts = hosts;
    }
}
