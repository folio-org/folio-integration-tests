package org.folio.test.shared;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class SharedCacheInstanceInitializer {

  private static final Logger logger = LoggerFactory.getLogger(SharedCacheInstanceInitializer.class);
  private static volatile boolean started = false;

  private static SharedCacheInstance sharedCacheInstance;

  public static void start() {
    if (!started) {
      synchronized (SharedCacheInstanceInitializer.class) {
        if (!started) {
          try {
            logger.info("start:: Attempting to start the shared cache instance");
            // Can later be transformed into a mock server on Jetty if needed
            sharedCacheInstance = new SharedCacheInstance();
            sharedCacheInstance.start();
            logger.info("start:: Shared cache instance started successfully");
          } catch (Exception e) {
            logger.error("Failed to start a shared cache instance: {}", e.getMessage());
            throw new RuntimeException("Failed to start a shared cache instance", e);
          }
          started = true;
        }
      }
    }
  }

  public static SharedCacheInstance getSharedCacheInstance() {
    if (!started || sharedCacheInstance == null) {
      throw new IllegalStateException("Failed to retrieve a shared cache instance");
    }

    return sharedCacheInstance;
  }
}