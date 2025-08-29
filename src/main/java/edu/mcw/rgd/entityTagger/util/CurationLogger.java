package edu.mcw.rgd.entityTagger.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Utility class for curation-specific logging
 */
public class CurationLogger {
    
    private static final Logger logger = LoggerFactory.getLogger(CurationLogger.class);
    
    public static void info(String message, Object... args) {
        logger.info(message, args);
    }
    
    public static void warn(String message, Object... args) {
        logger.warn(message, args);
    }
    
    public static void error(String message, Object... args) {
        logger.error(message, args);
    }
    
    public static void debug(String message, Object... args) {
        logger.debug(message, args);
    }
    
    public static void entering(Class<?> clazz, String methodName, Object... params) {
        if (params != null && params.length > 0) {
            logger.debug("Entering {}.{} with params: {}", clazz.getSimpleName(), methodName, params);
        } else {
            logger.debug("Entering {}.{}", clazz.getSimpleName(), methodName);
        }
    }
    
    public static void exiting(Class<?> clazz, String methodName) {
        logger.debug("Exiting {}.{}", clazz.getSimpleName(), methodName);
    }
    
    public static void logPdfProcessing(String message, Object... args) {
        logger.info(message, args);
    }
}