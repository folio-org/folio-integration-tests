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

  public SharedCacheInstance() {
    this.testRailDao = new TestRailDao();
    this.testRailClient = new TestRailClient();
    this.runId = EnvUtils.getInt(TESTRAIL_RUN_ID);
    this.caseIds = new HashSet<>();
  }

  public void start() {
    logger.info("start:: Shared cache instance is running");
    if (isTestRailEnabled()) {
      logger.info("start:: Test Rail integration is enabled, runId={}", runId);
      setCaseIds(runId);
      logger.info("start:: Test Rail case id cache loaded, totalCaseIds={}", caseIds.size());
    } else {
      logger.info("start:: Test Rail integration is disabled (TESTRAIL_RUN_ID env var not set)");
    }
  }

  private boolean isTestRailEnabled() {
    return runId != null;
  }

  public void setCaseIds(Integer runId) {
    var requestOffset = 0;
    var requestLimit = 250; // This is the maximum Test Rail will take
    while (true) {
      logger.info("setCaseIds:: Retrieving tests for runId={}, offset={}, limit={}", runId, requestOffset * requestLimit, requestLimit);
      var responsePayload = testRailDao.getTests(testRailClient, runId, requestOffset * requestLimit, requestLimit);
      if (responsePayload == null) {
        logger.warn("setCaseIds:: Response payload is null for runId={}, offset={} - stopping pagination", runId, requestOffset * requestLimit);
        break;
      }
      logger.info("setCaseIds:: Response received: offset={}, limit={}, size={}, testsCount={}",
        responsePayload.offset(), responsePayload.limit(), responsePayload.size(),
        responsePayload.tests() == null ? 0 : responsePayload.tests().size());

      var tests = responsePayload.tests();
      if (tests.isEmpty()) {
        logger.warn("setCaseIds:: No tests returned for runId={}, offset={} - stopping pagination", runId, requestOffset * requestLimit);
        break;
      }
      var caseIdsChunk = tests.stream()
        .filter(Objects::nonNull)
        .map(Test::caseId)
        .distinct()
        .toList();
      logger.info("setCaseIds:: Chunk extracted {} distinct case ids from {} tests (runningTotal={})",
        caseIdsChunk.size(), tests.size(), caseIds.size() + caseIdsChunk.size());
      caseIds.addAll(caseIdsChunk);

      if (responsePayload.links() == null || responsePayload.links().next() == null) {
        logger.info("setCaseIds:: No next link - pagination complete at offset={}", requestOffset * requestLimit);
        break;
      }
      logger.info("setCaseIds:: Offset: {}, next: {}", responsePayload.offset(), responsePayload.links().next());
      requestOffset++;
    }

    logger.info("setCaseIds:: Set {} case ids for runId={}", caseIds.size(), runId);
  }

  public Set<Integer> getCaseIds() {
    logger.info("getCaseIds:: Retrieved {} case ids", caseIds.size());
    return caseIds;
  }
}