package org.folio;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;


@FolioTest(team = "vega", module = "mod-circulation")
class ModCirculationTests extends TestBase {

  private static final String TEST_BASE_PATH = "classpath:vega/mod-circulation/features/";

  public ModCirculationTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:vega/mod-circulation/circulation-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Test
  void rootTest() {
    runFeatureTest("root");
  }

  @Test
  void runParallelTest() {
    TestIntegrationService testIntegrationService = new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH));
    String featureName = "parallelCheckout.feature";
    Runner.Builder builder = Runner.path(testIntegrationService.getTestConfiguration()
                    .getBasePath()
                    .concat(featureName))
            .outputHtmlReport(true)
            .outputCucumberJson(true)
            .outputJunitXml(true)
            .tags("~@Ignore", "~@NoTestRail");
    Results results = builder.parallel(2);
    try {
      testIntegrationService.generateReport(results.getReportDir());
    } catch (IOException ex) {
      logger.error("Error occurred during feature's report generation: {}", ex.getMessage());
    }
    testIntegrationService.addResult(featureName, results);
    Assertions.assertEquals(1, results.getFailCount());
    Assertions.assertTrue(results.getErrorMessages().contains("Patron has reached maximum limit of 1 items for material type"));
  }

}
