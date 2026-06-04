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
import java.util.Objects;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

import static org.folio.test.models.ResultStatus.FAILED;
import static org.folio.test.models.ResultStatus.PASSED;

public class TestRailService {

  private static final Logger logger = LoggerFactory.getLogger(TestRailService.class);
  private static final Pattern CASE_TAG_PATTERN = Pattern.compile("^C(\\d+)$");

  private final TestRailDao testRailDao;
  private final TestRailClient testRailClient;

  public TestRailService() {
    this.testRailDao = new TestRailDao();
    this.testRailClient = new TestRailClient();
  }

  public void createResults(Integer runId, Map<String, Results> results) {
    logger.info("createResults:: Starting result sync for runId={}, featureCount={}", runId, results == null ? 0 : results.size());
    var caseIds = SharedCacheInstanceInitializer.getSharedCacheInstance().getCaseIds();
    if (CollectionUtils.isEmpty(caseIds)) {
      logger.warn("createResults: Cannot create results, no case ids were found for the {} run", runId);
      return;
    }
    logger.info("createResults:: Using {} cached case ids for runId={}", caseIds.size(), runId);
    if (results == null || results.isEmpty()) {
      logger.warn("createResults:: No feature results to process for runId={}", runId);
      return;
    }
    for (var result : results.entrySet()) {
      logger.info("createResults:: Processing feature [{}]", result.getKey());
      prepareAndSendResults(runId, caseIds, result.getKey(), result.getValue());
    }
    logger.info("createResults:: Finished result sync for runId={}", runId);
  }

  private void prepareAndSendResults(Integer runId, Set<Integer> caseIds, String featureName, Results results) {
    var resultsPayload = new ArrayList<Result>();
    results.getScenarioResults().flatMap(TestRailService::flatten).forEach(scenarioResult -> {
      var scenarioName = scenarioResult.getScenario().getName();
      if (CollectionUtils.isEmpty(scenarioResult.getScenario().getTags())) {
        logger.warn("prepareAndSendResults: Cannot retrieve tags for [{}] scenario and [{}] feature", scenarioName, featureName);
        return;
      }

      var resultPayload = new Result();
      if (setCaseId(caseIds, scenarioResult, resultPayload)) {
        return;
      }
      setStatus(scenarioResult, resultPayload);
      logger.info("prepareAndSendResults: Prepared result payload for [{}] scenario and [{}] feature: {}", scenarioName, featureName, resultPayload);
      resultsPayload.add(resultPayload);
    });

    if (resultsPayload.isEmpty()) {
      logger.warn("prepareAndSendResults: No results payload was prepared for [{}]", featureName);
      return;
    }
    logger.info("prepareAndSendResults: Prepared results for [{}]: {}", featureName, resultsPayload);
    sendResults(runId, featureName, resultsPayload);
  }

  /** Top-level scenario + all scenarios reached via `call read(...)` recursively. */
  private static Stream<ScenarioResult> flatten(ScenarioResult sr) {
    if (sr == null) {
      return Stream.empty();
    }
    var nested = sr.getStepResults().stream()
      .filter(step -> step.getCallResults() != null)
      .flatMap(step -> step.getCallResults().stream())
      .flatMap(fr -> fr.getScenarioResults().stream())
      .flatMap(TestRailService::flatten);
    return Stream.concat(Stream.of(sr), nested);
  }

  private boolean setCaseId(Set<Integer> caseIds, ScenarioResult scenarioResult, Result resultPayload) {
    var scenarioName = scenarioResult.getScenario().getName();
    var optional = scenarioResult.getScenario().getTags().stream()
      .map(tag -> tag.getName())
      .filter(Objects::nonNull)
      .map(CASE_TAG_PATTERN::matcher)
      .filter(Matcher::matches)
      .map(matcher -> Integer.parseInt(matcher.group(1)))
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
    logger.info("sendResults:: Created results [{}] response: {}", featureName, responsePayload);
  }
}
