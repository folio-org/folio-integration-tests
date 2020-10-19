package org.folio.testrail;

import static org.folio.TestUtils.runHook;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.StringUtils;
import java.io.IOException;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.TestInstance.Lifecycle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@TestInstance(Lifecycle.PER_CLASS)
public abstract class AbstractTestRailIntegrationTest {

  protected static final Logger logger = LoggerFactory
      .getLogger(AbstractTestRailIntegrationTest.class);

  private TestRailIntegrationHelper integrationHelper;
  protected final boolean refreshScenarios = false;

  public AbstractTestRailIntegrationTest(TestRailIntegrationHelper integrationHelper) {
    this.integrationHelper = integrationHelper;
  }

  private void internalRun(String path, String featureName) {
    Results results = Runner.path(path)
        .tags("~@Ignore", "~@NoTestRail")
        .parallel(1);

    try {
      integrationHelper.generateReport(results.getReportDir());
    } catch (IOException ioe) {
      logger.error("Error occurred during feature's report generation: {}", ioe.getMessage());
    }
    integrationHelper.addResult(featureName, results);

    assert results.getFailCount() == 0;
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
    internalRun(integrationHelper.getTestConfiguration().getBasePath().concat(testFeatureName),
        testFeatureName);
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
      // Init connection
      integrationHelper.initConnection();

      //Create Test Run
      long runId = integrationHelper.createTestRun();
      logger.debug("RunID : {}", runId);
    }
  }

  @AfterAll
  public void afterAll() {
    if (isTestRailIntegrationEnabled()) {
      //get number of cases in suite
      integrationHelper.sendToTestTrails(refreshScenarios);
    }
  }

}