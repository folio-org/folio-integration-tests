package org.folio.test;

import com.epam.reportportal.junit5.ReportPortalExtension;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.RuntimeHook;
import com.intuit.karate.StringUtils;
import org.apache.commons.lang3.RandomUtils;
import org.folio.test.config.CommonFeature;
import org.folio.test.hooks.FolioRuntimeHook;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.folio.test.shared.SharedCacheInstanceExtension;
import org.folio.test.utils.EnvUtils;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.TestInstance.Lifecycle;
import org.junit.jupiter.api.extension.ExtendWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

import static org.folio.test.config.TestParam.CLIENT_SECRET;
import static org.folio.test.config.TestParam.KARATE_ENV;
import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;
import static org.folio.test.config.TestRailEnv.TESTRAIL_RUN_ID;

@TestInstance(Lifecycle.PER_CLASS)
@ExtendWith(ReportPortalExtension.class)
@ExtendWith(SharedCacheInstanceExtension.class)
public abstract class TestBaseEureka {

  private static final Logger logger = LoggerFactory.getLogger(TestBaseEureka.class);
  private static final int DEFAULT_THREAD_COUNT = 1;
  private static final String DEFAULT_TENANT_TEMPLATE = "testtenant";

  protected final TestIntegrationService testIntegrationService;
  protected final TestRailService testRailService;
  private final Integer runId;
  private final Map<Class<?>, AtomicInteger> testCounts = new HashMap<>();
  private boolean shouldCreateTenant = false;

  public TestBaseEureka(TestIntegrationService testIntegrationService) {
    this(testIntegrationService, null);
  }

  public TestBaseEureka(TestIntegrationService testIntegrationService, TestRailService testRailService) {
    this.testIntegrationService = testIntegrationService;
    this.testRailService = testRailService;
    this.runId = EnvUtils.getInt(TESTRAIL_RUN_ID);
  }

  @BeforeAll
  public void beforeAll() {
    runHook();
  }

  public void runHook() {
    Optional.ofNullable(System.getenv(KARATE_ENV.getValue()))
      .ifPresent(env -> System.setProperty(KARATE_ENV.getValue(), env));
    // Provide uniqueness of "testTenant" based on the value specified when karate tests runs
    var testTenant = System.getProperty(TEST_TENANT.getValue());
    if (StringUtils.isBlank(testTenant)) {
      System.setProperty(TEST_TENANT.getValue(), DEFAULT_TENANT_TEMPLATE + RandomUtils.nextLong());
      System.setProperty(TEST_TENANT_ID.getValue(), UUID.randomUUID().toString());
      shouldCreateTenant = true;
    } else {
      shouldCreateTenant = false;
    }
    // Provide clientSecret to work with keycloak
    var clientSecret = System.getenv(CLIENT_SECRET.getValue());
    if (clientSecret != null) {
      System.setProperty(CLIENT_SECRET.getValue(), clientSecret);
    }
  }

