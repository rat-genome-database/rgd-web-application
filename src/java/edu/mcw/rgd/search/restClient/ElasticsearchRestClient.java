package edu.mcw.rgd.search.restClient;

import org.apache.http.HttpHost;
//import org.elasticsearch.client.RestHighLevelClient;

import java.io.IOException;

/**
 * Created by jthota on 11/9/2018.
 */
public class ElasticsearchRestClient {

 /*   private RestHighLevelClient client;
    public RestHighLevelClient getRestClient(){
        client = new RestHighLevelClient(
                org.elasticsearch.client.RestClient.builder(
                        new HttpHost("erika01.rgd.mcw.edu", 9200, "http"),
                        new HttpHost("erika02.rgd.mcw.edu", 9201, "http")));
        return client;

    }
    public void close(){
        try {
            if(client!=null)
                client.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }*/
}
