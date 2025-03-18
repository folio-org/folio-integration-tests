package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "citation", module = "mod-linked-data")
@Disabled("Until karate scenarios would be refactored")
@Deprecated
class ModLinkedDataEurekaTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH =
    "classpath:citation/mod-linked-data/eureka/features/";

  public ModLinkedDataEurekaTest() {
    super(
      new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH))
    );
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:citation/mod-linked-data/eureka/linked-data-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void createInstanceAndWorkThroughApi() {
    runFeatureTest("create-bib-api/create-bib-api.feature");
  }

  @Test
  void createBibRecordInSrsAndUpdateInstanceThroughApi() {
    runFeatureTest("update-instance-api/update-instance.feature");
  }

  @Test
  void changeSuppressFlagsForInstance() {
    runFeatureTest("suppress-flags/suppress-flags.feature");
  }

  @Test
  void updateAuthority() {
    runFeatureTest("authority/authority-update.feature");
  }

  @Test
  void importBibRecordFromSrsToLinkedData() {
    runFeatureTest("import-bib/import-bib.feature");
  }

  @Test
  void lccnPatternValidation() {
    runFeatureTest("lccn-pattern-validation/lccn-pattern-validation.feature");
  }

  @Test
  void lccnDeduplication() {
    runFeatureTest("validation/lccn/deduplication/lccn-deduplication.feature");
  }
}
