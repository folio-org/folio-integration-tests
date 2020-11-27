package org.folio.testrail;

import java.io.IOException;
import java.util.Optional;

import org.apache.commons.lang3.RandomUtils;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.TestInstance.Lifecycle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.StringUtils;

@TestInstance(Lifecycle.PER_CLASS)
public abstract class AbstractTestRailIntegrationTest {

  private static final String TENANT_TEMPLATE = "testenant";

  protected static final Logger logger = LoggerFactory.getLogger(AbstractTestRailIntegrationTest.class);

  private final TestRailIntegrationService testRailIntegrationService;
  private Long runId;

  public AbstractTestRailIntegrationTest(TestRailIntegrationService integrationHelper) {
    this.testRailIntegrationService = integrationHelper;
  }

  private void internalRun(String path, String featureName) {
    Results results = Runner.path(path)
      .tags("~@Ignore", "~@NoTestRail")
      .parallel(1);

    try {
      testRailIntegrationService.generateReport(results.getReportDir());
    } catch (IOException ioe) {
      logger.error("Error occurred during feature's report generation: {}", ioe.getMessage());
    }

    testRailIntegrationService.addResult(featureName, results);

    Assertions.assertEquals(0, results.getFailCount());

    logger.debug("feature {} run result {} ", path, results.getErrorMessages());
  }

  protected void runFeature(String featurePath) {
    if (StringUtils.isBlank(featurePath)) {
      logger.warn("No feature path specified");
      return;
    }
    int idx = Math.max(featurePath.lastIndexOf("/"), featurePath.lastIndexOf("\\"));
    internalRun(featurePath, featurePath.substring(++idx));
  }

  protected void runFeatureTest(String testFeatureName) {
    if (StringUtils.isBlank(testFeatureName)) {
      logger.warn("No test feature name specified");
      return;
    }
    if (!testFeatureName.endsWith("feature")) {
      testFeatureName = testFeatureName.concat(".feature");
    }
    internalRun(testRailIntegrationService.getTestConfiguration()
      .getBasePath()
      .concat(testFeatureName), testFeatureName);
  }

  protected static boolean isTestRailIntegrationEnabled() {
    boolean isTestRailsEnabled = System.getProperty("testrail_url") != null;
    logger.debug("TestRails integration status, isTestRailsEnabled: {}", isTestRailsEnabled);
    return isTestRailsEnabled;
  }

  @BeforeAll
  public void beforeAll() {
    runHook();
    if (isTestRailIntegrationEnabled()) {
      // Create Test Run
      this.runId = testRailIntegrationService.createTestRun();
      logger.debug("RunID : {}", this.runId);
    }
  }

  @AfterAll
  public void afterAll() {
    if (isTestRailIntegrationEnabled()) {
      // get number of cases in suite
      testRailIntegrationService.sendToTestRail();
      testRailIntegrationService.closeRun(runId);
    }
  }

  public void runHook() {
    Optional.ofNullable(System.getenv("karate.env"))
      .ifPresent(env -> System.setProperty("karate.env", env));
    // Provide uniqueness of "testTenant" based on the value specified when karate tests runs
    System.setProperty("testTenant", TENANT_TEMPLATE + RandomUtils.nextLong());
  }

}
