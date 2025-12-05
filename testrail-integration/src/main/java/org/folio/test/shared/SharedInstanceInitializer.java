package org.folio.test.shared;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class SharedInstanceInitializer {

  private static final Logger logger = LoggerFactory.getLogger(SharedInstanceInitializer.class);
  private static volatile boolean started = false;

  private static SharedInstance sharedInstance;

  public static void start() {
    if (!started) {
      synchronized (SharedInstanceInitializer.class) {
        if (!started) {
          try {
            logger.info("start:: Attempting to start the shared instance");
            // Can later be transformed into a mock server on Jetty if needed
            sharedInstance = new SharedInstance();
            sharedInstance.start();

            Runtime.getRuntime().addShutdownHook(new Thread(sharedInstance::stop));
            logger.info("start:: Shared instance started successfully");
          } catch (Exception e) {
            logger.error("Failed to start a shared instance: {}", e.getMessage());
            throw new RuntimeException("Failed to start a shared test instance", e);
          }
          started = true;
        }
      }
    }
  }

  public static SharedInstance getSharedInstance() {
    if (!started || sharedInstance == null) {
      throw new IllegalStateException("Failed to retrieve a shared instance");
    }

    return sharedInstance;
  }

  public static void main(String[] args) throws Exception {
    logger.info("main:: Started testing single shared instance startup");

    // Start 5 threads simultaneously calling the startup logic
    var startupTask = (Runnable) SharedInstanceInitializer::start;
    for (int i = 0; i < 5; i++) {
      new Thread(startupTask, "TestRunner-" + i).start();
    }
    Thread.sleep(15000);

    logger.info("main:: Stopped testing single shared instance startup");
  }
}