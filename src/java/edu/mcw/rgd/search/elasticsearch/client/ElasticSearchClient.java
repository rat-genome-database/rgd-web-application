package edu.mcw.rgd.search.elasticsearch.client;


import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;


import java.util.List;


/**
 * Created by jthota on 2/22/2017.
 */
public class ElasticSearchClient {
    private static List<String> hosts;

    private ElasticSearchClient(){}
    public static RestHighLevelClient getInstance() {

      return new RestHighLevelClient(
                RestClient.builder(
                     new HttpHost(hosts.get(0), 9200,"http"),
                        new HttpHost(hosts.get(1), 9200,"http"),
                        new HttpHost(hosts.get(2), 9200,"http"),
                        new HttpHost(hosts.get(3), 9200,"http"),
                        new HttpHost(hosts.get(4), 9200,"http")
                       ));

    }

    public static List<String> getHosts() {
        return hosts;
    }

    public static void setHosts(List<String> hosts) {
        ElasticSearchClient.hosts = hosts;
    }
}
