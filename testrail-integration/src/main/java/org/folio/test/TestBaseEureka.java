package org.folio.test;

import com.epam.reportportal.junit5.ReportPortalExtension;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.RuntimeHook;
import com.intuit.karate.StringUtils;
import org.apache.commons.lang3.RandomUtils;
import org.folio.test.karate.FolioRuntimeHook;
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
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

@TestInstance(Lifecycle.PER_CLASS)
@ExtendWith(ReportPortalExtension.class)
public abstract class TestBaseEureka {


    private static final int DEFAULT_THREAD_COUNT = 1;
    private static final String TENANT_TEMPLATE = "testtenant";

    protected static final Logger logger = LoggerFactory.getLogger(TestBaseEureka.class);

    private final TestIntegrationService testIntegrationService;

    private Map<Class<?>, AtomicInteger> testCounts = new HashMap<>();

    private boolean shouldCreateTenant = false;

    public TestBaseEureka(TestIntegrationService integrationHelper) {
        this.testIntegrationService = integrationHelper;
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
            logger.error("Error occurred during feature's report generation: {}", ioe.getMessage());
        }

        testIntegrationService.addResult(featureName, results);

        Assertions.assertEquals(0, results.getFailCount());

        logger.debug("feature {} run result {} ", path, results.getErrorMessages());
    }

    protected void runFeature(String featurePath) {
        this.runFeature(featurePath, DEFAULT_THREAD_COUNT, null);
    }

    protected void runFeature(String featurePath, TestInfo testInfo) {
        this.runFeature(featurePath, DEFAULT_THREAD_COUNT, testInfo);
    }

    protected void runFeature(String featurePath, int threadCount, TestInfo testInfo) {
        if (StringUtils.isBlank(featurePath)) {
            logger.warn("No feature path specified");
            return;
        }
        int idx = Math.max(featurePath.lastIndexOf("/"), featurePath.lastIndexOf("\\"));
        internalRun(featurePath, featurePath.substring(++idx), threadCount, testInfo);
    }

    protected void runFeatureTest(String testFeatureName) {
        this.runFeatureTest(testFeatureName, DEFAULT_THREAD_COUNT, null);
    }

    protected void runFeatureTest(String testFeatureName, TestInfo testInfo) {
        this.runFeatureTest(testFeatureName, DEFAULT_THREAD_COUNT, testInfo);
    }

    protected void runFeatureTest(String testFeatureName, int threadCount) {
        this.runFeatureTest(testFeatureName, threadCount, null);
    }

    protected void runFeatureTest(String testFeatureName, int threadCount, TestInfo testInfo) {
        if (StringUtils.isBlank(testFeatureName)) {
            logger.warn("No test feature name specified");
            return;
        }
        if (!testFeatureName.endsWith("feature")) {
            testFeatureName = testFeatureName.concat(".feature");
        }
        internalRun(testIntegrationService.getTestConfiguration()
                .getBasePath()
                .concat(testFeatureName), testFeatureName, threadCount, testInfo);
    }

    @BeforeAll
    public void beforeAll() {
        runHook();
    }

    @AfterAll
    public void afterAll() {
    }

    public void runHook() {
        Optional.ofNullable(System.getenv("karate.env"))
                .ifPresent(env -> System.setProperty("karate.env", env));
        // Provide uniqueness of "testTenant" based on the value specified when karate tests runs
        String testTenant = System.getProperty("testTenant");
        if (StringUtils.isBlank(testTenant)) {
            System.setProperty("testTenant", TENANT_TEMPLATE + RandomUtils.nextLong());
            System.setProperty("testTenantId", UUID.randomUUID().toString());
            shouldCreateTenant = true;
        } else {
            shouldCreateTenant = false;
        }
        // Provide clientSecret to work with keycloak
        String clientSecret = System.getenv("clientSecret");
        if (clientSecret != null) {
            System.setProperty("clientSecret", clientSecret);
        }
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
                logger.warn("No feature path specified");
                return;
            }

            String actualFeaturePath = featurePath;
            if (!featurePath.startsWith("classpath:")) {
                actualFeaturePath = testIntegrationService.getTestConfiguration()
                        .getBasePath()
                        .concat(featurePath);
            }

            AtomicInteger testCount = testCounts.computeIfAbsent(getClass(), key -> new AtomicInteger());
            RuntimeHook hook = new FolioRuntimeHook(getClass(), testInfo, testCount.incrementAndGet());

            Runner.Builder builder = Runner.path(actualFeaturePath)
                    .outputCucumberJson(true)
                    .outputJunitXml(true)
                    .outputHtmlReport(outputHtmlReport)
                    .hook(hook)
                    .tags("~@Ignore", "~@NoTestRail");

            if (reportDir != null) {
                builder = builder.reportDir(reportDir);
            }

            Results results = builder.parallel(threadCount);

            // Only generate report if not using custom reportDir or if explicitly enabled
            if (reportDir == null || outputHtmlReport) {
                try {
                    testIntegrationService.generateReport(results.getReportDir());
                } catch (IOException ioe) {
                    logger.error("Error occurred during feature's report generation: {}", ioe.getMessage());
                }
            }

            int idx = Math.max(featurePath.lastIndexOf("/"), featurePath.lastIndexOf("\\"));
            String featureName = featurePath.substring(++idx);
            testIntegrationService.addResult(featureName, results);

            Assertions.assertEquals(0, results.getFailCount());
            logger.debug("feature {} run result {} ", featurePath, results.getErrorMessages());
        }
    }

}
