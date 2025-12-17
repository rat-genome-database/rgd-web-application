package edu.mcw.rgd.entityTagger.aspect;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import edu.mcw.rgd.entityTagger.service.TransactionService;

/**
 * Aspect for logging transaction-related operations.
 * Provides cross-cutting concerns for transaction monitoring and debugging.
 */
@Aspect
@Component
public class TransactionLoggingAspect {

    private static final Logger logger = LoggerFactory.getLogger(TransactionLoggingAspect.class);

    @Autowired
    private TransactionService transactionService;

    /**
     * Log transactions around methods annotated with @Transactional.
     */
    @Around("@annotation(transactional)")
    public Object logTransactionalMethod(ProceedingJoinPoint joinPoint, Transactional transactional) throws Throwable {
        String methodName = joinPoint.getSignature().toShortString();
        String className = joinPoint.getTarget().getClass().getSimpleName();
        
        // Get current transaction info before method execution
        TransactionService.TransactionInfo beforeInfo = transactionService.getCurrentTransactionInfo();
        
        logger.debug("Starting transactional method: {}.{} with propagation: {}, isolation: {}", 
                   className, methodName, transactional.propagation(), transactional.isolation());
        
        if (beforeInfo != null) {
            logger.debug("Pre-execution transaction state: {}", beforeInfo);
        }
        
        long startTime = System.currentTimeMillis();
        boolean success = false;
        
        try {
            Object result = joinPoint.proceed();
            success = true;
            
            // Get transaction info after successful execution
            TransactionService.TransactionInfo afterInfo = transactionService.getCurrentTransactionInfo();
            long executionTime = System.currentTimeMillis() - startTime;
            
            logger.debug("Completed transactional method: {}.{} in {}ms - SUCCESS", 
                       className, methodName, executionTime);
            
            if (afterInfo != null) {
                logger.debug("Post-execution transaction state: {}", afterInfo);
            }
            
            // Log warning for long-running transactions
            if (executionTime > 5000) {
                logger.warn("Long-running transaction detected: {}.{} took {}ms", 
                          className, methodName, executionTime);
            }
            
            return result;
            
        } catch (Exception e) {
            long executionTime = System.currentTimeMillis() - startTime;
            
            // Get transaction info after exception
            TransactionService.TransactionInfo errorInfo = transactionService.getCurrentTransactionInfo();
            
            logger.error("Failed transactional method: {}.{} in {}ms - ERROR: {}", 
                       className, methodName, executionTime, e.getMessage());
            
            if (errorInfo != null) {
                logger.error("Error transaction state: {}", errorInfo);
            }
            
            throw e;
        }
    }

    /**
     * Log DAO operations to monitor database access patterns.
     */
    @Around("execution(* edu.mcw.rgd.entityTagger.dao.impl.*.*(..))")
    public Object logDaoOperation(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().getName();
        String className = joinPoint.getTarget().getClass().getSimpleName();
        Object[] args = joinPoint.getArgs();
        
        // Check if we're in a transaction
        TransactionService.TransactionInfo txInfo = transactionService.getCurrentTransactionInfo();
        boolean inTransaction = txInfo != null;
        
        if (logger.isDebugEnabled()) {
            logger.debug("DAO operation: {}.{} - InTransaction: {} - Args: {}", 
                       className, methodName, inTransaction, formatArgs(args));
        }
        
        long startTime = System.currentTimeMillis();
        
        try {
            Object result = joinPoint.proceed();
            long executionTime = System.currentTimeMillis() - startTime;
            
            if (logger.isDebugEnabled()) {
                logger.debug("DAO operation completed: {}.{} in {}ms", 
                           className, methodName, executionTime);
            }
            
            // Log warning for slow DAO operations
            if (executionTime > 1000) {
                logger.warn("Slow DAO operation: {}.{} took {}ms", 
                          className, methodName, executionTime);
            }
            
            return result;
            
        } catch (Exception e) {
            long executionTime = System.currentTimeMillis() - startTime;
            
            logger.error("DAO operation failed: {}.{} in {}ms - Error: {}", 
                       className, methodName, executionTime, e.getMessage());
            
            throw e;
        }
    }

    /**
     * Log transaction service operations for monitoring.
     */
    @Around("execution(* edu.mcw.rgd.entityTagger.service.TransactionService.*(..))")
    public Object logTransactionServiceOperation(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();
        
        // Skip logging for getCurrentTransactionInfo to avoid recursion
        if ("getCurrentTransactionInfo".equals(methodName)) {
            return joinPoint.proceed();
        }
        
        logger.debug("Transaction service operation: {} - Args: {}", methodName, formatArgs(args));
        
        long startTime = System.currentTimeMillis();
        
        try {
            Object result = joinPoint.proceed();
            long executionTime = System.currentTimeMillis() - startTime;
            
            logger.debug("Transaction service operation completed: {} in {}ms", methodName, executionTime);
            
            return result;
            
        } catch (Exception e) {
            long executionTime = System.currentTimeMillis() - startTime;
            
            logger.error("Transaction service operation failed: {} in {}ms - Error: {}", 
                       methodName, executionTime, e.getMessage());
            
            throw e;
        }
    }

    /**
     * Monitor batch processing operations that involve transactions.
     */
    @Around("execution(* edu.mcw.rgd.entityTagger.service.*.process*(..))")
    public Object logBatchProcessingOperation(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().getName();
        String className = joinPoint.getTarget().getClass().getSimpleName();
        
        // Check transaction status
        TransactionService.TransactionInfo txInfo = transactionService.getCurrentTransactionInfo();
        
        logger.info("Starting batch processing: {}.{} - Transaction active: {}", 
                  className, methodName, txInfo != null);
        
        long startTime = System.currentTimeMillis();
        
        try {
            Object result = joinPoint.proceed();
            long executionTime = System.currentTimeMillis() - startTime;
            
            logger.info("Batch processing completed: {}.{} in {}ms", 
                      className, methodName, executionTime);
            
            return result;
            
        } catch (Exception e) {
            long executionTime = System.currentTimeMillis() - startTime;
            
            logger.error("Batch processing failed: {}.{} in {}ms - Error: {}", 
                       className, methodName, executionTime, e.getMessage());
            
            throw e;
        }
    }

    /**
     * Format method arguments for logging, handling sensitive data appropriately.
     */
    private String formatArgs(Object[] args) {
        if (args == null || args.length == 0) {
            return "[]";
        }
        
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < args.length; i++) {
            if (i > 0) {
                sb.append(", ");
            }
            
            Object arg = args[i];
            if (arg == null) {
                sb.append("null");
            } else if (arg instanceof String) {
                String str = (String) arg;
                // Mask potential passwords or sensitive data
                if (str.length() > 50 || containsSensitiveKeywords(str)) {
                    sb.append("\"").append(str.substring(0, Math.min(10, str.length()))).append("...\"");
                } else {
                    sb.append("\"").append(str).append("\"");
                }
            } else if (arg instanceof Number) {
                sb.append(arg.toString());
            } else {
                sb.append(arg.getClass().getSimpleName()).append("@").append(Integer.toHexString(arg.hashCode()));
            }
        }
        sb.append("]");
        
        return sb.toString();
    }

    /**
     * Check if a string contains keywords that might indicate sensitive data.
     */
    private boolean containsSensitiveKeywords(String str) {
        String lowerStr = str.toLowerCase();
        return lowerStr.contains("password") || 
               lowerStr.contains("secret") || 
               lowerStr.contains("token") ||
               lowerStr.contains("key") ||
               lowerStr.contains("credential");
    }
}