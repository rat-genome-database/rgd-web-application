package edu.mcw.rgd.entityTagger.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.concurrent.Callable;
import java.util.function.Supplier;

/**
 * Service for managing database transactions programmatically.
 * Provides utilities for transaction management beyond declarative annotations.
 */
@Service
public class TransactionService {

    private static final Logger logger = LoggerFactory.getLogger(TransactionService.class);

    @Autowired
    private PlatformTransactionManager transactionManager;

    private TransactionTemplate transactionTemplate;

    /**
     * Initialize the transaction template.
     */
    public void init() {
        this.transactionTemplate = new TransactionTemplate(transactionManager);
    }

    /**
     * Execute an operation within a transaction and return a result.
     * 
     * @param operation The operation to execute
     * @param <T> The return type
     * @return The result of the operation
     * @throws RuntimeException if the operation fails
     */
    public <T> T executeInTransaction(Supplier<T> operation) {
        if (transactionTemplate == null) {
            init();
        }
        
        return transactionTemplate.execute(status -> {
            try {
                return operation.get();
            } catch (Exception e) {
                logger.error("Transaction operation failed", e);
                status.setRollbackOnly();
                throw new RuntimeException("Transaction failed: " + e.getMessage(), e);
            }
        });
    }

    /**
     * Execute an operation within a transaction without returning a result.
     * 
     * @param operation The operation to execute
     * @throws RuntimeException if the operation fails
     */
    public void executeInTransaction(Runnable operation) {
        executeInTransaction(() -> {
            operation.run();
            return null;
        });
    }

    /**
     * Execute an operation within a transaction with custom isolation level.
     * 
     * @param operation The operation to execute
     * @param isolationLevel The transaction isolation level
     * @param <T> The return type
     * @return The result of the operation
     */
    public <T> T executeInTransaction(Supplier<T> operation, Isolation isolationLevel) {
        DefaultTransactionDefinition definition = new DefaultTransactionDefinition();
        definition.setIsolationLevel(isolationLevel.value());
        
        TransactionTemplate customTemplate = new TransactionTemplate(transactionManager, definition);
        
        return customTemplate.execute(status -> {
            try {
                return operation.get();
            } catch (Exception e) {
                logger.error("Transaction operation failed with isolation level {}", isolationLevel, e);
                status.setRollbackOnly();
                throw new RuntimeException("Transaction failed: " + e.getMessage(), e);
            }
        });
    }

    /**
     * Execute an operation within a read-only transaction.
     * 
     * @param operation The operation to execute
     * @param <T> The return type
     * @return The result of the operation
     */
    public <T> T executeInReadOnlyTransaction(Supplier<T> operation) {
        DefaultTransactionDefinition definition = new DefaultTransactionDefinition();
        definition.setReadOnly(true);
        definition.setPropagationBehavior(TransactionDefinition.PROPAGATION_SUPPORTS);
        
        TransactionTemplate readOnlyTemplate = new TransactionTemplate(transactionManager, definition);
        
        return readOnlyTemplate.execute(status -> operation.get());
    }

    /**
     * Execute an operation within a new transaction (requires new).
     * 
     * @param operation The operation to execute
     * @param <T> The return type
     * @return The result of the operation
     */
    public <T> T executeInNewTransaction(Supplier<T> operation) {
        DefaultTransactionDefinition definition = new DefaultTransactionDefinition();
        definition.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
        
        TransactionTemplate newTransactionTemplate = new TransactionTemplate(transactionManager, definition);
        
        return newTransactionTemplate.execute(status -> {
            try {
                return operation.get();
            } catch (Exception e) {
                logger.error("New transaction operation failed", e);
                status.setRollbackOnly();
                throw new RuntimeException("New transaction failed: " + e.getMessage(), e);
            }
        });
    }

    /**
     * Execute a batch operation within a transaction with custom batch size.
     * 
     * @param batchOperation The batch operation to execute
     * @param batchSize The size of each batch
     * @param totalItems Total number of items to process
     * @param <T> The return type
     * @return The result of the batch operation
     */
    public <T> T executeBatchInTransaction(BatchOperation<T> batchOperation, int batchSize, int totalItems) {
        return executeInTransaction(() -> {
            T result = null;
            int processedItems = 0;
            
            while (processedItems < totalItems) {
                int currentBatchSize = Math.min(batchSize, totalItems - processedItems);
                logger.debug("Processing batch: {} items (progress: {}/{})", 
                           currentBatchSize, processedItems, totalItems);
                
                try {
                    result = batchOperation.processBatch(processedItems, currentBatchSize, result);
                    processedItems += currentBatchSize;
                } catch (Exception e) {
                    logger.error("Batch processing failed at position {}", processedItems, e);
                    throw new RuntimeException("Batch processing failed: " + e.getMessage(), e);
                }
            }
            
            return result;
        });
    }

    /**
     * Execute an operation with manual transaction control.
     * Useful when you need fine-grained control over commit/rollback.
     * 
     * @param operation The operation to execute
     * @param <T> The return type
     * @return The result of the operation
     */
    public <T> T executeWithManualTransaction(TransactionCallback<T> operation) {
        TransactionStatus status = transactionManager.getTransaction(new DefaultTransactionDefinition());
        
        try {
            T result = operation.doInTransaction(status);
            
            if (!status.isRollbackOnly()) {
                transactionManager.commit(status);
                logger.debug("Manual transaction committed successfully");
            } else {
                transactionManager.rollback(status);
                logger.debug("Manual transaction rolled back");
            }
            
            return result;
        } catch (Exception e) {
            logger.error("Manual transaction failed", e);
            transactionManager.rollback(status);
            throw new RuntimeException("Manual transaction failed: " + e.getMessage(), e);
        }
    }

