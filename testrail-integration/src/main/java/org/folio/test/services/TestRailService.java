package org.folio.test.services;

import com.intuit.karate.Results;
import com.intuit.karate.core.ScenarioResult;
import org.folio.test.config.TestRailClient;
import org.folio.test.dao.TestRailDao;

import org.folio.test.models.AddResultsForCasesRequest;
import org.folio.test.models.Result;
import org.folio.test.models.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import static org.folio.test.models.TestRailResultStatus.FAILED;
import static org.folio.test.models.TestRailResultStatus.PASSED;

public class TestRailService {

  private static final Logger logger = LoggerFactory.getLogger(TestRailService.class);

  private final TestRailDao testRailDao;
  private final TestRailClient testRailClient;
  private final HashSet<Integer> cachedCaseIds;

  public TestRailService() {
    this.testRailDao = new TestRailDao();
    this.testRailClient = new TestRailClient();
    this.cachedCaseIds = new HashSet<>();
  }

  public void cacheCaseIds(Integer runId) {
    var requestOffset = 0;
    var requestLimit = 50;
    while (true) {
      logger.info("cacheCaseIds:: Retrieving tests, offset: {}, limit: {}", requestOffset, requestLimit);
      var responsePayload = testRailDao.getTests(testRailClient, runId, requestOffset * requestLimit, requestLimit);
      if (responsePayload == null) {
        break;
      }

      var tests = responsePayload.tests();
      if (tests.isEmpty()) {
        break;
      }
      var caseIds = tests.stream()
        .filter(Objects::nonNull)
        .map(Test::caseId)
        .toList();
      cachedCaseIds.addAll(caseIds);

      if (responsePayload.links().next() == null) {
        break;
      }
      logger.info("cacheCaseIds:: Offset: {}, next: {}", responsePayload.offset(), responsePayload.links().next());
      requestOffset++;
    }

    logger.info("cacheCaseIds:: Cached {} case ids", cachedCaseIds.size());
  }

  public void createResults(Integer runId, Map<String, Results> results) {
    for (var result : results.entrySet()) {
      prepareAndSendResults(runId, result.getKey(), result.getValue());
    }
  }

  private void prepareAndSendResults(Integer runId, String featureName, Results results) {
    var resultsPayload = new ArrayList<Result>();
    for (var scenarioResult : results.getScenarioResults().toList()) {
      var scenarioName = scenarioResult.getScenario().getName();
      if (CollectionUtils.isEmpty(scenarioResult.getScenario().getTags())) {
        logger.warn("prepareAndSendResults: Cannot retrieve tags for [{}]-[{}]", featureName, scenarioName);
        continue;
      }

      var resultPayload = new Result();
      if (setCaseId(scenarioResult, resultPayload)) {
        logger.warn("prepareAndSendResults: Cannot retrieve case id for [{}]-[{}]", featureName, scenarioName);
        continue;
      }
      setStatus(scenarioResult, resultPayload);
      logger.info("prepareAndSendResults: Prepared [{}]-[{}] result payload: {}", featureName, scenarioName, resultPayload);

      resultsPayload.add(resultPayload);
    }

    if (resultsPayload.isEmpty()) {
      logger.info("prepareAndSendResults: No results payload was prepared for [{}]", featureName);
      return;
    }
    logger.info("prepareAndSendResults: Prepared results for [{}]: {}", featureName, resultsPayload);
    sendResults(runId, featureName, resultsPayload);
  }

  private boolean setCaseId(ScenarioResult scenarioResult, Result resultPayload) {
    var optional = scenarioResult.getScenario().getTags().stream()
      .filter(tag -> tag.getName() != null && tag.getName().startsWith("C"))
      .map(tag -> tag.getName().replace("C", ""))
      .map(Integer::parseInt)
      .findFirst();
    if (optional.isEmpty()) {
      return true;
    }

    var caseId = optional.get();
    if (!cachedCaseIds.contains(caseId)) {
      logger.warn("setCaseId: Ignoring case id {}, is not associated with the current run", caseId);
      return true;
    }
    resultPayload.setCaseId(caseId);

    return false;
  }

  private void setStatus(ScenarioResult result, Result resultPayload) {
    if (result.isFailed()) {
      resultPayload.setStatusId(FAILED.getStatusId());
      if (result.getFailedStep() != null) {
        var failedStep = result.getFailedStep();
        resultPayload.setComment("Test failed:\n\n\n" + failedStep.getErrorMessage());
      }
      return;
    }

    resultPayload.setStatusId(PASSED.getStatusId());
  }

  private void sendResults(Integer runId, String featureName, List<Result> resultsPayload) {
    var requestPayload = new AddResultsForCasesRequest(resultsPayload);
    var responsePayload = testRailDao.addResultsForCases(testRailClient, runId, requestPayload);
    logger.info("sendResults:: Created results [{}] response: {}", featureName, responsePayload);
  }
}
