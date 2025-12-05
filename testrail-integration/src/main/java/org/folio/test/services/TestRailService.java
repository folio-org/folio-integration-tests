package org.folio.test.services;

import com.intuit.karate.Results;
import com.intuit.karate.core.ScenarioResult;
import org.folio.test.shared.SharedCacheInstanceInitializer;
import org.folio.test.config.TestRailClient;
import org.folio.test.dao.TestRailDao;

import org.folio.test.models.AddResultsForCasesRequest;
import org.folio.test.models.Result;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.folio.test.models.ResultStatus.FAILED;
import static org.folio.test.models.ResultStatus.PASSED;

public class TestRailService {

  private static final Logger logger = LoggerFactory.getLogger(TestRailService.class);

  private final TestRailDao testRailDao;
  private final TestRailClient testRailClient;

  public TestRailService() {
    this.testRailDao = new TestRailDao();
    this.testRailClient = new TestRailClient();
  }

  public void createResults(Integer runId, Map<String, Results> results) {
    var caseIds = SharedCacheInstanceInitializer.getSharedCacheInstance().getCaseIds();
    if (CollectionUtils.isEmpty(caseIds)) {
      logger.warn("createResults: Cannot create results, no case ids were found for the {} run", runId);
      return;
    }
    for (var result : results.entrySet()) {
      prepareAndSendResults(runId, caseIds, result.getKey(), result.getValue());
    }
  }

  private void prepareAndSendResults(Integer runId, Set<Integer> caseIds, String featureName, Results results) {
    var resultsPayload = new ArrayList<Result>();
    for (var scenarioResult : results.getScenarioResults().toList()) {
      var scenarioName = scenarioResult.getScenario().getName();
      if (CollectionUtils.isEmpty(scenarioResult.getScenario().getTags())) {
        logger.warn("prepareAndSendResults: Cannot retrieve tags for [{}] scenario and [{}] feature", scenarioName, featureName);
        continue;
      }

      var resultPayload = new Result();
      if (setCaseId(caseIds, scenarioResult, resultPayload)) {
        continue;
      }
      setStatus(scenarioResult, resultPayload);
      logger.debug("prepareAndSendResults: Prepared result payload for [{}] scenario and [{}] feature: {}", scenarioName, featureName, resultPayload);

      resultsPayload.add(resultPayload);
    }

    if (resultsPayload.isEmpty()) {
      logger.warn("prepareAndSendResults: No results payload was prepared for [{}]", featureName);
      return;
    }
    logger.debug("prepareAndSendResults: Prepared results for [{}]: {}", featureName, resultsPayload);
    sendResults(runId, featureName, resultsPayload);
  }

  private boolean setCaseId(Set<Integer> caseIds, ScenarioResult scenarioResult, Result resultPayload) {
    var scenarioName = scenarioResult.getScenario().getName();
    var optional = scenarioResult.getScenario().getTags().stream()
      .filter(tag -> tag.getName() != null && tag.getName().startsWith("C"))
      .map(tag -> tag.getName().replace("C", ""))
      .map(Integer::parseInt)
      .findFirst();
    if (optional.isEmpty()) {
      logger.warn("setCaseId: Cannot set case id for [{}] scenario, invalid tag format", scenarioName);
      return true;
    }

    var caseId = optional.get();
    if (!caseIds.contains(caseId)) {
      logger.warn("setCaseId: Cannot set id {} for [{}] scenario, case id is not associated with the current run", caseId, scenarioName);
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
    logger.debug("sendResults:: Created results [{}] response: {}", featureName, responsePayload);
  }
}
