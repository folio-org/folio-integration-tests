package org.folio.test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.RuntimeHook;
import com.intuit.karate.StringUtils;
import org.apache.commons.lang3.RandomUtils;
import org.folio.test.karate.FolioRuntimeHook;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.TestInstance.Lifecycle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

@TestInstance(Lifecycle.PER_CLASS)
public abstract class TestBase {


    private static final int DEFAULT_THREAD_COUNT = 1;
    private static final String TENANT_TEMPLATE = "testenant";

    protected static final Logger logger = LoggerFactory.getLogger(TestBase.class);

    private final TestIntegrationService testIntegrationService;

    private Map<Class<?>, AtomicInteger> testCounts = new HashMap<>();

    public TestBase(TestIntegrationService integrationHelper) {
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
        System.setProperty("testTenant", TENANT_TEMPLATE + RandomUtils.nextLong());
    }

}
