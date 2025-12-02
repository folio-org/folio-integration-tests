package org.folio.test;

import com.epam.reportportal.junit5.ReportPortalExtension;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.RuntimeHook;
import com.intuit.karate.StringUtils;
import org.apache.commons.lang3.RandomUtils;
import org.folio.test.hooks.FolioRuntimeHook;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.TestInstance.Lifecycle;
import org.junit.jupiter.api.extension.ExtendWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

import static org.folio.test.config.TestParam.KARATE_ENV;
import static org.folio.test.config.TestParam.TEST_TENANT;

@Deprecated(forRemoval = true)
@TestInstance(Lifecycle.PER_CLASS)
@ExtendWith(ReportPortalExtension.class)
public abstract class TestBase {

  protected static final Logger logger = LoggerFactory.getLogger(TestBase.class);
  private static final int DEFAULT_THREAD_COUNT = 1;
  private static final String DEFAULT_TENANT_TEMPLATE = "testtenant";

  private final TestIntegrationService testIntegrationService;
  private final Map<Class<?>, AtomicInteger> testCounts = new HashMap<>();
  private boolean shouldCreateTenant = false;

  public TestBase(TestIntegrationService testIntegrationService) {
    this.testIntegrationService = testIntegrationService;
  }

  @BeforeAll
  public void beforeAll() {
    runHook();
  }

  public void runHook() {
    Optional.ofNullable(System.getenv(KARATE_ENV.getValue()))
      .ifPresent(env -> System.setProperty(KARATE_ENV.getValue(), env));
    // Provide uniqueness of "testTenant" based on the value specified when karate tests runs
    String testTenant = System.getProperty(TEST_TENANT.getValue());
    if (StringUtils.isBlank(testTenant)) {
      System.setProperty(TEST_TENANT.getValue(), DEFAULT_TENANT_TEMPLATE + RandomUtils.nextLong());
      shouldCreateTenant = true;
    } else {
      shouldCreateTenant = false;
    }
  }

  @AfterAll
  public void afterAll() {
  }

  // ============================== For one file & multiple features ==============================

  protected void runFeature(String featurePath) {
    runFeature(featurePath, DEFAULT_THREAD_COUNT, null);
  }

  protected void runFeature(String featurePath, TestInfo testInfo) {
    runFeature(featurePath, DEFAULT_THREAD_COUNT, testInfo);
  }

  protected void runFeature(String featurePath, int threadCount, TestInfo testInfo) {
    if (StringUtils.isBlank(featurePath)) {
      logger.warn("runFeature:: No feature path specified");
      return;
    }
    var idx = Math.max(featurePath.lastIndexOf("/"), featurePath.lastIndexOf("\\"));
    var featureName = featurePath.substring(++idx);
    internalRun(featurePath, featureName, threadCount, testInfo);
  }

  // ============================== For one file & one feature ==============================

  protected void runFeatureTest(String featureName) {
    runFeatureTest(featureName, DEFAULT_THREAD_COUNT, null);
  }

  protected void runFeatureTest(String featureName, TestInfo testInfo) {
    runFeatureTest(featureName, DEFAULT_THREAD_COUNT, testInfo);
  }

  protected void runFeatureTest(String featureName, int threadCount) {
    runFeatureTest(featureName, threadCount, null);
  }

  protected void runFeatureTest(String featureName, int threadCount, TestInfo testInfo) {
    if (StringUtils.isBlank(featureName)) {
      logger.warn("runFeatureTest:: No test feature name specified");
      return;
    }
    if (!featureName.endsWith("feature")) {
      featureName = featureName.concat(".feature");
    }
    internalRun(testIntegrationService.getTestConfiguration()
      .basePath()
      .concat(featureName), featureName, threadCount, testInfo);
  }

  private void internalRun(String path, String featureName, int threadCount, TestInfo testInfo) {
    AtomicInteger testCount = testCounts.computeIfAbsent(getClass(), key -> new AtomicInteger());
    RuntimeHook hook = new FolioRuntimeHook(getClass(), testInfo, testCount.incrementAndGet());

    Runner.Builder builder = Runner.path(path)
      .outputHtmlReport(true)
      .outputCucumberJson(true)
      .outputJunitXml(true)
      .hook(hook)
      .tags("~@Ignore", "~@NoTestRail");

    Results results = builder.parallel(threadCount);
    try {
      testIntegrationService.generateReport(results.getReportDir());
    } catch (IOException ioe) {
      logger.error("Error occurred during feature's report generation in an internal run: {}", ioe.getMessage());
    }
    testIntegrationService.addResult(featureName, results);

    Assertions.assertEquals(0, results.getFailCount());
  }
}