    /**
     * Execute an operation with retry logic within a transaction.
     * 
     * @param operation The operation to execute
     * @param maxRetries Maximum number of retry attempts
     * @param retryDelay Delay between retries in milliseconds
     * @param <T> The return type
     * @return The result of the operation
     */
    public <T> T executeWithRetry(Supplier<T> operation, int maxRetries, long retryDelay) {
        Exception lastException = null;
        
        for (int attempt = 1; attempt <= maxRetries + 1; attempt++) {
            try {
                return executeInNewTransaction(operation);
            } catch (Exception e) {
                lastException = e;
                logger.warn("Transaction attempt {} failed (max: {}): {}", 
                          attempt, maxRetries + 1, e.getMessage());
                
                if (attempt <= maxRetries) {
                    try {
                        Thread.sleep(retryDelay);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new RuntimeException("Retry interrupted", ie);
                    }
                }
            }
        }
        
        throw new RuntimeException("Transaction failed after " + (maxRetries + 1) + " attempts", lastException);
    }

    /**
     * Functional interface for batch operations.
     */
    @FunctionalInterface
    public interface BatchOperation<T> {
        T processBatch(int startIndex, int batchSize, T previousResult) throws Exception;
    }

    /**
     * Transaction-aware session management for curation operations.
     */
    @Transactional(propagation = Propagation.REQUIRED, isolation = Isolation.READ_COMMITTED)
    public <T> T executeInCurationSession(String sessionKey, Supplier<T> operation) {
        logger.debug("Starting curation session transaction for session: {}", sessionKey);
        
        try {
            T result = operation.get();
            logger.debug("Curation session transaction completed successfully for session: {}", sessionKey);
            return result;
        } catch (Exception e) {
            logger.error("Curation session transaction failed for session: {}", sessionKey, e);
            throw new RuntimeException("Curation session failed: " + e.getMessage(), e);
        }
    }

    /**
     * Batch entity processing with transaction management.
     */
    @Transactional(propagation = Propagation.REQUIRED, isolation = Isolation.READ_COMMITTED)
    public void processBatchEntities(String batchId, BatchEntityProcessor processor, int batchSize) {
        logger.debug("Starting batch entity processing for batch: {} with batch size: {}", batchId, batchSize);
        
        try {
            processor.process(batchId, batchSize);
            logger.debug("Batch entity processing completed successfully for batch: {}", batchId);
        } catch (Exception e) {
            logger.error("Batch entity processing failed for batch: {}", batchId, e);
            throw new RuntimeException("Batch processing failed: " + e.getMessage(), e);
        }
    }

    /**
     * Functional interface for batch entity processing.
     */
    @FunctionalInterface
    public interface BatchEntityProcessor {
        void process(String batchId, int batchSize) throws Exception;
    }

    /**
     * Execute cleanup operations in a separate transaction.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW, isolation = Isolation.READ_COMMITTED)
    public void executeCleanupOperation(Runnable cleanupOperation) {
        logger.debug("Starting cleanup operation in new transaction");
        
        try {
            cleanupOperation.run();
            logger.debug("Cleanup operation completed successfully");
        } catch (Exception e) {
            logger.error("Cleanup operation failed", e);
            throw new RuntimeException("Cleanup operation failed: " + e.getMessage(), e);
        }
    }

    /**
     * Get current transaction status information.
     * 
     * @return Transaction status information or null if no active transaction
     */
    public TransactionInfo getCurrentTransactionInfo() {
        try {
            TransactionStatus status = transactionManager.getTransaction(
                new DefaultTransactionDefinition(TransactionDefinition.PROPAGATION_MANDATORY));
            
            return new TransactionInfo(
                !status.isNewTransaction(),
                status.isRollbackOnly(),
                status.isCompleted(),
                status.hasSavepoint()
            );
        } catch (Exception e) {
            // No active transaction
            return null;
        }
    }

    /**
     * Transaction information holder.
     */
    public static class TransactionInfo {
        private final boolean existingTransaction;
        private final boolean rollbackOnly;
        private final boolean completed;
        private final boolean hasSavepoint;

        public TransactionInfo(boolean existingTransaction, boolean rollbackOnly, 
                             boolean completed, boolean hasSavepoint) {
            this.existingTransaction = existingTransaction;
            this.rollbackOnly = rollbackOnly;
            this.completed = completed;
            this.hasSavepoint = hasSavepoint;
        }

        public boolean isExistingTransaction() { return existingTransaction; }
        public boolean isRollbackOnly() { return rollbackOnly; }
        public boolean isCompleted() { return completed; }
        public boolean hasSavepoint() { return hasSavepoint; }

        @Override
        public String toString() {
            return String.format("TransactionInfo{existing=%s, rollbackOnly=%s, completed=%s, savepoint=%s}",
                               existingTransaction, rollbackOnly, completed, hasSavepoint);
        }
    }
}