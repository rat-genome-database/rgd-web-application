package edu.mcw.rgd.search;

import jyinterface.interfaces.OBOEngineType;
import jyinterface.factory.OBOEngineFactory;

import java.io.File;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jul 11, 2008
 * Time: 4:22:47 PM
 * To change this template use File | Settings | File Templates.
 */
public class OBOEngineRuntime extends Thread{

    public static OBOEngineRuntime runtime = new OBOEngineRuntime();

    private OBOEngineRuntime () {
    }

    public OBOEngineType oboEngine = null;

    public static OBOEngineRuntime getInstance() {
        return runtime;
    }

    public OBOEngineType getOBOEngine() {
          return oboEngine;
    }

    public void run() {
       try {
          System.setProperty("python.home",System.getProperty("catalina.home") + "/apps/OBOEngine");
          OBOEngineFactory factory = new OBOEngineFactory(System.getProperty("catalina.home") + "/apps/OBOEngine/jython_code" + File.pathSeparator + System.getProperty("catalina.home") + "/apps/OBOEngine/jython_code/pythonlib.jar");
          oboEngine = factory.create(System.getProperty("catalina.home") + "/apps/OBOEngine/data",true);
       } catch (Exception e) {
          e.printStackTrace();
       }
    }
}
