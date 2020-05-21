package edu.mcw.rgd.vv.vvservice;

import io.netty.util.internal.InternalThreadLocalMap;
import org.apache.http.HttpHost;
import org.apache.http.client.config.RequestConfig;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestClientBuilder;
import org.elasticsearch.client.RestHighLevelClient;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Created by jthota on 1/3/2020.
 */
public class VariantIndexClient {
    private static RestHighLevelClient client=null;
    public static RestHighLevelClient init(){
        if(client==null) {
         try(InputStream input= new FileInputStream("C:/Apps/elasticsearchProps.properties")){
        //    try(InputStream input= new FileInputStream("/data/properties/elasticsearchProps.properties")){
                Properties props= new Properties();
                props.load(input);
               String VARIANTS_HOST= (String) props.get("VARIANTS_HOST");
            //    String VARIANTS_HOST= (String) props.get("HOST1");
                int port=Integer.parseInt((String) props.get("PORT"));
                client = new RestHighLevelClient(
                        RestClient.builder(
                              new HttpHost(VARIANTS_HOST, port, "http")
                        ).setRequestConfigCallback(
                                new RestClientBuilder.RequestConfigCallback(){
                                    @Override
                                    public RequestConfig.Builder customizeRequestConfig(
                                            RequestConfig.Builder requestConfigBuilder) {
                                        return requestConfigBuilder
                                                .setConnectTimeout(5000)
                                                .setSocketTimeout(120000)
                                        .setConnectionRequestTimeout(0);
                                    }

                                }
                        )
                );


            }catch (Exception e){
                e.printStackTrace();
            }

        }
        return client;
    }
    public synchronized void destroy() throws IOException {
        System.out.println("destroying Variants Elasticsearch Client...");
        if(client!=null) {
            client.close();
            //  client.threadPool().shutdownNow();
            InternalThreadLocalMap.remove();
            client=null;


        }
    }

    public static RestHighLevelClient getClient() {
        if(client==null) {
           try(InputStream input= new FileInputStream("C:/Apps/elasticsearchProps.properties")){
        //    try(InputStream input= new FileInputStream("/data/properties/elasticsearchProps.properties")){
                Properties props= new Properties();
                props.load(input);
                String VARIANTS_HOST= (String) props.get("VARIANTS_HOST");
                //    String VARIANTS_HOST= (String) props.get("HOST1");
               System.out.println("HOST: "+ VARIANTS_HOST);
                int port=Integer.parseInt((String) props.get("PORT"));
                client = new RestHighLevelClient(
                        RestClient.builder(
                                new HttpHost(VARIANTS_HOST, port, "http")

                        ));
                input.close();
            }catch (Exception e){
                e.printStackTrace();
            }

        }
        return client;
    }

    public static void setClient(RestHighLevelClient client) {
        VariantIndexClient.client = client;
    }
}
