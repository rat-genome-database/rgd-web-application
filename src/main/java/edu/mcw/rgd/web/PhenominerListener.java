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
                try {
                    System.out.println("phenominer init VT ...");
                    OTrees.getInstance().getOTree("VT", null, 3);
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

        Thread t = new Thread(r);
        t.start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {

    }
}
