package edu.mcw.rgd.web;

import edu.mcw.rgd.phenominer.frontend.OTrees;
import edu.mcw.rgd.services.ClientInit;

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
                try {
                    System.out.println("phenominer init MMO ...");
                    OTrees.getInstance().getOTree("MMO", null, 3);
                    System.out.println("phenominer init CMO ...");
                    OTrees.getInstance().getOTree("CMO", null, 3);
                    System.out.println("phenominer init XCO ...");
                    OTrees.getInstance().getOTree("XCO", null, 3);
                    System.out.println("phenominer init RS ...");
                    OTrees.getInstance().getOTree("RS", null, 3);
                    System.out.println("phenominer init done!");
                } catch(Exception e) {
                    System.out.println("phenominer init exception: "+e.getMessage());
                }
            }
        };

        Thread t = new Thread(r, "phenominer-ontology-preload");
        t.setDaemon(true);
        t.start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {

        // Shut the Elasticsearch client down with the context. Without this, a redeploy leaves the
        // previous client's connection manager and reactor threads running; those threads hold a
        // reference to this webapp's classloader, so every redeploy retains a whole extra copy of
        // the application and the heap walks upward until the JVM dies.
        try {
            ClientInit.destroy();
        } catch (Exception e) {
            System.out.println("Elasticsearch client shutdown failed: " + e.getMessage());
        }
    }
}