  @AfterAll
  public void afterAll() {
    if (isTestRailEnabled()) {
      var results = testIntegrationService.getResults();
      testRailService.createResults(runId, results);
    }
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

  protected void runFeatureTest(String featureName, int threadCount) {
    runFeatureTest(featureName, threadCount, null);
  }

  protected void runFeatureTest(String featureName, TestInfo testInfo) {
    runFeatureTest(featureName, DEFAULT_THREAD_COUNT, testInfo);
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

  // ============================== For a list of files with multiple features ==============================

  public void runFeatures(CommonFeature[] values, int threadCount, TestInfo testInfo) {
    var featureNames = Arrays.stream(values)
      .filter(CommonFeature::isEnabled)
      .map(CommonFeature::getFileName)
      .toList();
    var testCount = testCounts.computeIfAbsent(getClass(), key -> new AtomicInteger());
    var hook = new FolioRuntimeHook(getClass(), testInfo, testCount.incrementAndGet());

    var finalFeatureNames = new ArrayList<String>();
    featureNames.forEach(featureName -> {
      if (!featureName.endsWith("feature")) {
        featureName = featureName.concat(".feature");
      }
      finalFeatureNames.add(featureName);
    });
    logger.info("runFeatures:: Preparing features to run concurrently with {} threads", threadCount);

    var paths = finalFeatureNames.stream()
      .map(featureName -> {
        if (!featureName.startsWith("classpath:")) {
          return testIntegrationService.getTestConfiguration().basePath().concat(featureName);
        }
        return featureName;
      })
      .peek(featureName -> logger.info("runFeatures:: Preparing a feature: {}", featureName))
      .toList();

    var builder = Runner.path(paths)
      .outputHtmlReport(true)
      .outputCucumberJson(true)
      .outputJunitXml(true)
      .hook(hook)
      .tags("~@Ignore", "~@NoTestRail");
    builder.reportDir(timestampedReportDir());

    var results = builder.parallel(threadCount);
    try {
      testIntegrationService.generateReport(results.getReportDir());
    } catch (IOException ioe) {
      logger.error("Error occurred during feature's report generation in a prepared run: {}", ioe.getMessage());
    }
    finalFeatureNames.forEach(featureName -> testIntegrationService.addResult(featureName, results));

    Assertions.assertEquals(0, results.getFailCount());
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
    // This is critically important for the Test Rail integration, because the scenario results
    // only hold a pointer to the json report that we just generated after the feature run, and if
    // we truncate the folder, the pointer when used will point to nowhere, and will throw an exception
    if (isTestRailEnabled()) {
      builder.reportDir(timestampedReportDir());
    }

    Results results = builder.parallel(threadCount);
    try {
      testIntegrationService.generateReport(results.getReportDir());
    } catch (IOException ioe) {
      logger.error("Error occurred during feature's report generation in an internal run: {}", ioe.getMessage());
    }
    testIntegrationService.addResult(featureName, results);

    Assertions.assertEquals(0, results.getFailCount());
  }

  private boolean isTestRailEnabled() {
    return testRailService != null && runId != null;
  }

  /**
   * Signal creation/deletion of a test tenant in FOLIO
   */
  public boolean shouldCreateTenant() {
    return shouldCreateTenant;
  }

  /**
   * Builder for running features with custom configuration
   */
  public FeatureRunner feature(String featurePath) {
    return new FeatureRunner(featurePath);
  }

  /**
   * Helper method to generate timestamped report directory
   */
  protected String timestampedReportDir() {
    return "target/karate-reports-" + System.currentTimeMillis();
  }

  public class FeatureRunner {
    private final String featurePath;
    private String reportDir;
    private int threadCount = DEFAULT_THREAD_COUNT;
    private TestInfo testInfo;
    private boolean outputHtmlReport = true;

    private FeatureRunner(String featurePath) {
      this.featurePath = featurePath;
    }

    public FeatureRunner reportDir(String reportDir) {
      this.reportDir = reportDir;
      return this;
    }

    public FeatureRunner threadCount(int threadCount) {
      this.threadCount = threadCount;
      return this;
    }

    public FeatureRunner testInfo(TestInfo testInfo) {
      this.testInfo = testInfo;
      return this;
    }

    public FeatureRunner outputHtmlReport(boolean outputHtmlReport) {
      this.outputHtmlReport = outputHtmlReport;
      return this;
    }

    public void run() {
      if (StringUtils.isBlank(featurePath)) {
        logger.warn("run:: No feature path specified");
        return;
      }

      String actualFeaturePath = featurePath;
      if (!featurePath.startsWith("classpath:")) {
        actualFeaturePath = testIntegrationService.getTestConfiguration()
          .basePath()
          .concat(featurePath);
      }

      // Use TestBaseEureka.this.getClass() to get the actual test class (e.g., DataImportApiTest)
      // instead of the inner FeatureRunner class, so FolioRuntimeHook can find the @FolioTest annotation
      AtomicInteger testCount = testCounts.computeIfAbsent(TestBaseEureka.this.getClass(), key -> new AtomicInteger());
      RuntimeHook hook = new FolioRuntimeHook(TestBaseEureka.this.getClass(), testInfo, testCount.incrementAndGet());

      Runner.Builder builder = Runner.path(actualFeaturePath)
        .outputCucumberJson(true)
        .outputJunitXml(true)
        .outputHtmlReport(outputHtmlReport)
        .hook(hook)
        .tags("~@Ignore", "~@NoTestRail");
      if (reportDir != null) {
        builder = builder.reportDir(reportDir);
      }

      // Only generate report if not using custom reportDir or if explicitly enabled
      Results results = builder.parallel(threadCount);
      if (reportDir == null || outputHtmlReport) {
        try {
          testIntegrationService.generateReport(results.getReportDir());
        } catch (IOException ioe) {
          logger.error("Error occurred during feature's report generation in a run: {}", ioe.getMessage());
        }
      }

      int idx = Math.max(featurePath.lastIndexOf("/"), featurePath.lastIndexOf("\\"));
      String featureName = featurePath.substring(++idx);
      testIntegrationService.addResult(featureName, results);

      Assertions.assertEquals(0, results.getFailCount());
      logger.debug("run:: Ran feature {} with result: {} ", featurePath, results.getErrorMessages());
    }
  }
}
