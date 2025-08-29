package edu.mcw.rgd.web;

import edu.mcw.rgd.phenominer.frontend.OTrees;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

/**
 * @author mtutaj
 * @since 4/12/2018
 */
public class PhenominerListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {

        // preloads ontology tress for phenominer in background thread
        Runnable r = new Runnable() {

            @Override
            public void run() {
                System.out.println("phenominer init: starting ontology tree initialization...");
                
                String[] ontologies = {"VT", "MMO", "CMO", "XCO", "RS"};
                int successCount = 0;
                
                for (String ontology : ontologies) {
                    try {
                        System.out.println("phenominer init " + ontology + " ...");
                        OTrees.getInstance().getOTree(ontology, null, 3);
                        System.out.println(ontology + " loaded successfully");
                        successCount++;
                    } catch(Exception e) {
                        System.err.println("phenominer init exception for " + ontology + ": " + e.getMessage());
                        // Continue with next ontology instead of failing completely
                    }
                }
                
                System.out.println("phenominer init completed: " + successCount + "/" + ontologies.length + " ontologies loaded successfully");
                if (successCount < ontologies.length) {
                    System.out.println("phenominer init: some ontologies failed to load but will be loaded on demand");
                }
            }
        };

        Thread t = new Thread(r);
        t.start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {

    }
}
