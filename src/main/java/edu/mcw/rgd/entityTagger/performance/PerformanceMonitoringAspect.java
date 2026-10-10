package edu.mcw.rgd.entityTagger.performance;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Performance Monitoring Aspect
 * Monitors method execution times and logs performance metrics
 */
@Aspect
@Component
public class PerformanceMonitoringAspect {

    private static final Logger logger = LoggerFactory.getLogger(PerformanceMonitoringAspect.class);
    private static final Logger performanceLogger = LoggerFactory.getLogger("PERFORMANCE");

    // Threshold for logging slow operations (in milliseconds)
    private static final long SLOW_OPERATION_THRESHOLD = 1000; // 1 second
    private static final long VERY_SLOW_OPERATION_THRESHOLD = 5000; // 5 seconds

    /**
     * Monitor service layer methods
     */
    @Around("execution(* edu.mcw.rgd.entityTagger.service..*(..))")
    public Object monitorServiceMethods(ProceedingJoinPoint joinPoint) throws Throwable {
        return monitorMethodExecution(joinPoint, "SERVICE");
    }

    /**
     * Monitor DAO layer methods
     */
    @Around("execution(* edu.mcw.rgd.entityTagger.dao..*(..))")
    public Object monitorDaoMethods(ProceedingJoinPoint joinPoint) throws Throwable {
        return monitorMethodExecution(joinPoint, "DAO");
    }

    /**
     * Monitor controller layer methods
     */
    @Around("execution(* edu.mcw.rgd.entityTagger.controller..*(..))")
    public Object monitorControllerMethods(ProceedingJoinPoint joinPoint) throws Throwable {
        return monitorMethodExecution(joinPoint, "CONTROLLER");
    }

    /**
     * Monitor batch processing methods
     */
    @Around("execution(* edu.mcw.rgd.entityTagger.batch..*(..))")
    public Object monitorBatchMethods(ProceedingJoinPoint joinPoint) throws Throwable {
        return monitorMethodExecution(joinPoint, "BATCH");
    }

    /**
     * Monitor entity recognition methods
     */
    @Around("execution(* edu.mcw.rgd.entityTagger.entity..*(..))")
    public Object monitorEntityRecognitionMethods(ProceedingJoinPoint joinPoint) throws Throwable {
        return monitorMethodExecution(joinPoint, "ENTITY_RECOGNITION");
    }

    /**
     * Generic method execution monitoring
     */
    private Object monitorMethodExecution(ProceedingJoinPoint joinPoint, String layer) throws Throwable {
        String className = joinPoint.getTarget().getClass().getSimpleName();
        String methodName = joinPoint.getSignature().getName();
        String fullMethodName = className + "." + methodName;
        
        long startTime = System.currentTimeMillis();
        Object result = null;
        Throwable exception = null;
        
        try {
            result = joinPoint.proceed();
            return result;
        } catch (Throwable t) {
            exception = t;
            throw t;
        } finally {
            long executionTime = System.currentTimeMillis() - startTime;
            logPerformanceMetrics(layer, fullMethodName, executionTime, exception, joinPoint.getArgs());
        }
    }

    /**
     * Log performance metrics
     */
    private void logPerformanceMetrics(String layer, String methodName, long executionTime, 
                                     Throwable exception, Object[] args) {
        
        // Always log to performance logger for metrics collection
        performanceLogger.info("PERF|{}|{}|{}ms|{}|{}", 
            layer, methodName, executionTime, 
            exception != null ? "ERROR" : "SUCCESS",
            args != null ? args.length : 0);

        // Log slow operations to main logger
        if (executionTime > VERY_SLOW_OPERATION_THRESHOLD) {
            logger.warn("VERY SLOW OPERATION: {}.{} took {}ms", 
                       layer, methodName, executionTime);
        } else if (executionTime > SLOW_OPERATION_THRESHOLD) {
            logger.info("Slow operation: {}.{} took {}ms", 
                       layer, methodName, executionTime);
        }

        // Log errors with execution time
        if (exception != null) {
            logger.error("Method {}.{} failed after {}ms: {}", 
                        layer, methodName, executionTime, exception.getMessage());
        }

        // Log debug information for very detailed monitoring
        if (logger.isDebugEnabled()) {
            logger.debug("Method execution: {}.{} - {}ms - {} args", 
                        layer, methodName, executionTime, args != null ? args.length : 0);
        }
    }
}