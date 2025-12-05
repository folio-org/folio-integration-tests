package org.folio.test.shared;

import org.folio.test.config.TestRailClient;
import org.folio.test.dao.TestRailDao;
import org.folio.test.models.Test;
import org.folio.test.utils.EnvUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

import static org.folio.test.config.TestRailEnv.TESTRAIL_RUN_ID;

public class SharedCacheInstance {

  private static final Logger logger = LoggerFactory.getLogger(SharedCacheInstance.class);
  private final TestRailDao testRailDao;
  private final TestRailClient testRailClient;
  private final Integer runId;
  private final HashSet<Integer> caseIds;

  private Thread instanceThread;

  public SharedCacheInstance() {
    this.testRailDao = new TestRailDao();
    this.testRailClient = new TestRailClient();
    this.runId = EnvUtils.getInt(TESTRAIL_RUN_ID);
    this.caseIds = new HashSet<>();
  }

  public void start() {
    instanceThread = new Thread(() -> {
      try {
        logger.info("start:: Shared cache instance is running");
        if (isTestRailEnabled()) {
          logger.info("start:: Test Rail integration is enabled");
          setCaseIds(runId);
        } else {
          logger.info("start:: Test Rail integration is disabled");
        }

        Thread.sleep(Long.MAX_VALUE);
      } catch (InterruptedException ignored) {
      }
    });
    instanceThread.setName("Shared Cache Instance");
    instanceThread.setDaemon(true);
    instanceThread.start();
    try {
      Thread.sleep(500);
    } catch (InterruptedException ignored) {
    }
  }

  public void stop() {
    if (instanceThread != null) {
      instanceThread.interrupt();
      logger.info("start:: Shared cache instance stopped successfully");
    }
  }

  private boolean isTestRailEnabled() {
    return runId != null;
  }

  public void setCaseIds(Integer runId) {
    var requestOffset = 0;
    var requestLimit = 250; // This is the maximum Test Rail will take
    while (true) {
      logger.info("setCaseIds:: Retrieving tests, offset: {}, limit: {}", requestOffset, requestLimit);
      var responsePayload = testRailDao.getTests(testRailClient, runId, requestOffset * requestLimit, requestLimit);
      if (responsePayload == null) {
        break;
      }

      var tests = responsePayload.tests();
      if (tests.isEmpty()) {
        break;
      }
      var caseIdsChunk = tests.stream()
        .filter(Objects::nonNull)
        .map(Test::caseId)
        .distinct()
        .toList();
      caseIds.addAll(caseIdsChunk);

      if (responsePayload.links().next() == null) {
        break;
      }
      logger.info("setCaseIds:: Offset: {}, next: {}", responsePayload.offset(), responsePayload.links().next());
      requestOffset++;
    }

    logger.info("setCaseIds:: Set {} case ids", caseIds.size());
  }

  public Set<Integer> getCaseIds() {
    logger.info("getCaseIds:: Retrieved {} case ids", caseIds.size());
    return caseIds;
  }
}